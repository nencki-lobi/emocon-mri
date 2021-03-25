% Run Volume of Interest extraction for ACC / DE

my_config = ini2struct('../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'mot_out');
roi_dir = fullfile(my_config.spm.root, 'roi');

% select all 1st level models for OFL
files = dir(fullfile(analysis_dir, 'first_level_longevent', '*_de', 'SPM.mat'));

% batch setup
nrun = size(files, 1);
jobfile = {'voi_de_ACC_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(6, nrun);

% voi definitions - shared by all subjects
contrast = [1, 1, 1; 2, 1, -1];
ppi_name = 'ACCxCS';
centre = [6, 20, 38];
radius = 8;

for crun = 1:nrun
    
    model = fullfile(files(crun,1).folder, files(crun,1).name);
    
    inputs{1, crun} = cellstr(model); % Volume of Interest: Select SPM.mat - cfg_files
    inputs{2, crun} = centre; % Volume of Interest: Centre - cfg_entry
    inputs{3, crun} = radius; % Volume of Interest: Radius - cfg_entry
    inputs{4, crun} = cellstr(model); % Physio/Psycho-Physiologic Interaction: Select SPM.mat - cfg_files
    inputs{5, crun} = contrast; % Physio/Psycho-Physiologic Interaction:  Input variables and contrast weights - cfg_entry
    inputs{6, crun} = ppi_name; % Physio/Psycho-Physiologic Interaction: Name of PPI - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
