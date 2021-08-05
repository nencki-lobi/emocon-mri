% Export thresholded statistical map
%
% Exported map can be used for further visualisation
% See job file for parameters used

my_config = ini2struct('../../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'complete');

spm_file = cellstr(fullfile(...
    analysis_dir, 'second_level', 'ofl_basic', 'obsUR_1sample', 'SPM.mat'));
contrast = 1;
basename = 'thresholded';

jobfile = {'export_1s_job.m'};
jobs = repmat(jobfile, 1, 1);
inputs = cell(3, 1);

inputs{1, 1} = spm_file; % Results Report: Select SPM.mat - cfg_files
inputs{2, 1} = contrast; % Results Report: Contrast(s) - cfg_entry
inputs{3, 1} = basename; % Results Report: Basename - cfg_entry

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
