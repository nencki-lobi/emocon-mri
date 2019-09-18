import argparse
import configparser
import glob
import os
import pandas
import re
from bids import BIDSLayout


def read_logfile(log_fname, subtract_pulse=True):

    rename_dict = {
        'Event Type': 'EventType',
        'Time': 'onset',
        'Duration': 'duration',
        'Code': 'trial_type',
        }

    df = pandas.read_csv(log_fname, sep='\t', skiprows=3)
    df.rename(columns=rename_dict, inplace=True)

    # Find first pulse
    first_pulse = df.query('EventType == "Pulse"').iloc[0].onset

    # correct onset to match fMRI
    if subtract_pulse:
        df.onset = df.onset - first_pulse

    # convert onset & duration to seconds
    df.onset = df.onset / 10000
    df.duration = df.duration / 10000

    # rename fix_2 (used in DE for reasons unknown) to fix
    df.trial_type.replace('fix_2', 'fix', inplace=True)

    # Choose relevant rows & columns
    subset = (
        df
        .query('trial_type in ["fix", "cs_plus", "cs_minus", "US_stim_ON"]')
        .loc[:, ['onset', 'duration', 'trial_type']]
        )

    # Rename US trial_type
    subset.trial_type.replace('US_stim_ON', 'us', inplace=True)

    # Set us duration to 1.5 (which approximates how long the reaction lasts)
    subset.loc[subset.trial_type == 'us', 'duration'] = 1.5

    # Add 'value' column with corresponding port codes
    subset.loc[:, 'value'] = subset.trial_type.map(
        {'cs_plus': 1, 'cs_minus': 2, 'fix': 7, 'us': 8}
    )

    return subset


def read_video_logfile(log_fname, video_substitutions, video_shifts):

    rename_dict = {'Event Type': 'EventType', 'Time': 'onset'}

    # find fMRI and video onsets, first 10 rows should be plenty
    df = pandas.read_csv(log_fname, sep='\t', skiprows=3, nrows=10)
    df.rename(columns=rename_dict, inplace=True)

    first_pulse = df.query('EventType == "Pulse"').iloc[0].onset
    video_start = df.query('EventType == "Video"').iloc[0].onset

    # calculate the difference to be added to original onsets
    video_delay = (video_start - first_pulse) / 10000

    # read file until video summary and get the video file name
    with open(log_fname) as f:
        while f.readline().rstrip() != 'video summary':
            pass
        f.readline()
        v_summary = f.readline().rstrip().split('\t')

    # get filename without extension; stimuli\(anything but dot).avi
    vid_code = re.search(r'stimuli\\([^.]+)\.avi', v_summary[0]).group(1)

    # filename = code in most cases, but we also used a different naming scheme
    if vid_code in video_substitutions:
        vid_code = video_substitutions[vid_code]

    # load onsets as usual (but without correcting for first pulse)
    orig = os.path.join(
        os.path.dirname(log_fname),
        '{}-procedure OFL.log'. format(vid_code),
        )
    events = read_logfile(orig, subtract_pulse=False)

    # add video_delay to onsets
    events.onset = events.onset + video_delay

    # some videos start after scenario beginning, subtract offset in such case
    if vid_code in video_shifts:
        events.onset = events.onset - video_shifts[vid_code]

    return events


def capitalise(s):
    return s[0].upper() + s[1:].lower()


parser = argparse.ArgumentParser()
parser.add_argument('participant_label', nargs='+')
args = parser.parse_args()

config = configparser.ConfigParser()
config.read('config.ini')

BIDS_ROOT = config['DEFAULT']['BIDS_ROOT']
LOG_DIR = config['DEFAULT']['LOG_DIR']

video_dict = {
    'GYF_full': 'GYFXOU',
    'GYF_inverse': 'GYFXOU',
    'SUB-1': 'FRAMWY',
    'SUB-2': 'PAZHLQ',
    'QETQJZ': 'QETWJZ'
}

# required shifts for videos which start after scenario beginning
video_offsets = {
    'ASSYXO': 22.0,
    'HVDPMG': 14.26,
    'HWTFRX': 19.0,
    'LGBBCQ': 12.0,
    }

# initialise the bids layout
layout = BIDSLayout(BIDS_ROOT, validate=False, absolute_paths=True)

for code in args.participant_label:

    # patterns for globbing
    ofl_pat = '{}-procedure OFL.log'.format(code.upper())
    ofl_vid_pat = '{}-ofl_v_?.log'.format(code.upper())
    de_pat = '{}-procedure DE.log'.format(code.upper())

    # glob the files
    logs_ofl = glob.glob(os.path.join(LOG_DIR, ofl_pat))
    logs_ofl_vid = glob.glob(os.path.join(LOG_DIR, ofl_vid_pat))
    logs_de = glob.glob(os.path.join(LOG_DIR, de_pat))

    if len(logs_de) != 1 or (len(logs_ofl) + len(logs_ofl_vid)) != 1:
        raise RuntimeError('Could not find the right number of log files')

    # load events
    events = {}
    if len(logs_ofl) == 1:
        events['ofl'] = read_logfile(logs_ofl[0])
    else:
        events['ofl'] = read_video_logfile(logs_ofl_vid[0], video_dict,
                                           video_offsets)

    events['de'] = read_logfile(logs_de[0])

    # save the events
    for task in ('ofl', 'de'):
        # placeholder files are created by heudiconv, so we can use get
        tsv_file = layout.get(
            subject=capitalise(code),
            datatype='func',
            task=task,
            suffix='events',
            extension='tsv',
            return_type='filename',
            )
        events[task].to_csv(tsv_file[0], sep='\t', index=False,
                            float_format='%.3f')
        print('Written', tsv_file[0])
