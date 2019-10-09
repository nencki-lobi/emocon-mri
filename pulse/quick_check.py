"""
This script can be used to plot the PulseOx trace for a given subject.
"""

import argparse
import configparser
import matplotlib.pyplot as plt
import numpy as np

from bids import BIDSLayout

config = configparser.ConfigParser()
config.read('config.ini')
BIDS_ROOT = config['DEFAULT']['BIDS_ROOT']

parser = argparse.ArgumentParser()
parser.add_argument('participant_label')
args = parser.parse_args()

layout = BIDSLayout(BIDS_ROOT, validate=False)

files = layout.get(
    subject=args.participant_label.capitalize(),
    suffix='physio',
    extension='tsv.gz',
    )

if len(files) == 0:
    print('No physio recordings for subject', args.participant_label)

for obj in files:

    data = np.loadtxt(obj.path)

    metadata = obj.get_metadata()
    fs = metadata['SamplingFrequency']
    start_time = metadata['StartTime']

    ent = obj.get_entities()

    if start_time < 0:
        start_sample = - start_time * fs
        data = data[int(start_sample):]
        time = np.linspace(0, data.shape[0]/fs, data.shape[0])
    else:
        time = np.linspace(0, data.shape[0]/fs, data.shape[0]) + start_time

    plt.figure(figsize=(9, 6))
    plt.plot(time, data)
    plt.xlabel('time [s]')
    plt.title('subject: {}, task: {}'.format(ent['subject'], ent['task']))

plt.show()
