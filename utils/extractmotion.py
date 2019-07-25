import argparse
import configparser
import os
import pandas
import re

parser = argparse.ArgumentParser()
parser.add_argument('--friston24', action='store_true',
                    help='Add derivatives and squares of motion parameters')
parser.add_argument('--participant-label', nargs='+')
args = parser.parse_args()

if args.friston24:
    motion_regex = '^trans|^rot'
    output_fname = '{subject}_{task}_f24.txt'
else:
    motion_regex = '^(trans|rot)_[xyz]$'
    output_fname = '{subject}_{task}.txt'

config = configparser.ConfigParser()
config.read('config.ini')

DERIV_DIR = config['DEFAULT']['DERIV_DIR']
SPM_CONFOUNDS_DIR = config['SPM']['CONFOUNDS']

fmriprep_dir = os.path.join(DERIV_DIR, 'fmriprep')

# The output dir must exist for DataFrame.to_csv() to work
if not os.path.exists(SPM_CONFOUNDS_DIR):
    os.makedirs(SPM_CONFOUNDS_DIR)

# Process both tasks
tasks = ['ofl', 'de']

# Process all subjects if --participant-label is not given
if args.participant_label is None:
    subjects = []
    for f in os.listdir(fmriprep_dir):
        match = re.match(r'sub-(\w+)$', f)
        if match is not None:
            subjects.append(match.group(1))
else:
    subjects = args.participant_label

input_fname = os.path.join(
    'sub-{subject}',
    'func',
    'sub-{subject}_task-{task}_desc-confounds_regressors.tsv',
    )

for subject in subjects:
    for task in tasks:
        input_path = os.path.join(
            fmriprep_dir,
            input_fname.format(subject=subject, task=task),
            )
        output_path = os.path.join(
            SPM_CONFOUNDS_DIR,
            output_fname.format(subject=subject, task=task),
            )
        try:
            confounds = pandas.read_csv(input_path, sep='\t')
        except FileNotFoundError:
            print('[WARNING] file:', input_path, 'not found, skipping')
            continue
        subset = confounds.filter(regex=motion_regex)
        subset.to_csv(output_path, sep='\t', header=False, index=False,
                      na_rep='0')
