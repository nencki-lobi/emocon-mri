""" Create ROI masks based on the Harvard - Oxford atlas

Creates a bilateral mask for the Amygdala, by thresholding the atlas
at 70 % (matching Lindstrom, Haaker & Olsson, Neuroimage 2018).

Many other masks are created from within Matlab, using the script in
spm/complete/roi/prepare_roi.m
"""

import argparse
import configparser
import numpy as np
from matplotlib import pyplot as plt
from nilearn import datasets, image, plotting
from pathlib import Path


parser = argparse.ArgumentParser()
parser.add_argument('-p', '--plot', action='store_true',
                    help='Display plots')
args = parser.parse_args()

# output directory
config = configparser.ConfigParser()
config.read('config.ini')
outdir = Path(config['SPM']['ROOT']).joinpath('roi')
if not outdir.is_dir():
    outdir.mkdir(parents=True)

# fetch subcortical atlas - probabilistic version
dataset = datasets.fetch_atlas_harvard_oxford('sub-prob-2mm')
atlas_filename = dataset.maps
labels = dataset.labels

atlas = image.load_img(atlas_filename)
atlas_data = atlas.get_fdata()

# create bilateral amygdala mask
mask_data = np.zeros(atlas_data.shape[:-1], dtype=np.int32)
where_left = atlas_data[:, :, :, labels.index('Left Amygdala') - 1] > 70
where_right = atlas_data[:, :, :, labels.index('Right Amygdala') - 1] > 70
# thresholding at 70 % to match Lindstrom, Haaker & Olsson Neuroimage 2018
# -1 because 'Background' label does not have a corresponding image
mask_data[where_left] = 1
mask_data[where_right] = 1

mask_amy = image.new_img_like(atlas, mask_data)
mask_amy.to_filename(str(outdir.joinpath('amy_bilateral.nii')))

if args.plot:
    plotting.plot_roi(mask_amy)
    plt.show()
