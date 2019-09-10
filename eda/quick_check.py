import argparse
import configparser
import matplotlib.pyplot as plt
import mne
import numpy as np
import os
import scipy.signal as ss

from collections import defaultdict


def compare_counts(d, marker, expectations):
    if type(expectations) is int:
        expectations = [expectations]
    if d[marker] not in expectations:
        emsg = 'Marker {} occurs {} times, expected {}.'
        print(emsg.format(marker, d[marker], expectations))


def preproc_1(x):
    """Downsample to 25 Hz, apply 0.05 - 1 Hz bandpass filter"""
    # downsample
    ds = ss.decimate(x, 10)  # to 25 Hz, assuming 250 Hz input

    # create adjusted time axis
    fs = 25
    t = np.arange(0, len(ds)/fs, 1/fs)

    # design and apply filter
    b, a = ss.butter(N=4, Wn=[0.05, 1], btype='bandpass', fs=fs)
    preprocessed = ss.filtfilt(b, a, ds)

    return preprocessed, t


config = configparser.ConfigParser()
config.read('config.ini')
EDA_DIR = config['DEFAULT']['EDA_DIR']

parser = argparse.ArgumentParser()
parser.add_argument('participant_label')
args = parser.parse_args()

hdr_file = os.path.join(EDA_DIR, args.participant_label.upper() + '.vhdr')

data = mne.io.read_raw_brainvision(hdr_file)

events, event_id = mne.events_from_annotations(data)
is_stimulus = events[:, 2] < 1000
stim_events = events[is_stimulus, :]

# check if sample rate is 250 Hz
if data.info['sfreq'] != 250:
    print('Sampling rate was {}, expected {}'.format(data.info['sfreq'], 250))

# check if number of markers is as expected
unique, counts = np.unique(stim_events[:, 2], return_counts=True)
mrk_count = defaultdict(int, zip(unique, counts))
compare_counts(mrk_count, 1, [36, 13])
compare_counts(mrk_count, 2, [36, 12])
compare_counts(mrk_count, 8, [12, 0])
compare_counts(mrk_count, 13, [0, 1])
compare_counts(mrk_count, 14, 1)
compare_counts(mrk_count, 15, 1)
compare_counts(mrk_count, 16, 1)

# plot
plt.figure(figsize=(9, 6))

ax1 = plt.subplot(211)
eda = data.get_data().flatten() * 1e6
t = np.arange(0, len(eda)/data.info['sfreq'], 1/data.info['sfreq'])
plt.plot(t, eda)

ax2 = plt.subplot(212, sharex=ax1)
eda_p, t_p = preproc_1(eda)
plt.plot(t_p, eda_p)
plt.show()
