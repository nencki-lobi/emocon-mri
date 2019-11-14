"""
This scripts unpacks all the brain masks produced by fmriprep
(from .nii.gz to .nii) and places them in a designated directory
for easy use with SPM.
Original .nii.gz files are left untouched.
"""

import gzip
import shutil
import configparser
from bids import BIDSLayout
from pathlib import Path

config = configparser.ConfigParser()
config.read('config.ini')
DERIV_DIR = config['DEFAULT']['DERIV_DIR']

# query the masks
layout = BIDSLayout(Path(DERIV_DIR).joinpath('fmriprep'), validate=False,
                    absolute_paths=True)
all_masks = layout.get(datatype='func', extension='nii.gz', suffix='mask')

# choose a place to put uncompressed masks
out_dir = Path(config['SPM']['ROOT']).joinpath('brain_masks')

# uncompress all masks (if not uncompressed already)
for mask in all_masks:
    subject = mask.entities['subject']
    uncompressed_fname = mask.filename.replace('.nii.gz', '.nii')

    target_folder = out_dir.joinpath('sub-' + subject)
    target_file = target_folder.joinpath(uncompressed_fname)

    # create subject's folder if does not already exist
    if not target_folder.is_dir():
        target_folder.mkdir(parents=True)

    # unpack / copy the file if does not already exist
    if not target_file.is_file():
        with gzip.open(mask.path, 'rb') as f_in:
            with target_file.open('wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
