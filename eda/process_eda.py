import argparse
import configparser
import glob
import os
import numpy as np
import pandas
import mne
import matplotlib.pyplot as plt
import scipy.signal as ss

from ecphysio.eventhandler import EventCollection
from ecphysio.eda import Trial
from ecphysio.cvxEDA import cvxEDA


def read_data(hdr_path):
    """Extract signal, events and sampling frequency from file"""

    mne_data = mne.io.read_raw_brainvision(hdr_path)
    sampling_freq = int(mne_data.info['sfreq'])
    eda = mne_data.get_data().flatten() * 1e6  # gives microsiemens
    events, event_id = mne.events_from_annotations(mne_data)
    event_col = EventCollection.from_mne_events(events)

    print(event_id)

    return eda, event_col, sampling_freq


def extract_phase(signal, events, start_mrk, stop_mrk):
    phase_start = events.samples_for_marker(start_mrk)[0]
    phase_end = events.samples_for_marker(stop_mrk)[0]
    phase_signal = signal[phase_start:phase_end]
    phase_events = events.events_between_events(start_mrk, stop_mrk)
    phase_ec = EventCollection.from_list(phase_events, reset_samples=True)

    return phase_signal, phase_ec


def process_phase(all_signal, all_events, start_mrk, stop_mrk, fs):

    # hardcoded: length of trial and baseline
    n_s = (9+10)*fs  # take 9 seconds of CS and 10 seconds of fix
    n_b_s = 2*fs

    # extract relevant signal & events
    signal, events = extract_phase(all_signal, all_events, start_mrk, stop_mrk)

    # decompose (later replace with 0.05 - 1 Hz filtering)
    [r, p, t, l, d, e, obj] = cvxEDA(signal, 1/fs)

    # extract trials
    trials = []
    onsets_cs = events.samples_for_marker(1) + events.samples_for_marker(2)
    onsets_cs.sort()

    for onset in onsets_cs:
        trial_events = events.events_between_samples(onset, onset+n_s)
        trials.append(Trial(events=trial_events,
                            n_samples=n_s,
                            n_bl_samples=n_b_s,
                            fs=fs,
                            signal=r,
                            smna=p,
                            ))

    return trials


def score_trials(list_of_trials, name):
    # score trials

    scores = []
    for n, trial in enumerate(list_of_trials):
        stimulus = 'CS+' if 1 in trial.event_values else 'CS-'
        amplitude, peak_time = trial.score_eir(
            onset=0,
            duration=6,
            baseline_length=2)

        scores.append(
            {
                'stimulus': '{} {}'.format(name, stimulus),
                'trial': n,
                'amplitude': amplitude,
            })

        # in obs stage, score reaction to US (or US absent), but only for CS+
        if name == 'obs' and 1 in trial.event_values:

            stimulus = 'US present' if 8 in trial.event_values else 'US absent'
            amplitude, peak_time = trial.score_eir(
                onset=7.5,
                duration=6,
                baseline_length=2)

            scores.append(
                {
                    'stimulus': '{} {}'.format(name, stimulus),
                    'trial': n,
                    'amplitude': amplitude
                })

    return scores


def score_trials_smna(list_of_trials, name):

    scores = []
    for n, trial in enumerate(list_of_trials):

        if name == 'obs' and 1 in trial.event_values:
            # for obs, score only US / noUS
            stimulus = 'US present' if 8 in trial.event_values else 'US absent'
            amplitude, peak_time = trial.score_smna(onset=7.5, duration=6)

        elif name == 'direct':
            # for direct, score CSs over all duration
            stimulus = 'CS+' if 1 in trial.event_values else 'CS-'
            amplitude, peak_time = trial.score_smna(onset=0, duration=9)

        else:
            # ignore other trials
            continue

        scores.append(
            {
                'stimulus': '{} {}'.format(name, stimulus),
                'trial': n,
                'amplitude': amplitude
            })
    return scores


def save_scores(list_of_scores, subject_code, suffix=''):
    df_directory = os.path.expanduser(os.path.join('~/', 'Desktop', 'eda'))
    df = pandas.DataFrame.from_records(list_of_scores)

    if not os.path.exists(df_directory):
        os.makedirs(df_directory)
    df_filename = os.path.join(df_directory, subject_code + suffix + '.pickle')
    df.to_pickle(df_filename)


def plot_trials(nrows, ncols, trials, fname):
    fig, axs = plt.subplots(nrows, ncols, figsize=(12.8, 7.2), sharey=True)
    pmax = np.max([trial.smna.max() for trial in trials])
    for i, ax in enumerate(axs.flat):
        tx = ax.twinx()
        tx.set_ylim(0, pmax)
        trials[i].plot(ax, tx)
    fig.savefig(fname)
    plt.close(fig)


# load paths
config = configparser.ConfigParser()
config.read('config.ini')

EDA_DIR = config['DEFAULT']['EDA_DIR']
BIDS_ROOT = config['DEFAULT']['BIDS_ROOT']

# parse command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--participant_label', nargs='+')
args = parser.parse_args()

# subjects to process - either specified or all
if args.participant_label is not None:
    vhdr_files = [os.path.join(EDA_DIR, x.upper() + '.vhdr')
                  for x in args.participant_label]
else:
    vhdr_files = glob.glob(os.path.join(EDA_DIR, '*.vhdr'))

# constants
target_fs = 25

# load group assignment
group_table = pandas.read_csv(
    filepath_or_buffer=os.path.join(BIDS_ROOT, 'participants.tsv'),
    sep='\t',
    usecols=['participant_id', 'group'],
    converters={'participant_id': lambda s: s.split('-')[-1].upper()},
    index_col='participant_id',
)

# process files
for hdr_file in vhdr_files:

    # obtain subject code
    code = os.path.splitext(os.path.basename(hdr_file))[0]

    # obtain subject group
    group = group_table.loc[code].group

    # skip stranger group (for now)
    if group == 'stranger':
        continue

    # load data & events
    eda, event_collection, fs = read_data(hdr_file)

    # TODO: for stranger group load OFL events from log file WOHOOO!

    # fix events if necessary
    if code == 'ZTLHXI':
        # DE started again, drop first occurrence of marker 15 - 'DE start'
        i_drop = event_collection.as_marker_list().index(15)
        event_collection.remove_at_index(i_drop)

    # downsample to 25 Hz
    if fs % target_fs == 0:
        ds_factor = int(fs/target_fs)
        eda = ss.decimate(eda, ds_factor)
        event_collection.downsample(ds_factor)
    else:
        raise RuntimeError('Unexpected sampling frequency')

    # divide into trials
    trials_ofl = process_phase(eda, event_collection, 13, 14, target_fs)
    trials_de = process_phase(eda, event_collection, 15, 16, target_fs)

    # score the trials
    scores_ofl = score_trials(trials_ofl, 'obs')
    scores_de = score_trials(trials_de, 'direct')

    # gather & save trial scores
    scores = scores_ofl + scores_de
    for score in scores:
        score['code'] = code
    save_scores(scores, code)

    # score & save also the SMNA while we have it
    smna_ofl = score_trials_smna(trials_ofl, 'obs')
    smna_de = score_trials_smna(trials_de, 'direct')
    smna_all = smna_ofl + smna_de
    for s in smna_all:
        s['code'] = code
    save_scores(smna_all, code, '_smna')

    # plot trials
    fig_directory = os.path.expanduser('~/Desktop/eda/figures')  # todo
    if not os.path.exists(fig_directory):
        os.makedirs(fig_directory)
    plot_trials(8, 6, trials_ofl,
                fname=os.path.join(fig_directory, code + '_trials_OFL.png'))
    plot_trials(6, 4, trials_de,
                fname=os.path.join(fig_directory, code + '_trials_DE.png'))
