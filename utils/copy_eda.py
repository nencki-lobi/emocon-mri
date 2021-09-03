"""Copy & reorganise skin conductance files

This scripts selects, copies and reorganises raw, imported, trimmed
files and missing epoch files in preparation for the OSF upload. The
same subjects as for fMRI are included in the raw data.

"""


import configparser
import os
import pandas as pd
import re
import shutil
from pathlib import Path


def copy_select(src_folder, dst_folder, pattern, accepted):
    files = os.listdir(src_folder)
    if not os.path.isdir(dst_folder):
        os.makedirs(dst_folder)
    for f in files:
        m = re.search(pattern, f)
        if m is not None:
            if m.group(0) in accepted:
                print("copying", f)
                shutil.copyfile(
                    src_folder / f,
                    dst_folder / f
                    )

# Read config
config = configparser.ConfigParser()
config.read('../config.ini')

## Select subjects included in fMRI analysis

q_dir = Path(config['DEFAULT']['QUESTIONNAIRE_DIR'])
table = pd.read_csv(q_dir / 'table.tsv', sep='\t')

excl = ["Trltdn", "Cgotop", "Plarre", "Nagery"]
subjects = (table
            .query('CONT_contingency == "YES"')
            .query('label not in @excl')
            )

labels = subjects.label.values
labels_upper = [s.upper() for s in labels]

assert len(labels) == 69

## Copy files

label_pat = re.compile('[A-Z]{6}')

raw_dir = Path(config['DEFAULT']['EDA_DIR'])
pspm_root = Path(config['PSPM']['ROOT'])

publish_dir = Path(config['PSPM']['ROOT']).joinpath('osf_copy')

copy_select(raw_dir, publish_dir / 'raw', label_pat, labels_upper)

copy_select(pspm_root / 'scr',
            publish_dir / 'pspm_import_trim',
            label_pat,
            labels_upper)

copy_select(pspm_root / 'missing_epochs_scr',
            publish_dir / 'missing_epochs',
            label_pat,
            labels_upper)

# manually copy the 'empty.mat' file
# manually copy the models directory

# copy_select(pspm_root / 'models_scr_dcm', 'xd', re.compile('[A-Z][a-z]{5}'), labels)
