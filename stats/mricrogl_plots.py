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
result_file = os.path.join(RESULT_DIR, 'ofl_basic', 'obsUR_1sample',
                           'spmT_0001_thresholded.nii')

# Create figure output directory
if not os.path.isdir(FIGURE_DIR):
    os.makedirs(FIGURE_DIR)

# Reset defaults
gl.resetdefaults()

#open background image
gl.loadimage('mni152')

#open overlay and set scale range
gl.overlayload(result_file)
gl.colorname(1, '4hot')
gl.minmax(1, 5.42, 15)  # layer (0=bg), min, max
gl.opacity(1, 70)

# Remove the colorbar
gl.colorbarposition(0)

# Set background to white & remove crosshair
gl.backcolor(255, 255, 255)
gl.linewidth(0)

# Select crossection (this one is through the insula)
gl.orthoviewmm(0, 0, -2) # must set all three

 # Show a single view, 1-axial, 2-coronal, 4-sagittal
gl.view(1)

# Save the image
gl.savebmp(os.path.join(FIGURE_DIR, 'axial1.png'))

# The next views:

# fusiform
gl.orthoviewmm(0, 0, -16)
gl.view(1)
gl.savebmp(os.path.join(FIGURE_DIR, 'axial2.png'))

# amygdala
gl.orthoviewmm(0, -4, 0)
gl.view(2)
gl.savebmp(os.path.join(FIGURE_DIR, 'coronal1.png'))

# cingulate
gl.orthoviewmm(3.5, 0, 0)
gl.view(4)
gl.savebmp(os.path.join(FIGURE_DIR, 'sagittal1.png'))

# temporal sulcus
gl.orthoviewmm(52, 0, 0)
gl.view(4)
gl.savebmp(os.path.join(FIGURE_DIR, 'sagittal2.png'))

# Enable colorbar
gl.colorbarposition(1)

# Colorbar background cannot (?) be changed, so this will have to be
# done manually

# Some useful things
# gl.mosaic("A L+ H -0.1 -24 -16 16 40; 48 56 S X R 0");
# view(v) -> Display Axial (1), Coronal (2), Sagittal (4), Flipped Sagittal (8), MPR (16), Mosaic (32) or Rendering (64)
# removesmallclusters()
# overlaycloseall()
