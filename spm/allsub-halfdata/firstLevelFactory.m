function firstLevelFactory(analysis_dir, task, event_subfolder,...
    model_subfolder)
%FIRSTLEVELFACTORY Summary of this function goes here
%   Detailed explanation goes here

% path specs
my_config = ini2struct('../../config.ini');

deriv_dir = my_config.default.deriv_dir;
spm_out_dir = my_config.spm.root;

pat_smoothed = 'sm6_sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';
pat_mask = 'sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-brain_mask.nii';

subject_table = readtable(...
    fullfile(spm_out_dir, analysis_dir, 'participants.csv'),...
    'TextType', 'string');

nrun = height(subject_table);
jobfile = {'first_level_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(6, nrun);

for crun = 1:nrun
    
    subject = subject_table.subject(crun);
    
    bold_path = cellstr(fullfile(...
        deriv_dir, 'spm', 'smooth', strcat('sub-', subject), ...
        sprintf(pat_smoothed, subject, task)));
    
    mask_path = cellstr(fullfile(...
        spm_out_dir, 'brain_masks', strcat('sub-', subject), ...
        sprintf(pat_mask, subject, task)));
    
    events_path = cellstr(fullfile(...
        spm_out_dir, analysis_dir, event_subfolder, ...
        sprintf('%s_%s.mat', subject, task)));
    
    confounds_path = cellstr(fullfile(...
        spm_out_dir, analysis_dir, 'confounds', ...
        sprintf('%s_%s.mat', subject, task)));  % using .mat this time
    
    model_dir = cellstr(fullfile(...
        spm_out_dir, analysis_dir, model_subfolder, ...
        sprintf('sub-%s_task-%s', subject, task)));
    
    % the following is valid for DE only!
    % OFL should discard from start too
    frames = 1 : subject_table.use_volumes(crun);
    
    inputs{1, crun} = bold_path; % Expand image frames: NIfTI file(s) - cfg_files
    inputs{2, crun} = frames; % Expand image frames: Frames - cfg_entry
    inputs{3, crun} = model_dir; % fMRI model specification: Directory - cfg_files
    inputs{4, crun} = events_path; % fMRI model specification: Multiple conditions - cfg_files
    inputs{5, crun} = confounds_path; % fMRI model specification: Multiple regressors - cfg_files
    inputs{6, crun} = mask_path; % fMRI model specification: Explicit mask - cfg_files
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

end

