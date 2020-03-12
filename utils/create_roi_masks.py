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


# fetch cortical atlas
dataset = datasets.fetch_atlas_harvard_oxford('cort-maxprob-thr25-2mm')

cort_labels = dataset.labels
cort_atlas = image.load_img(dataset.maps)
cort_atlas_data = cort_atlas.get_data()

# create bilateral insula mask
mask_data = np.zeros(atlas_data.shape, dtype=np.int32)
mask_data[cort_atlas_data == cort_labels.index('Insular Cortex')] = 1

mask_insula = image.new_img_like(atlas, mask_data)
mask_insula.to_filename(str(outdir.joinpath('insula_bilateral.nii')))

if args.plot:
    plotting.plot_roi(mask_insula)
    plt.show()

# fetch Destrieux atlas
dataset = datasets.fetch_atlas_destrieux_2009()
destrieux_labels = dataset.labels
destrieux_atlas = image.load_img(dataset.maps)
destrieux_atlas_data = destrieux_atlas.get_fdata()

# create anterior insula mask from Destrieux atlas
# this atlas keeps labels in numpy recarray and uses bytes literals
arr_idx = np.where(destrieux_labels.name == b'R S_circular_insula_ant')[0][0]
img_idx = destrieux_labels.index[arr_idx]

mask_data = np.zeros(destrieux_atlas_data.shape)
mask_data[destrieux_atlas_data == img_idx] = 1

mask_ains = image.new_img_like(destrieux_atlas, mask_data)
mask_ains.to_filename(str(outdir.joinpath('R_S_circular_insula_ant')))
