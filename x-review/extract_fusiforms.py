import configparser
import numpy as np
import pandas as pd
from pathlib import Path
from nilearn.input_data import NiftiMasker
from nilearn.image import load_img, clean_img, concat_imgs, math_img


def extract_betas(img_list, masker):
    """Extracts mean beta value for each image
    inputs:
    img_list: list or series of file names
    masker: NiftiMasker with appropriate mask
    returns:
    mean_betas: array with 1 parameter per subject
    """
    # concatenate all beta maps to 4D
    all_betas = concat_imgs(img_list)  # expects a list of strings
    
    # replace NaNs with zeros to stop Nilearn from complaining
    # uses clean_img without any additional transforms
    all_finite = clean_img(
        all_betas, detrend=False, standardize=False, ensure_finite=True)
    
    # extract all voxel values from mask
    extracted_betas = masker.fit_transform(all_finite)
    
    # average over voxels in a mask
    mean_betas = np.mean(extracted_betas, axis=1)
    return mean_betas


# load paths from a local config file
config = configparser.ConfigParser()
config.read('config.ini')
osf_data = Path(config['extras']['osf_data'])
roi_input = Path(config['extras']['roi_input'])
roi_output = Path(config['extras']['roi_output'])

# paths to analysed files
ofl_dir = osf_data / 'fMRI' / '1st_level' / 'observational fear learning/'
subjects_file = osf_data / 'Behavioral' / 'table.tsv'

# mask file names (as string, nibabel doesn't like Paths)
rFFA_file = str(roi_input / 'seed_rFFA_vox200.nii.gz')
lFFA_file = str(roi_input / 'seed_lFFA_vox200.nii.gz')

# combine left and right into a bilateral masks
bilateral_mask = math_img('img1 + img2', img1=lFFA_file, img2=rFFA_file)

# create NiftiMasker objects to be aplied to data
lFFA_masker = NiftiMasker(mask_img=lFFA_file)
rFFA_masker = NiftiMasker(mask_img=rFFA_file)
bl_masker = NiftiMasker(mask_img = bilateral_mask)

# make lists of subjects / paths, keeping order consistent
subdir_list = [p for p in ofl_dir.iterdir() if p.is_dir()]
us_paths = [d / 'con_0003.nii' for d in subdir_list]
no_paths = [d / 'con_0004.nii' for d in subdir_list]
vs_paths = [d / 'con_0005.nii' for d in subdir_list]
labels = [d.name for d in subdir_list]

# put these in a data frame
df = pd.DataFrame(
    {'label': labels,
     'us_path': us_paths,
     'no_path': no_paths,
     'vs_path': vs_paths,
     }
).astype(str)

# figure out group assignment
subject_table = pd.read_table(subjects_file)
groupinfo = subject_table.query('role=="OBS"').set_index('label')['group']
df = df.join(groupinfo, on='label', how='left')

# extract and keep US betas
df['left_us'] = extract_betas(df.us_path, lFFA_masker)
df['right_us'] = extract_betas(df.us_path, rFFA_masker)
df['both_us'] = extract_betas(df.us_path, bl_masker)

# extract and keep noUS betas
df['left_no'] = extract_betas(df.no_path, lFFA_masker)
df['right_no'] = extract_betas(df.no_path, rFFA_masker)
df['both_no'] = extract_betas(df.no_path, bl_masker)

# extract and keep US vs noUS betas
df['left_vs'] = extract_betas(df.vs_path, lFFA_masker)
df['right_vs'] = extract_betas(df.vs_path, rFFA_masker)
df['both_vs'] = extract_betas(df.vs_path, bl_masker)

# drop paths from the table
df.drop(columns=['us_path', 'no_path', 'vs_path'], inplace=True)

# write out the table
if not roi_output.exists():
    roi_output.mkdir(parents=True)
    
df.to_csv(roi_output / 'ffa_betas.csv', index=False)

print(df)
