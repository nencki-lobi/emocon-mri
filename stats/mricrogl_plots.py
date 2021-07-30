""" MRIcroGL script to generate crossections

Needs to be run with mricrogl, not regular python, e.g.:
/Applications/MRIcroGL.app/Contents/MacOS/MRIcroGL script.py
"""

import gl
import os
import sys

# Path constants - wasn't able to work with the config file
RESULT_DIR = '/Volumes/MyBookPro/emocon_mri/spm/complete/second_level'
FIGURE_DIR = '/Users/michal/Documents/emocon_mri_study/stats/figures/mricroGL'

# Path to the result
result_file = os.path.join(RESULT_DIR, 'ofl_basic', 'obsUR_1sample', 'spmT_0001.nii')

# Create figure output directory
if not os.path.isdir(FIGURE_DIR):
    os.makedirs(FIGURE_DIR)

# Reset defaults
gl.resetdefaults()

#open background image
gl.loadimage('mni152')

#open overlay and set scale range
gl.overlayload(result_file)
gl.minmax(1, 5.4, 15)  # layer (0=bg), min, max

# Set background to white & remove crosshair
gl.backcolor(255, 255, 255)
gl.linewidth(0)

# Select crossection
gl.orthoviewmm(0, 0, -2) # must set all three

# Show a single view, 1-axial, 2-coronal, 4-sagittal
gl.view(1)

# Save the image
gl.savebmp(os.path.join(FIGURE_DIR, 'axial1.png'))

# The next views:

# temporal sulcus
gl.orthoviewmm(52, 0, 0)
gl.view(4)
gl.savebmp(os.path.join(FIGURE_DIR, 'sagittal1.png'))

# fusiform
gl.orthoviewmm(0, 0, -16)
gl.view(1)
gl.savebmp(os.path.join(FIGURE_DIR, 'axial2.png'))

# cingulate
gl.orthoviewmm(4.6, 0, 0)
gl.view(4)
gl.savebmp(os.path.join(FIGURE_DIR, 'sagittal2.png'))

# amygdala
gl.orthoviewmm(0, -4, 0)
gl.view(2)
gl.savebmp(os.path.join(FIGURE_DIR, 'coronal1.png'))


# Some useful things
# gl.mosaic("A L+ H -0.1 -24 -16 16 40; 48 56 S X R 0");
# view(v) -> Display Axial (1), Coronal (2), Sagittal (4), Flipped Sagittal (8), MPR (16), Mosaic (32) or Rendering (64)
# removesmallclusters()
# overlaycloseall()
