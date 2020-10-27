% Run Volume of Interest extraction for right TPJ

my_config = ini2struct('../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'mot_out');
roi_dir = fullfile(my_config.spm.root, 'roi');

% select all 1st level models for OFL
files = dir(fullfile(analysis_dir, 'first_level', '*_ofl', 'SPM.mat'));

% batch setup
nrun = size(files, 1);
jobfile = {'voi_ofl_rTPJ_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(7, nrun);

% voi definitions - shared by all subjects
contrast = [3, 1, 1; 4, 1, -1];
ppi_name = 'RTPJxUSDIFF';

for crun = 1:nrun
    model = fullfile(files(crun,1).folder, files(crun,1).name);
    subject_mask = fullfile(files(crun,1).folder, 'mask.nii,1');
    centre = [58 -50 14];  % peak for term 'tpj' on Neurosynth
    radius = 8;
    
    inputs{1, crun} = cellstr(model); % Volume of Interest: Select SPM.mat - cfg_files
    inputs{2, crun} = centre; % Volume of Interest: Centre - cfg_entry
    inputs{3, crun} = radius; % Volume of Interest: Radius - cfg_entry
    inputs{4, crun} = cellstr(subject_mask); % Volume of Interest: Image file - cfg_files
    inputs{5, crun} = cellstr(model); % Physio/Psycho-Physiologic Interaction: Select SPM.mat - cfg_files
    inputs{6, crun} = contrast; % Physio/Psycho-Physiologic Interaction:  Input variables and contrast weights - cfg_entry
    inputs{7, crun} = ppi_name; % Physio/Psycho-Physiologic Interaction: Name of PPI - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
