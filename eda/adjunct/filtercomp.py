"""
Compare two filtering strategies for EDA. Included filter designs seem optimal.
"""

import configparser
import matplotlib.pyplot as plt
import numpy as np
import os
import scipy.signal as ss
from mne.io import read_raw_brainvision


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


def preproc_2(x):
    """Downsample to 10 Hz fs, apply 0.0159 Hz highpass filter"""
    # downsample (large factor, use two steps)
    ds_1st_pass = ss.decimate(x, 5)  # 50 Hz, assuming 250 Hz input
    ds = ss.decimate(ds_1st_pass, 5)  # 10 hz

    # create adjusted time axis
    fs = 10
    t = np.arange(0, len(ds)/fs, 1/fs)

    # design and apply filter
    b, a = ss.butter(N=1, Wn=0.0159, btype='highpass', fs=fs)
    preprocessed = ss.filtfilt(b, a, ds)

    return preprocessed, t


config = configparser.ConfigParser()
config.read('config.ini')
EDA_DIR = config['DEFAULT']['EDA_DIR']
hdr_path = os.path.join(EDA_DIR, 'ABCDEF.vhdr')

mne_data = read_raw_brainvision(hdr_path)
sfreq = int(mne_data.info['sfreq'])
eda = mne_data.get_data().flatten() * 1e6

print('Original sampling frequency:', sfreq)
t0 = np.arange(0, len(eda)/sfreq, 1/sfreq)


eda1, t1 = preproc_1(eda)
eda2, t2 = preproc_2(eda)

plt.plot(t0, eda, label='raw')
plt.plot(t1, eda1, label='0.05 - 1 Hz')
plt.plot(t2, eda2, label='0.0159 - 5 Hz')
plt.legend(loc='upper right')
plt.show()
