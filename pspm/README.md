# PsPM analysis

This folder contains scripts for PsPM analysis. Currently work in progress.

## Core scripts:

1. make_subjects_table.py: combines information from BIDS participants table and questionnaires table for easy access to participant info (code, contingency)
2. import_scr.m handles data import
3. trim_scr.m handles data trimming (trims to match beginning with MR)
4. create_events_scr_dcm.m creates event files for scr dcm
5. dcm_batch_ofl.m & dcm_batch_de.m run first level DCM

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

### Batch wrappers

1. dcm_process_* are functions which take subject label as argument and run an appropriate batch - this is useful when running in noninteractive mode.

## Notes

For running R scripts in terminal, use `Rscript` command.
