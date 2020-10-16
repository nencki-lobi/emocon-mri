% Run Volume of Interest extraction for right TPJ

my_config = ini2struct('../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'mot_out');
roi_dir = fullfile(my_config.spm.root, 'roi');

% select all 1st level models for OFL
files = dir(fullfile(analysis_dir, 'first_level', '*_ofl', 'SPM.mat'));

% fetch VOI definition if not present
% should probably be moved elsewhere (python script with all rois?)
local_path = fullfile(roi_dir, 'seed_rTPJ_vox200.nii');
mask_url = 'https://neurovault.org/media/images/2462/seed_rTPJ_vox200.nii.gz';
if ~ isfile(local_path)
    gunzip(mask_url, roi_dir)
end

% batch setup
nrun = size(files, 1);
jobfile = {'voi_ofl_rTPJ_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(5, nrun);

% voi definitions - shared by all subjects
voi_mask = fullfile(roi_dir, 'seed_rTPJ_vox200.nii,1');
contrast = [3, 1, 1; 4, 1, -1];
ppi_name = 'RTPJxUSDIFF';

for crun = 1:nrun
    model = fullfile(files(crun,1).folder, files(crun,1).name);
    inputs{1, crun} = cellstr(model); % Volume of Interest: Select SPM.mat - cfg_files
    inputs{2, crun} = cellstr(voi_mask); % Volume of Interest: Image file - cfg_files
    inputs{3, crun} = cellstr(model); % Physio/Psycho-Physiologic Interaction: Select SPM.mat - cfg_files
    inputs{4, crun} = contrast; % Physio/Psycho-Physiologic Interaction:  Input variables and contrast weights - cfg_entry
    inputs{5, crun} = ppi_name; % Physio/Psycho-Physiologic Interaction: Name of PPI - cfg_entry
end
% spm('defaults', 'FMRI');
% spm_jobman('run', jobs, inputs{:});
