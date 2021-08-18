"""Copy & rename statistical map files for publishing

This scripts copies statistical maps (spmT) and gives them distinct
names. This should make them easier to publish.
"""

import configparser
import shutil
from pathlib import Path

# Read config
config = configparser.ConfigParser()
config.read('../config.ini')

# Base path - spm analysis directory
base_path = Path(config['SPM']['ROOT']).joinpath('complete')

# Out path - stat_maps folder therein
out_path = base_path / 'stat_maps'
if not out_path.is_dir():
    out_path.mkdir()

# OFL US > noUS
shutil.copyfile(
    base_path/'second_level'/'ofl_basic'/'obsUR_1sample'/'spmT_0001.nii',
    out_path/'ofl_USvsNOUS_1sample.nii'
    )

shutil.copyfile(
    base_path/'second_level'/'ofl_basic'/'obsUR_2sample'/'spmT_0001.nii',
    out_path/'ofl_USvsNOUS_2sample.nii'
    )

# DE CS+ > CS-
shutil.copyfile(
    base_path/'second_level'/'de_basic'/'CR_1sample'/'spmT_0001.nii',
    out_path/'de_CSPvsCSM_1sample.nii'
    )

shutil.copyfile(
    base_path/'second_level'/'de_basic'/'CR_2sample'/'spmT_0001.nii',
    out_path/'de_CSPvsCSM_2sample.nii'
    )

# OFL US only
shutil.copyfile(
    base_path/'second_level'/'ofl_extra'/'us_only_2sample'/'spmT_0001.nii',
    out_path/'ofl_USstick_2sample.nii'
    )

# DE CS+ x time decrease
shutil.copyfile(
    base_path/'second_level'/'de_extra'/'tmod_1sample'/'spmT_0001.nii',
    out_path/'de_CSPxTimeDecrease_1sample.nii'
    )  # 'TimeDecrease' b/c 1st lvl weight was 1, 2nd level weight was -1

shutil.copyfile(
    base_path/'second_level'/'de_extra'/'tmod_2sample'/'spmT_0001.nii',
    out_path/'de_CSPxTime_2sample.nii'
    )  # 'Time' b/c 1st level weight was 1, 2nd level weight was [1 -1]

# PPI OFL

rois = ['AI', 'rpSTS', 'aMCC', 'amygdala', 'FFA', 'rTPJ']

for roi in rois:
    ppi = 'PPI_ofl_{}xUS'.format(roi)
    shutil.copyfile(
        base_path/'ppi_group'/ppi/'1_sample'/'spmT_0001.nii',
        out_path/(ppi+'_1sample.nii')
    )
    shutil.copyfile(
        base_path/'ppi_group'/ppi/'2_sample'/'spmT_0001.nii',
        out_path/(ppi+'_2sample.nii')
    )
