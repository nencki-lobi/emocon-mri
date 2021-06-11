"""Create activation plots

This script creates figures displaying statistical maps for the main
contrasts of interest:
  - observation: US > noUS (pooled)
  - direct: CS+ > CS-

The input files are taken from the spm second level output
directory. FWE thresholds were taken from SPM results. Cross-sections
were selected so that resulting images are maximally informative while
still being concise.

Figures are saved in the 'figures' directory in the workdir.
"""

from nilearn import image, plotting
from matplotlib import pyplot as plt
from matplotlib import rc
import configparser
import numpy as np
import os
import seaborn as sns

# Config and paths
config = configparser.ConfigParser()
config.read('../config.ini')

sl_dir = os.path.join(config['SPM']['ROOT'], 'complete', 'second_level')

# Decide on fonts and colors
rc('font', size=8)  # affects colorbars, not annotations
my_cm = sns.color_palette("icefire", as_cmap = True)

# Load the obs learning image and clip it to keep positive values
orig_map = image.load_img(os.path.join(
    sl_dir, 'ofl_basic', 'obsUR_1sample', 'spmT_0001.nii'))
obs_map = image.new_img_like(orig_map, np.clip(orig_map.get_fdata(), 0, None))

# Do the same for the direct expression
orig_map = image.load_img(os.path.join(
    sl_dir, 'de_basic', 'CR_1sample', 'spmT_0001.nii'))
de_map = image.new_img_like(orig_map, np.clip(orig_map.get_fdata(), 0, None))

# Thresholds - from SPM
obs_fwe = 5.424
de_fwe = 5.40

# FIGURE 1 - observational learning

# Slices to be displayed
cuts = [-52, -42, -20, -4, 4, 20, 42, 52]

# Create an empty figure
fig1 = plt.figure(figsize=(8, 3.5), dpi=300)

# Bottom row (stat_map)
sm1 = plotting.plot_stat_map(
    stat_map_img = obs_map,
    threshold = obs_fwe,
    display_mode = 'x',
    cut_coords = cuts[:4],
    annotate = False,
    figure = fig1,
    axes = (0, 0.51, 0.75, 0.48),
    cmap = my_cm,
    colorbar = False,
)

# Top row (stat map)
sm2 = plotting.plot_stat_map(
    stat_map_img = obs_map,
    threshold = obs_fwe,
    display_mode = 'x',
    cut_coords = cuts[4:],
    annotate = False,
    figure = fig1,
    axes = (0, 0, 0.75, 0.48),
    cmap = my_cm,
    colorbar = False,
)

# Add annotations with slice position to both rows
sm1.annotate(left_right=False, positions=True, size=8)
sm2.annotate(left_right=False, positions=True, size=8)

# Right side, axial slice on which cut coordinates will be shown
cc = plotting.plot_stat_map(
    stat_map_img = obs_map,
    threshold = obs_fwe,
    display_mode = 'z',
    cut_coords = [-14],
    figure = fig1,
    axes = (0.8, 0.25, 0.2, 0.48),
    cmap = my_cm,
    colorbar = True,
    annotate = False,
)

# Draw lines showing cut coordinates
cc.annotate(left_right=False, positions=True, size=8)
bounds = cc.axes[-14].get_object_bounds()
cc.axes[-14].ax.vlines(x=cuts, ymin=bounds[2], ymax=bounds[3], color='black',
                       alpha=0.5)

# Add 'T-values' above the colorbar (alt. use annotate with different syntax)
cc.frame_axes.text(
    x = 0.98,
    y = 1.02,
    s = 'T-values',
    horizontalalignment = 'right',
    verticalalignment = 'bottom',
    transform = cc.frame_axes.transAxes
)

# Save the figure
path_fig1 = os.path.join('figures', 'stat_maps_ofl.png')
fig1.savefig(path_fig1)
print('Saved', path_fig1)


# FIGURE 2 - direct expression

# Create empty figure, 5.9 in = 150 mm = 1.75 column width
fig2 = plt.figure(figsize=(5.9, 1.75), dpi = 300)

# Plot stat map - this time in a typical xyz mode
sm3 = plotting.plot_stat_map(
    stat_map_img = de_map,
    threshold = de_fwe,
    cut_coords = [4, 26, -2],
    draw_cross = False,
    cmap = my_cm,
    figure = fig2,
    annotate = False,
)

# Add annotations with slice positions
sm3.annotate(left_right=False, positions=True, size=8)

# Add 'T-values' next to the colorbar
sm3.frame_axes.text(
    x = 0.92,  # 1.0
    y = 0.98,  # 1.02
    s = 'T-values',
    horizontalalignment = 'right',
    verticalalignment = 'top',
    transform = sm3.frame_axes.transAxes,
)

# Save the figure
path_fig2 = os.path.join('figures', 'stat_maps_de.png')
fig2.savefig(path_fig2)
print('Saved', path_fig2)