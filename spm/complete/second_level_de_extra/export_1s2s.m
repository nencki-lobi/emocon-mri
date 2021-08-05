% Export thresholded statistical map
%
% Exported map can be used for further visualisation
% Using cluster thresholding with thresholds from GUI

my_config = ini2struct('../../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'complete');

jobfile = {'export_1s2s_job.m'};
jobs = repmat(jobfile, 1, 2);
inputs = cell(5, 2);

% Results Report: Select SPM.mat - cfg_files
inputs{1, 1} = cellstr(fullfile(...
    analysis_dir, 'second_level', 'de_extra', 'tmod_1sample', 'SPM.mat'));;
% Results Report: Contrast(s) - cfg_entry
inputs{2, 1} = 1;
% Results Report: Threshold - cfg_entry
inputs{3, 1} = 3.21;
% Results Report: Extent (voxels) - cfg_entry
inputs{4, 1} = 105;
% Results Report: Basename - cfg_entry
inputs{5, 1} = 'thr_cluster';

% Results Report: Select SPM.mat - cfg_files
inputs{1, 2} = cellstr(fullfile(...
    analysis_dir, 'second_level', 'de_extra', 'tmod_2sample', 'SPM.mat'));;
% Results Report: Contrast(s) - cfg_entry
inputs{2, 2} = 1;
% Results Report: Threshold - cfg_entry
inputs{3, 2} = 3.21;
% Results Report: Extent (voxels) - cfg_entry
inputs{4, 2} = 95;
% Results Report: Basename - cfg_entry
inputs{5, 2} = 'thr_cluster';

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
