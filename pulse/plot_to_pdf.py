import configparser
import matplotlib.pyplot as plt
import numpy as np
import os
import time

from bids import BIDSLayout
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib.ticker import FuncFormatter


def plot(bids_df):
    global participant_table

    data = np.loadtxt(bids_df.path)
    meta = bids_df.get_metadata()

    fs = meta["SamplingFrequency"]

    subject = bids_df.entities['subject']
    task = bids_df.entities['task']

    # get group from the table
    sub_info = participant_table[participant_table.participant_id == subject]
    group = sub_info['group'].iloc[0]

    # different settings for different tasks
    if task == 'ofl':
        max_duration = 17*60 + 19 if group == 'friend' else 18*60 + 21
        frag_starts = [120, 600, 1000]
        start_row = 0
    else:
        max_duration = 8*60 + 58
        frag_starts = [120, 300, 480]
        start_row = 2

    # trim the signal at start...
    n_samp = int(abs(meta["StartTime"]))
    if meta["StartTime"] < 0:
        # trim everything prior to first functional volume
        data = data[n_samp:]
    else:
        data = np.concatenate((np.zeros(n_samp), data))

    # ...and the end as well
    if len(data) > max_duration*fs:
        data = data[:max_duration*fs]

    # create a formatter to display time
    time_formatter = FuncFormatter(
        lambda x, pos=None: time.strftime('%M:%S', time.gmtime(x/fs)))

    # plot whole signal (to identify very bad fragments)
    ax_main = plt.subplot2grid((4, 3), (start_row, 0), colspan=3)
    ax_main.plot(data)
    ax_main.xaxis.set_major_formatter(time_formatter)
    ax_main.set_title(task)

    # plot 3 segments of 20 seconds to observe shape
    for i, start_sec in enumerate(frag_starts):
        ax_small = plt.subplot2grid((4, 3), (start_row+1, i), colspan=1)
        ax_small.plot(data[start_sec*fs: (start_sec+20)*fs])
        ax_small.xaxis.set_major_formatter(time_formatter)

    # set figure title
    plt.suptitle(subject)


config = configparser.ConfigParser()
config.read('config.ini')
BIDS_ROOT = config['DEFAULT']['BIDS_ROOT']

layout = BIDSLayout(BIDS_ROOT)

ofl_files = layout.get(task='ofl', suffix='physio', extension='tsv.gz')

participant_table = layout.get(suffix='participants')[0].get_df()
participant_table.participant_id = \
    participant_table.participant_id.str.replace('sub-', '')

pdf_file_path = os.path.expanduser('~/Desktop/my_file.pdf')

with PdfPages(pdf_file_path) as pdf:
    for ofl_df in ofl_files:
        de_df = layout.get(subject=ofl_df.entities['subject'], task='de',
                           suffix='physio', extension='tsv.gz')[0]

        plt.figure(figsize=(8.27, 11.1))
        plot(ofl_df)
        plot(de_df)
        pdf.savefig()
        plt.close()
