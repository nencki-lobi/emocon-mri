import argparse
import configparser
import glob
import os
import pandas
import mne
import matplotlib.pyplot as plt
import scipy.signal as ss

from ecphysio.eventhandler import EventCollection
from ecphysio.eda import Trial


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

    # design and apply bandpass filter (0.05 Hz - 1 Hz)
    b, a = ss.butter(N=4, Wn=[0.05, 1], btype='bandpass', fs=fs)
    filtered_eda = ss.filtfilt(b, a, signal)

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
                            signal=filtered_eda,
                            smna=None,
                            ))

    return trials


def score_trials(list_of_trials, name):
    # score trials

    scores = []
    for n, trial in enumerate(list_of_trials):
        stimulus = 'CS+' if 1 in trial.event_values else 'CS-'
        amplitude, peak_time = trial.score_eir(
            onset=0,
            duration=7.5,
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
                duration=7.5,
                baseline_length=2)

            scores.append(
                {
                    'stimulus': '{} {}'.format(name, stimulus),
                    'trial': n,
                    'amplitude': amplitude
                })

    return scores


def save_scores(list_of_scores, subject_code, df_directory):
    df = pandas.DataFrame.from_records(list_of_scores)

    if not os.path.exists(df_directory):
        os.makedirs(df_directory)
    df_filename = os.path.join(df_directory, subject_code + '.pickle')
    print('Saving', df_filename)
    df.to_pickle(df_filename)


def plot_trials(nrows, ncols, trials, fname):
    fig, axs = plt.subplots(nrows, ncols, figsize=(12.8, 7.2), sharey=True)
    for i, ax in enumerate(axs.flat):
        trials[i].plot(ax)
    fig.savefig(fname)
    plt.close(fig)


# load paths
config = configparser.ConfigParser()
config.read('config.ini')

EDA_DIR = config['DEFAULT']['EDA_DIR']
BIDS_ROOT = config['DEFAULT']['BIDS_ROOT']
EDA_DERIV_DIR = config['PHYSIO']['EDA_DERIV_DIR']

eda_scores_dir = os.path.join(EDA_DERIV_DIR, 'peak_to_peak', 'scores')
eda_figures_dir = os.path.join(EDA_DERIV_DIR, 'peak_to_peak', 'figures')

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
        print('Downsampling factor:', ds_factor)
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
        score['group'] = group
    save_scores(scores, code, eda_scores_dir)

    # plot trials
    if not os.path.exists(eda_figures_dir):
        os.makedirs(eda_figures_dir)
    plot_trials(8, 6, trials_ofl,
                fname=os.path.join(eda_figures_dir, code + '_trials_OFL.png'))
    plot_trials(6, 4, trials_de,
                fname=os.path.join(eda_figures_dir, code + '_trials_DE.png'))

# Aggregate all existing files into one dataframe, save it also as feather
subject_files = glob.glob(os.path.join(eda_scores_dir, '?????[A-Z].pickle'))
dataframes = [pandas.read_pickle(f) for f in subject_files]
df_all = pandas.concat(dataframes, ignore_index=True)
pickle_path = os.path.join(eda_scores_dir, 'all_scores.pickle')
feather_path = os.path.join(eda_scores_dir, 'all_scores.feather')
df_all.to_pickle(pickle_path)
df_all.to_feather(feather_path)
