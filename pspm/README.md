# PsPM analysis

This folder contains scripts for PsPM analysis. Currently work in progress.

## Core scripts:

1. make_subjects_table.py: extract information from questionnaires table for easy access to participant info (label, group, contingency)
2. import_scr.m handles data import
3. trim_scr.m handles data trimming (trims to match beginning with MR)
4. create_events_scr_dcm.m creates event files for scr dcm
5. dcm_batch_ofl.m & dcm_batch_de.m run first level DCM

Note: before running first level scripts, create an empty directory `<pspm_analysis_root>/models_scr_dcm`; pspm model estimation crashes if it does not exist, but only after doing the estimation.

## Core functions

1. get_condition_info: Get condition info from events file

## Other

This part not complete

### Utility scripts

1. reorder_epochs.m - reorders epochs array in missing epochs file, appears to be necessary to avoid crashers
2. show_filtered - for quick preview of raw & filtered signal
3. plot_us_responses
4. check_markers, check_main_markers
5. markers_coverage - can be used to screen for problems with scanner markers (which are used to trim data) - when the first and last one are closer or further apart then the task would suggest; further screening not included, but described in comments
6. make_processing_list - collects subjects and makes a text file with functions to be called to run model estimation (potentially in parallel)

### Batch wrappers

1. dcm_process_* are functions which take subject label as argument and run an appropriate batch - this is useful when running in noninteractive mode.

Example GNU parallel call:

```
parallel -a <pspm_root>/to_call.txt --jobs 8
    'matlab -nodisplay -singleCompThread -batch {}' > /dev/null
``` 

where  `<pspm_root>/to_call.txt` contains function calls in subsequent rows:

```
dcm_process_ofl("Abcdef")
dcm_process_de("Abcdef")
...
```

## Notes

For running R scripts in terminal, use `Rscript` command.
