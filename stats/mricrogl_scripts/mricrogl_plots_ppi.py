import gl
import os
import sys

# Path constants - wasn't able to work with the config file
RESULT_DIR = '/Volumes/MyBookPro/emocon_mri/spm/complete/ppi_group'
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

# Anterior insula PPI
# Path to the result
result_file = os.path.join(RESULT_DIR, 'ppi_ofl_AIxUS', '1_sample',
                           'spmT_0001_thr_cluster.nii')

# open overlay and set scale range
gl.overlayload(result_file)
gl.colorname(1, '4hot')
gl.minmax(1, 3.21, 6.2)
gl.opacity(1, 70)

# Select xy location
gl.orthoviewmm(50, -40, 0)

# Save coronal view
gl.view(2)
gl.savebmp(os.path.join(FIGURE_DIR, 'ppi_1.png'))

# Save sagittal view
gl.view(4)
gl.savebmp(os.path.join(FIGURE_DIR, 'ppi_2.png'))

gl.overlaycloseall()

# Right pSTS PPI
result_file = os.path.join(RESULT_DIR, 'ppi_ofl_rpSTSxUS', '1_sample',
                           'spmT_0001_thr_cluster.nii')

gl.overlayload(result_file)
gl.colorname(1, '4hot')
gl.minmax(1, 3.21, 9.3)
gl.opacity(1, 70)

gl.orthoviewmm(0, 0, 0)
gl.view(1)
gl.savebmp(os.path.join(FIGURE_DIR, 'ppi_3.png'))

gl.orthoviewmm(0, 0, -16)
gl.view(1)
gl.savebmp(os.path.join(FIGURE_DIR, 'ppi_4.png'))

gl.overlaycloseall()

# Right pSTS PPI SVC
result_file = os.path.join(RESULT_DIR, 'ppi_ofl_rpSTSxUS', '1_sample',
                           'spmT_0001_thr_svc.nii')

gl.overlayload(result_file)
gl.colorname(1, '4hot')
gl.minmax(1, 3.41, 3.8)
gl.opacity(1, 70)

gl.orthoviewmm(0, -4.5, 0)
gl.view(2)
gl.savebmp(os.path.join(FIGURE_DIR, 'ppi_5.png'))
