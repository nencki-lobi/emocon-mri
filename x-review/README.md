# Extras - review

This folder contains an additional analysis of fusiform laterality, performed in the review process.
It should work standalone (independent of code elsewhere), and depend only on files publically available on OSF.
Python script(s) to be executed from the current directory, with the same virtualenv as the main analysis.

## Content:
- `extract_fusiforms.py` - beta parameter extraction
- `Fusiform_lateralisation.Rmd` - analysis of FFA activation lateralisation
- `config.ini.example` - local config with paths to data files

## Reproducing
- Download files from [OSF](https://osf.io/g3wkq/) (keeping subfolder structure; required folders: `fMRI/first_level`, `Behavioral`)
- Download `seed_lFFA_vox200.nii.gz` and `seed_rFFA_vox200.nii.gz` from [Neurovault](https://neurovault.org/collections/2462/)
- Copy config example to `config.ini` and adjust paths accordingly
- Run `extract_fusiforms.py`
- Build html from `Fusiform_lateralisation.Rmd`
