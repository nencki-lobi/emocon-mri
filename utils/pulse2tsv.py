import argparse
import configparser
import glob
import os
import json
import numpy as np
import pydicom
import re
from bids import BIDSLayout
from itertools import islice


def dicomtime2sec(t):
    h = int(t[:2])
    m = int(t[2:4])
    s = int(t[4:6])
    tics = int(t[7:11])

    return(h * 3600 + m * 60 + s + tics * 0.0001)


def pulsetime2sec(t):
    return(int(t) * 0.001)


def load_pulse(file_name):
    # load data
    data = np.loadtxt(file_name, max_rows=1)
    data = data[4:]  # drop parameters stored at the beginning
    data = data[np.where(data < 5000)]  # drop markers

    # load metadata
    meta = {}
    with open(file_name) as f:
        for line in islice(f, 1, None):
            try:
                k, v = line.split(':')
                meta[k.strip()] = v.strip()
            except ValueError:
                # don't care about entries with one item
                pass

    return data, meta


def create_for_one(dicom_file, pulse_file):
    ds = pydicom.dcmread(dicom_file)
    pdata, pmeta = load_pulse(pulse_file)

    dicom_sec = dicomtime2sec(ds.AcquisitionTime)  # 0008, 0032
    pulse_sec = pulsetime2sec(pmeta['LogStartMPCUTime'])

    time_delta = pulse_sec - dicom_sec

    info = {
        'SamplingFrequency': 50,
        'StartTime': np.round(time_delta, 3),
        'Columns': ['cardiac'],
    }

    return pdata, info


def create_for_two(s1_dicom_start, s1_dicom_end, s2_dicom_start, pulse_file):
    fs = 50

    dicom_filenames = [s1_dicom_start, s1_dicom_end, s2_dicom_start]
    ds_list = [pydicom.dcmread(f) for f in dicom_filenames]
    dicom_seconds = [dicomtime2sec(ds.AcquisitionTime) for ds in ds_list]

    pdata, pmeta = load_pulse(pulse_file)
    pulse_seconds = pulsetime2sec(pmeta['LogStartMPCUTime'])

    # I want to split the recording at midpoint between the scans
    midpoint_seconds = (dicom_seconds[1] + dicom_seconds[2]) / 2
    break_samples = int(np.floor((midpoint_seconds - dicom_seconds[0]) * fs))
    # adjust to 1st sample after break
    midpoint_seconds = dicom_seconds[0] + break_samples / fs

    time_deltas = [
        pulse_seconds - dicom_seconds[0],
        midpoint_seconds - dicom_seconds[2],
        ]

    pdata_list = np.split(pdata, [break_samples])
    info_list = []

    for i in range(2):

        info_list.append(
            {
                'SamplingFrequency': fs,
                'StartTime': np.round(time_deltas[i], 3),
                'Columns': ['cardiac'],
            })

    return pdata_list[0], info_list[0], pdata_list[1], info_list[1]


def save_pulse(data, info, layout, subject, task):
    tsv_file = layout.build_path({
        'subject': subject,
        'task': task,
        'suffix': 'physio',
        'extension': 'tsv.gz',
        })
    json_file = layout.build_path({
        'subject': subject,
        'task': task,
        'suffix': 'physio',
        'extension': 'json',
        })

    np.savetxt(os.path.join(layout.root, tsv_file), data, fmt='%g')
    print('Written', tsv_file)

    with open(os.path.join(layout.root, json_file), 'w') as jfile:
        json.dump(info, jfile, indent=3)
        print('Written', json_file)


def get_volume_number(fname):
    """Get volume number from xnat dicom file name"""
    pat = re.compile('[0-9.]*-[0-9]+-([0-9]+)-[0-9a-z]*.dcm')
    try:
        n = int(re.match(pat, fname).group(1))
    except AttributeError as ae:
        print('!', fname)
        raise ae
    return n


def list_subdirs(parent_dir):
    subdirs = []
    for elem in os.listdir(parent_dir):
        if os.path.isdir(os.path.join(parent_dir, elem)):
            subdirs.append(elem)
    return subdirs


def get_dicom_files(dicom_root, code, task, return_last=False):
    subject_folder = os.path.join(dicom_root, 'Ec_{}'.format(code))
    session_id = list_subdirs(subject_folder)[0]

    if session_id.startswith('Head'):
        # Head_12ch_Emocon - 1
        return get_horos_dicoms(dicom_root, code, task, return_last)
    elif session_id.startswith('20'):
        # 20190903_....
        return get_xnat_dicoms(dicom_root, code, task, return_last)
    else:
        raise RuntimeWarning('Can not decide if Horos or Xnat')


def get_horos_dicoms(dicom_root, code, task, return_last=False):
    """Get first, or first & last dicom for a given series"""
    task_folders = glob.glob(os.path.join(
        dicom_root, 'Ec_{}'.format(code), '*', 'task{}*'.format(task),
        ))
    if len(task_folders) == 1:
        task_folder = task_folders[0]
    else:
        raise RuntimeError(
            'Found {} occurrences of task {}'.format(len(task_folders), task)
            )

    files = sorted(os.listdir(task_folder))

    if return_last:
        first = os.path.join(task_folder, files[0])
        last = os.path.join(task_folder, files[-1])
        return first, last
    else:
        first = os.path.join(task_folder, files[0])
        return first


def get_xnat_dicoms(dicom_root, code, task, return_last=False):
    """Get file names for a given code / task
    Task names are looked up in dicoms and the order is taken from filenames.
    Could as well extract times, but kept this way for compatibility.
    """
    mydict = {}
    subject_folder = os.path.join(dicom_root, 'Ec_{}'.format(code))
    session_id = list_subdirs(subject_folder)[0]  # assuming just one
    series_ids = list_subdirs(os.path.join(subject_folder, session_id))
    for series_id in series_ids:
        s_dir = os.path.join(subject_folder, session_id, series_id, 'DICOM')
        series_files = sorted(os.listdir(s_dir), key=get_volume_number)
        first = os.path.join(s_dir, series_files[0])
        last = os.path.join(s_dir, series_files[-1])
        ds = pydicom.dcmread(first)
        desc = ds.SeriesDescription
        try:
            current_task = re.match('task-([a-zA-Z]+)', desc).group(1)
        except AttributeError:
            continue
        if current_task not in mydict:
            mydict[current_task] = (first, last)
        else:
            raise RuntimeError(
                'Found multiple occurrences of task {}'.format(current_task)
                )

    first, last = mydict[task]
    if return_last:
        return first, last
    else:
        return first


def get_pulse_files(pulse_root, code):
    """Get one or two pulse files for a given subject"""
    ofl = os.path.join(pulse_root, 'EC_{}_ofl.puls').format(code)
    de = os.path.join(pulse_root, 'EC_{}_de.puls').format(code)
    both = os.path.join(pulse_root, 'EC_{}.puls').format(code)
    if os.path.isfile(ofl) and os.path.isfile(de):
        return ofl, de
    elif os.path.isfile(both):
        return (both,)
    elif os.path.isfile(ofl):
        return ofl, None  # ofl, but not de, file present
    elif os.path.isfile(de):
        return None, de  # de, but not ofl, file present
    else:
        raise RuntimeError('Can not find pulse for subject {}', code)


def capitalise(s):
    return s[0].upper() + s[1:].lower()


def fix_zrzxcw(dicom_root, pulse_dir, layout):
    """Let me tell you about the time we saved two subjects in one file..."""

    zrzxcw_dicoms = get_dicom_files(dicom_root, 'Zrzxcw', 'de', True)
    zrzxcw_ds = [pydicom.dcmread(f) for f in zrzxcw_dicoms]
    zrzxcw_times = [dicomtime2sec(ds.AcquisitionTime) for ds in zrzxcw_ds]

    krulak_dicoms = get_dicom_files(dicom_root, 'Krulak', 'ofl', True)
    krulak_ds = [pydicom.dcmread(f) for f in krulak_dicoms]
    krulak_times = [dicomtime2sec(ds.AcquisitionTime) for ds in krulak_ds]

    pulse_f = get_pulse_files(pulse_dir, 'ZRZXCW')

    # nothing wrong with OFL, save normally
    zrzxcw_ofl_dicom = get_dicom_files(dicom_root, 'Zrzxcw', 'ofl', False)
    pdata, info = create_for_one(zrzxcw_ofl_dicom, pulse_f[0])
    save_pulse(pdata, info, layout, 'Zrzxcw', 'ofl')

    # calculate start / end times relative to DE pulse
    added_seconds = 10  # take additional 10 seconds at start / end
    pdata, pmeta = load_pulse(pulse_f[1])
    pulse_start = pulsetime2sec(pmeta['LogStartMPCUTime'])
    zrzxcw_end = zrzxcw_times[1] - pulse_start + added_seconds
    krulak_start = krulak_times[0] - pulse_start - added_seconds
    krulak_end = krulak_times[1] - pulse_start + added_seconds
    fs = 50

    # load pulse data (will be trimmed) & create info for DE
    pdata, info = create_for_one(zrzxcw_dicoms[0], pulse_f[1])

    # save DE - trim only at the end, so start time is not changed
    pdata_zrzxcw = pdata[:int(zrzxcw_end * fs)]
    save_pulse(pdata_zrzxcw, info, layout, 'Zrzxcw', 'de')

    # save next subject's OFL
    pdata_krulak = pdata[int(krulak_start * fs): int(krulak_end * fs)]
    info['StartTime'] = -added_seconds
    save_pulse(pdata_krulak, info, layout, 'Krulak', 'ofl')


config = configparser.ConfigParser()
config.read('config.ini')

DICOM_DIR = config['DEFAULT']['DICOM_DIR']
PULSE_DIR = config['DEFAULT']['PULSE_DIR']
BIDS_ROOT = config['DEFAULT']['BIDS_ROOT']

parser = argparse.ArgumentParser()
parser.add_argument('participant_label', nargs='+')
args = parser.parse_args()

layout = BIDSLayout(BIDS_ROOT, validate=False)

for code in args.participant_label:

    if capitalise(code) == 'Zrzxcw':
        # special case
        fix_zrzxcw(DICOM_DIR, PULSE_DIR, layout)
        continue

    pulse_f = get_pulse_files(PULSE_DIR, code.upper())

    if len(pulse_f) == 2:
        for i, task_name in enumerate(['ofl', 'de']):
            pulse_file = pulse_f[i]
            if pulse_file is None:
                print(code, task_name, 'file not present')
                continue
            dicom_file = get_dicom_files(DICOM_DIR, capitalise(code),
                                         task_name)
            pdata, info = create_for_one(dicom_file, pulse_file)
            save_pulse(pdata, info, layout, capitalise(code), task_name)
    else:
        first_ofl, last_ofl = get_dicom_files(DICOM_DIR, capitalise(code),
                                              'ofl', return_last=True)
        first_de = get_dicom_files(DICOM_DIR, capitalise(code), 'de')
        pdata_ofl, info_ofl, pdata_de, info_de = create_for_two(
            first_ofl, last_ofl, first_de, pulse_f[0]
            )
        save_pulse(pdata_ofl, info_ofl, layout, capitalise(code), 'ofl')
        save_pulse(pdata_de, info_de, layout, capitalise(code), 'de')
