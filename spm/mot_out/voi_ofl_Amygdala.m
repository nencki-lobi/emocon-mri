% Run Volume of Interest & PPI modules for bilateral Amygdala
%
% Uses a crossection of VOI mask and subject's mask.nii from 1st level
% because for 2 subjects there were a few missing voxels resulting in a
% crash.

my_config = ini2struct('../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'mot_out');
roi_dir = fullfile(my_config.spm.root, 'roi');

files = dir(fullfile(analysis_dir, 'first_level', '*_ofl', 'SPM.mat'));

nrun = size(files, 1);

jobfile = {'voi_ofl_Amygdala_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(6, nrun);

% same for all subjects
voi_mask = cellstr(fullfile(roi_dir, 'amy_bilateral.nii,1'));
contrast = [3, 1, 1; 4, 1, -1];
ppi_name = 'AMYxUSDIFF';

for crun = 1:nrun
    
    model = cellstr(fullfile(files(crun,1).folder, files(crun,1).name));
    subject_mask = cellstr(fullfile(files(crun,1).folder, 'mask.nii,1'));
    
    % Volume of Interest: Select SPM.mat - cfg_files
    inputs{1, crun} = model; 
    
    % Volume of Interest: Image file - cfg_files
    inputs{2, crun} = voi_mask;  % i1
    
    % Volume of Interest: Image file - cfg_files
    inputs{3, crun} = subject_mask;  % i2
    
    % Physio/Psycho-Physiologic Interaction: Select SPM.mat - cfg_files
    inputs{4, crun} = model;
    
    % Physio/Psycho-Physiologic Interaction:  Input variables and contrast weights - cfg_entry
    inputs{5, crun} = contrast;
    
    % Physio/Psycho-Physiologic Interaction: Name of PPI - cfg_entry
    inputs{6, crun} = ppi_name;
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
