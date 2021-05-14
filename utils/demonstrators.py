"""Match demonstrators to the observers

Reads log files and matches demonstrators to the observers for the
stranger group.
"""

import configparser
import glob
import os
import pandas
import re

config = configparser.ConfigParser()
config.read('../config.ini')

bids_dir = config['DEFAULT']['BIDS_ROOT']
log_dir = config['DEFAULT']['LOG_DIR']
out_file = os.path.join(
    config['DEFAULT']['QUESTIONNAIRE_DIR'], 'demonstrators.tsv')

def find_dem(obs_code, log_dir):
    
    video_substitutions = {
        'GYF_full': 'GYFXOU',
        'GYF_inverse': 'GYFXOU',
        'SUB-1': 'FRAMWY',
        'SUB-2': 'PAZHLQ',
        'QETQJZ': 'QETWJZ'
        }
    
    try:
        obs_log = glob.glob(os.path.join(log_dir, obs_code + '-ofl*'))[0]
    except IndexError:
        return None
    
    with open(obs_log) as f:
        while f.readline().rstrip() != 'video summary':
            pass
        f.readline()
        v_summary = f.readline().rstrip().split('\t')
        
    vid_code = re.search(r'stimuli\\([^.]+)\.avi', v_summary[0]).group(1)
    if vid_code in video_substitutions:
        vid_code = video_substitutions[vid_code]

    return vid_code

# read participants file
participants_file = os.path.join(bids_dir, 'participants.tsv')
participants = pandas.read_csv(participants_file, sep='\t')
participants.insert(
    loc = 0,
    column = 'subject',
    value = participants.participant_id.str.extract('sub-(\w*)')
    )

# match by checking logs
observers = participants.loc[participants.group=='stranger', 'subject']
demonstrators = (
    observers
    .str.upper()
    .apply(find_dem, args=(log_dir,))
    .str.capitalize()
    )

result = pandas.DataFrame(
    data={'observer': observers, 'demonstrator': demonstrators}
    )

if not os.path.exists(os.path.dirname(out_file)):
    os.mkdir(os.path.dirname(out_file))

result.to_csv(out_file, sep='\t', index=False)
