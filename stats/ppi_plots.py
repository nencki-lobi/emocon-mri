"""Create brain plots with PPI results

This script creates a figure displaying statistical maps for PPI
analysis (observational learning stage; ACC and rpSTS seeds).

The statistical maps are taken from the spm second level output
directory. Mask for amygdala SVC is created in
utils/create_roi_mask.py and is taken from the Harvard - Oxford atlas,
thresholded at 70 %.

Cluster and small volume thresholding are all performed in this
script. Cluster size thresholds were calculated externally using the
CorrClusTh.m function by T.Nichols & M.Wilke (note that this function
returns the actual threshold, while SPM displays the size of the first
cluster above that threshold, so the end result is the same although
values differ). SVC t-threshold was taken from SPM GUI (for voxel-wise
thresholding within the small volume).

Resulting figure is saved in the 'figures' directory in the workdir.
"""

from nilearn import image, plotting, regions
from matplotlib import pyplot as plt
from matplotlib import rc
import configparser
import numpy as np
import os
import seaborn as sns

# Config and paths
config = configparser.ConfigParser()
config.read('../config.ini')

sl_dir = os.path.join(config['SPM']['ROOT'], 'complete', 'ppi_group')

# Decide on fonts and colors
rc('font', size=8)  # affects colorbars, not annotations
my_cm = sns.color_palette("icefire", as_cmap = True)

# Load images and clip them keeping positive values
ai_orig = image.load_img(os.path.join(
    sl_dir, 'PPI_ofl_AIxUS', '1_sample', 'spmT_0001.nii'))
ai_map = image.new_img_like(ai_orig, np.clip(ai_orig.get_fdata(), 0, None))

sts_orig = image.load_img(os.path.join(
    sl_dir, 'PPI_ofl_rpSTSxUS', '1_sample', 'spmT_0001.nii'))
sts_map = image.new_img_like(sts_orig, np.clip(sts_orig.get_fdata(), 0, None))

# Load amygdala mask (Harvard-Oxford @ 70 %) for SVC
amy_mask = image.load_img(
    os.path.join(config['SPM']['ROOT'], 'roi', 'amy_bilateral.nii'))

# AI PPI - do cluster thresholding
ai_map_thr = image.threshold_img(ai_map, threshold=3.21)  # CDT
ai_cluster_extent = 86
ai_cluster_vol = ai_cluster_extent * np.prod(ai_map_thr.header.get_zooms())

ai_clusters_4d = regions.connected_regions(
    ai_map_thr,
    min_region_size = ai_cluster_vol,
    extract_type = 'connected_components')[0]
ai_map_clustth = image.math_img('np.sum(img, axis=-1)', img=ai_clusters_4d)

# pSTS PPI - do cluster thresholding
sts_map_thr = image.threshold_img(sts_map, threshold = 3.21)  # CDT
sts_cluster_extent = 86
sts_cluster_vol = sts_cluster_extent * np.prod(sts_map_thr.header.get_zooms())

sts_clusters_4d = regions.connected_regions(
    sts_map_thr,
    min_region_size = sts_cluster_vol,
    extract_type = 'connected_components')[0]
sts_map_clustth = image.math_img('np.sum(img, axis=-1)', img=sts_clusters_4d)

# pSTs PPI - do small volume masking / thresholding
amy_mask_r = image.resample_to_img(amy_mask, sts_map, interpolation='nearest')
sts_map_svc = image.new_img_like(
    ref_niimg = sts_map,
    data = amy_mask_r.get_fdata() * sts_map.get_fdata())

## Build the plots

fig = plt.figure(figsize=(8, 1.75), dpi = 300)
unit_width = 1/5  # this much figure width per brain

# AI PPI, showing the pSTS
sm1 = plotting.plot_stat_map(
    stat_map_img = ai_map_clustth,
    cmap = my_cm,
    threshold = 3.21,
    cut_coords=[52, -40],
    display_mode='yx',
    draw_cross=False,
    annotate=False,
    figure = fig,
    axes = (0, 0, 1.8*unit_width, 1),
)

# pSTS PPI, showing Fusiform & AI
sm2 = plotting.plot_stat_map(
    stat_map_img = sts_map_clustth,
    cmap = my_cm,
    threshold = 3.21,
    cut_coords = [-16, 0],
    display_mode = 'z',
    draw_cross = False,
    annotate = False,
    figure = fig,
    axes = (2*unit_width, 0, 1.8*unit_width, 1),
)

# pSTS PPI, small volume corrected
sm3 = plotting.plot_stat_map(
    stat_map_img = sts_map_svc,
    cmap = 'Reds',      # for better visibility, range is different
    threshold = 3.417,  # FWE threshold for SVC
    cut_coords = [-4],
    display_mode = 'y',
    draw_cross = False,
    annotate = False,
    figure = fig,
    axes = (4*unit_width, 0, unit_width, 1),
)

# Add annotations, colorbar labels and panel labels

for sm, xcoord, label in zip([sm1, sm2, sm3],
                             [0.85, 0.85, 0.72],
                             ['A', 'B', 'C']):

    # Annotations
    sm.annotate(left_right=False, positions=True, size=8)

    # 'T-values' colorbar label
    sm.frame_axes.text(
        x = xcoord,
        y = .98,
        s = 'T-values',
        horizontalalignment = 'right',
        verticalalignment = 'top',
        transform = sm.frame_axes.transAxes,
    )

    # Panel label (A, B, C)
    sm.frame_axes.text(
        x = 0,
        y = .98,
        s = label,
        horizontalalignment = 'left',
        verticalalignment = 'top',
        transform = sm.frame_axes.transAxes,
        size = 10,
        weight = 'bold',
    )

path_fig = os.path.join('figures', 'stat_maps_ppi.png')
fig.savefig(path_fig)
print('Saved', path_fig)
