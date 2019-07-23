import argparse
import configparser
import numpy as np
import os
import pandas

from bids import BIDSLayout
from scipy import io

parser = argparse.ArgumentParser()
parser.add_argument('output_dir')
parser.add_argument('--participant-label', nargs='+')
parser.add_argument('--cs-duration', type=float)
parser.add_argument('--us-duration', type=float)
args = parser.parse_args()

config = configparser.ConfigParser()
config.read('config.ini')

BIDS_ROOT = config['DEFAULT']['BIDS_ROOT']

trials_to_include = {
    'ofl': ['cs_plus', 'cs_minus', 'us', 'no_us'],
    'de': ['cs_plus', 'cs_minus'],
}

layout = BIDSLayout(BIDS_ROOT, validate=False, absolute_paths=True)

# figure out which subjects to use
if args.participant_label is None:
    # if not specified, take all subjects
    subjects = layout.get_subjects()
else:
    # take the specified subjects
    subjects = args.participant_label
    # check if all are present in the layout, if not then crash now
    available_subjects = layout.get_subjects()
    for s in subjects:
        if s not in available_subjects:
            raise RuntimeError('Subject {} not present in dataset'.format(s))

# all tasks will be processed
tasks = layout.get_tasks()

# create the output folder if it does not exist
if not os.path.exists(args.output_dir):
    os.makedirs(args.output_dir)

for subject in subjects:
    for task in tasks:
        bids_events_file = layout.get(
            subject=subject,
            task=task,
            suffix='events',
            return_type='file')[0]

        events = pandas.read_csv(bids_events_file, sep='\t')

        if task == 'ofl':
            # generate noUS events
            new_rows = []
            for i in range(events.shape[0] - 1):
                if (events.iloc[i].trial_type == 'cs_plus'
                        and events.iloc[i+1].trial_type != 'us'):
                    new_rows.append([events.iloc[i].onset+7.5, 1.5, 'no_us',
                                     np.nan])
            new_events = pandas.DataFrame(new_rows, columns=events.columns)
            events = events.append(new_events, ignore_index=True)

        trial_types = trials_to_include[task]
        names = np.empty(len(trial_types), dtype=np.object)
        onsets = np.empty_like(names)
        durations = np.empty_like(names)

        for i, trial_type in enumerate(trial_types):
            matching_events = events.query('trial_type == @trial_type')

            names[i] = trial_type.replace('_', ' ')
            onsets[i] = matching_events.onset.values
            if trial_type.startswith('cs') and args.cs_duration is not None:
                durations[i] = args.cs_duration
            elif trial_type.endswith('us') and args.us_duration is not None:
                durations[i] = args.us_duration
            else:
                durations[i] = matching_events.duration.values

        out_file = '{}_{}.mat'.format(subject, task)
        out_path = os.path.join(args.output_dir, out_file)
        io.savemat(
            file_name=out_path,
            mdict={'names': names, 'onsets': onsets, 'durations': durations}
            )
