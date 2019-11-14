% List of open inputs
% Expand image frames: NIfTI file(s) - cfg_files
% Expand image frames: Frames - cfg_entry
% fMRI model specification: Directory - cfg_files
% fMRI model specification: Multiple conditions - cfg_files
% fMRI model specification: Multiple regressors - cfg_files
% fMRI model specification: Explicit mask - cfg_files

% path specs
my_config = ini2struct('../../config.ini');

deriv_dir = my_config.default.deriv_dir;
spm_out_dir = my_config.spm.root;

pat_smoothed = 'sm6_sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';
pat_mask = 'sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-brain_mask.nii';

subject_table = readtable(...
    fullfile(spm_out_dir, 'modulation', 'participants.csv'),...
    'TextType', 'string');

confounds_dir = fullfile(spm_out_dir, 'modulation', 'confounds');

task = 'de';  % for now only de

nrun = height(subject_table);
jobfile = {'first_level_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(6, nrun);
for crun = 1:nrun
    
    subject = subject_table.code(crun);
    
    bold_path = cellstr(fullfile(...
        deriv_dir, 'spm', 'smooth', strcat('sub-', subject), ...
        sprintf(pat_smoothed, subject, task)));
    
    mask_path = cellstr(fullfile(...
        spm_out_dir, 'brain_masks', strcat('sub-', subject), ...
        sprintf(pat_mask, subject, task)));
    
    events_path = cellstr(fullfile(...
        spm_out_dir, 'modulation', 'events_pmod', ...
        sprintf('%s_%s.mat', subject, task)));
    
    confounds_path = cellstr(fullfile(...
        confounds_dir, ...
        sprintf('%s_%s.txt', subject, task)));
    
    model_dir = cellstr(fullfile(...
        spm_out_dir, 'modulation', 'level1_pmod', ...
        sprintf('sub-%s_task-%s', subject, task)));
    
    frames = Inf;
    
    inputs{1, crun} = bold_path; % Expand image frames: NIfTI file(s) - cfg_files
    inputs{2, crun} = frames; % Expand image frames: Frames - cfg_entry
    inputs{3, crun} = model_dir; % fMRI model specification: Directory - cfg_files
    inputs{4, crun} = events_path; % fMRI model specification: Multiple conditions - cfg_files
    inputs{5, crun} = confounds_path; % fMRI model specification: Multiple regressors - cfg_files
    inputs{6, crun} = mask_path; % fMRI model specification: Explicit mask - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
