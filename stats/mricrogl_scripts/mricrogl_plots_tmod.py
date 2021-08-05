import gl
import os
import sys

# Path constants - wasn't able to work with the config file
RESULT_DIR = '/Volumes/MyBookPro/emocon_mri/spm/complete/second_level'
FIGURE_DIR = '/Users/michal/Documents/emocon_mri_study/stats/figures/mricroGL'

# Create figure output directory
if not os.path.isdir(FIGURE_DIR):
    os.makedirs(FIGURE_DIR)

# Reset defaults
gl.resetdefaults()

#open background image
gl.loadimage('mni152')

# Remove the colorbar
gl.colorbarposition(0)

# Set background to white & remove crosshair
gl.backcolor(255, 255, 255)
gl.linewidth(0)

# 1 sample t test
result_file = os.path.join(RESULT_DIR, 'de_extra', 'tmod_1sample',
                           'spmT_0001_thr_cluster.nii')

gl.overlayload(result_file)
gl.colorname(1, '4hot')
gl.minmax(1, 3.21, 5.83)
gl.opacity(1, 70)

gl.orthoviewmm(3.5, 0, 0)

gl.view(4)
gl.savebmp(os.path.join(FIGURE_DIR, 'tmod_1.png'))

gl.overlaycloseall()

# 2 sample t test
result_file = os.path.join(RESULT_DIR, 'de_extra', 'tmod_2sample',
                           'spmT_0001_thr_cluster.nii')

gl.overlayload(result_file)
gl.colorname(1, '4hot')
gl.minmax(1, 3.21, 6.38)
gl.opacity(1, 70)

gl.orthoviewmm(0, 0, 10)
gl.view(1)
gl.savebmp(os.path.join(FIGURE_DIR, 'tmod_2.png'))

gl.orthoviewmm(0, 0, -2)
gl.view(1)
gl.savebmp(os.path.join(FIGURE_DIR, 'tmod_3.png'))
