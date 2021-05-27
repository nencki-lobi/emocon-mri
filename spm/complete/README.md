Complete
========

This folder contains scripts for running the SPM analysis, incl. preparation of event / confound files, 1st and 2nd level models.

Prerequisites
-------------

The following need to be prepared and accessible:
- BIDS raw dataset
- fMRIPrep derivative dataset
- smoothed data
- unzipped brain masks from the fMRIPrep
- the behavioral table, which contains contingency knowledge classification

File organisation
-----------------

This is how the scripts are laid out (described in a logical order):

- Preparation of events, confounds & participants list: `prepare.m`
- Basic first levels: `first_level_ofl.m` & `first_level_de.m`
- Whole-brain activation analysis
  - Second levels for primary contrasts of interest (US > noUS, CS+ > CS-): folders `second_level_<task>_basic`
	- 1 sample t-test (pooled): `ttest_1s.m`
	- 2 sample t-test (between-group): `ttest_2s.m`
- ROI analysis (i.e. parameter extraction): folder `roi`
  - Prepare ROIs (download, unpack, combine): `prepare_roi.m`
  - Parameter extraction: `extract_from_roi.m`
- PPI analysis: folders `ppi_<task>_<roi>` (and `ppi_shared`) with:
	- VOI specification & timeseries extraction: `timeseries_extraction.m`
	- PPI model: `ppi_model_<task>.m`
	- Second level (1 and 2 sample t-test): `second_levels_ppi`
