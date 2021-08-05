% Export thresholded statistical map
%
% Cluster size thresholding with size obtained from GUI

my_config = ini2struct('../../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'complete');

spm_file = cellstr(fullfile(...
    analysis_dir, 'ppi_group', 'PPI_ofl_AIxUS', '1_sample', 'SPM.mat'));
contrast = 1;
threshold = 3.21;
extent = 93;
basename = 'thr_cluster';

jobfile = {'../ppi_shared/export_1s_job.m'};
jobs = repmat(jobfile, 1, 1);
inputs = cell(5, 1);

inputs{1, 1} = spm_file; % Results Report: Select SPM.mat - cfg_files
inputs{2, 1} = contrast; % Results Report: Contrast(s) - cfg_entry
inputs{3, 1} = threshold; % Results Report: Threshold - cfg_entry
inputs{4, 1} = extent; % Results Report: Extent (voxels) - cfg_entry
inputs{5, 1} = basename; % Results Report: Basename - cfg_entry

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
