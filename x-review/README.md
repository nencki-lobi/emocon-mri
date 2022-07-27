# Extras - review

This folder contains an additional analysis of fusiform laterality, performed in the review process.
It should work standalone (independent of code elsewhere), and depend only on files publically available on OSF.
Python script(s) to be executed from the current directory, with the same virtualenv as the main analysis.

## Content:
- Closer inspection of fusiform lateralisation
  - `extract_fusiforms.py` - beta parameter extraction
  - `Fusiform_lateralisation.Rmd` - analysis of FFA activation lateralisation
- Multivariate signature analysis
  - `signature_of_pain.py` - pattern expression calculation
  - `signature_of_pain.Rmd` - statistical group comparisons
- Helper files:
  - `config.ini.example` - local config with paths to data files

## Reproducing
- Download files from [OSF](https://osf.io/g3wkq/) (keeping subfolder structure; required folders: `fMRI/first_level`, `Behavioral`)
- Download `seed_lFFA_vox200.nii.gz` and `seed_rFFA_vox200.nii.gz` from [Neurovault](https://neurovault.org/collections/2462/)
- Download multivariate signature patterns: `General_vicarious_pain_pattern_unthresholded.nii` and `VIFS.nii` from CANlab's [Neuroimaging Pattern Masks](https://github.com/canlab/Neuroimaging_Pattern_Masks) repository (2020 Zhou & 2021 Zhou folders, respectively)
  - direct links: [pain](https://github.com/canlab/Neuroimaging_Pattern_Masks/raw/master/Multivariate_signature_patterns/2020_Zhou_general_vicarious_pain/General_vicarious_pain_pattern_unthresholded.nii), [fear](https://github.com/canlab/Neuroimaging_Pattern_Masks/raw/master/Multivariate_signature_patterns/2021_Zhou_Subjective_Fear/VIFS.nii)
- Copy config example to `config.ini` and adjust paths accordingly
- Closer inspection of fusiform lateralisation:
  - Run `extract_fusiforms.py`
  - Build html from `Fusiform_lateralisation.Rmd`
- Multivariate signature analysis
  - Run `signature_of_pain.py`
  - Build html from `signature_of_pain.Rmd`
