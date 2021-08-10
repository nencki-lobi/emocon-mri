import gl
import os
import sys

# Path constants - wasn't able to work with the config file
RESULT_DIR = '/Volumes/MyBookPro/emocon_mri/spm/complete/second_level'
FIGURE_DIR = '/Users/michal/Documents/emocon_mri_study/stats/figures/mricroGL'

# Path to the result
result_file = os.path.join(RESULT_DIR, 'de_basic', 'CR_1sample',
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
gl.minmax(1, 5.40, 8.30)  # layer (0=bg), min, max
gl.opacity(1, 70)

# Remove the colorbar
gl.colorbarposition(0)

# Set background to white & remove crosshair
gl.backcolor(255, 255, 255)
gl.linewidth(0)

# Select crossection
gl.orthoviewmm(4, 26, -4)

# Show axial view
gl.view(1)

# Save
gl.savebmp(os.path.join(FIGURE_DIR, 'de_axial.png'))

# Re-enable colorbar
gl.colorbarposition(2)
