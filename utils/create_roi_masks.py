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

# fetch subcortical atlas
dataset = datasets.fetch_atlas_harvard_oxford('sub-maxprob-thr25-2mm')
atlas_filename = dataset.maps
labels = dataset.labels

atlas = image.load_img(atlas_filename)
atlas_data = atlas.get_data()

# create bilateral amygdala mask
mask_data = np.zeros(atlas_data.shape, dtype=np.int32)
mask_data[atlas_data == labels.index('Left Amygdala')] = 1
mask_data[atlas_data == labels.index('Right Amygdala')] = 1

mask_amy = image.new_img_like(atlas, mask_data)
mask_amy.to_filename(str(outdir.joinpath('amy_bilateral.nii')))

if args.plot:
    plotting.plot_roi(mask_amy)
    plt.show()
