% Run Volume of Interest extraction for bilateral Anterior Insula

my_config = ini2struct('../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'mot_out');
roi_dir = fullfile(my_config.spm.root, 'roi');

files = dir(fullfile(analysis_dir, 'first_level', '*_ofl', 'SPM.mat'));

nrun = size(files, 1); % enter the number of runs here
jobfile = {'voi_ofl_Insula_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(5, nrun);

% same for all subjects
voi_mask = fullfile(roi_dir, 'anterior_insula.nii,1');
contrast = [3, 1, 1; 4, 1, -1];
ppi_name = 'AINSxUSDIFF';

for crun = 1:nrun
    model = fullfile(files(crun,1).folder, files(crun,1).name);
    inputs{1, crun} = cellstr(model); % Volume of Interest: Select SPM.mat - cfg_files
    inputs{2, crun} = cellstr(voi_mask); % Volume of Interest: Image file - cfg_files
    inputs{3, crun} = cellstr(model); % Physio/Psycho-Physiologic Interaction: Select SPM.mat - cfg_files
    inputs{4, crun} = contrast; % Physio/Psycho-Physiologic Interaction:  Input variables and contrast weights - cfg_entry
    inputs{5, crun} = ppi_name; % Physio/Psycho-Physiologic Interaction: Name of PPI - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
