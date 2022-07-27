"""This script applies the signature of pain from Zhou et al 2020
(https://doi.org/10.7554/eLife.56929)
and the visually induced fear signature from Zhou et al 2021
(https://doi.org/10.1101/2020.11.23.394973)
to the 1st level results from the current study.
"""

import configparser
import numpy as np
import pandas as pd
from nilearn import image, input_data
from pathlib import Path

# load paths from a local config file
config = configparser.ConfigParser()
config.read('config.ini')

osf_data = Path(config['extras']['osf_data'])  # /home/mszczepanik/data/emocon
pain_dir = Path(config['extras']['signature_of_pain'])
fear_dir = Path(config['extras']['signature_of_fear'])
out_dir = Path(config['extras']['multivariate_output'])

# make a list of images to analyse
ofl_dir = osf_data / 'fMRI' / '1st_level' / 'observational fear learning/'

subdir_list = [p for p in ofl_dir.iterdir() if p.is_dir()]
spm_paths = [str(d / 'con_0005.nii') for d in subdir_list]  # US > noUS
labels = [d.name for d in subdir_list]

# all images were normalised to the same space
# load one to get a reference space
example_result = image.load_img(spm_paths[0])

# load the unthresholded signatures of pain and fear
pain_un = image.load_img(str(pain_dir / 'General_vicarious_pain_pattern_unthresholded.nii'))
fear_un = image.load_img(str(fear_dir / 'VIFS.nii'))

# resample the signature images to our result space
pain_un_r = image.resample_to_img(pain_un, example_result, interpolation='nearest')
fear_un_r = image.resample_to_img(fear_un, example_result, interpolation='nearest')

# vectorize the signatures
masker = input_data.NiftiMasker(mask_strategy='template')
pain_signature = masker.fit_transform(pain_un_r).reshape(-1, 1) # ensures column vector
fear_signature = masker.fit_transform(fear_un_r).reshape(-1, 1)
signature = np.hstack((pain_signature, fear_signature))  # (voxels x signatures)

# load and vectorize our 1st level results, shape: (voxels x images)
my_data = np.zeros([signature.shape[0], len(labels)])
for n, spm_path in enumerate(spm_paths):
    masker = input_data.NiftiMasker(mask_strategy='template')
    my_data[:, n] = masker.fit_transform(spm_path).flatten()

# calculate dot product
dot_product = np.dot(my_data.T, signature)  # (subjects x signature(s))

# store the results in a pandas dataframe and save it
df = pd.DataFrame(
    data=dot_product,
    index=labels,
    columns=["dot_pain", "dot_fear"],
)

if not out_dir.exists():
    out_dir.mkdir()

df.to_csv(
    out_dir / 'pattern_expression.csv',
    header=True,
    index=True,
    index_label="label"
)
