% Vanila first level: specify, estimate, contrast manager

my_config = ini2struct('../../config.ini');

bids_dir = my_config.default.bids_root;
deriv_dir = my_config.default.deriv_dir;
spm_out_dir = my_config.spm.root;

pat_smoothed = 'sm6_sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';
pat_mask = 'sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-brain_mask.nii';

analysis_dir = fullfile(spm_out_dir, 'mot_out');

subject_table = readtable(fullfile(analysis_dir, 'participants.csv'), ...
    'TextType', 'string');

nrun = height(subject_table);
jobfile = {'first_level_de_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(5, nrun);
for crun = 1:nrun
    
    subject = subject_table.subject(crun);
    bold_path = cellstr(fullfile( ...
        deriv_dir, 'spm', 'smooth', strcat('sub-', subject), ...
        sprintf(pat_smoothed, subject, 'de')));
    mask_path = cellstr(fullfile( ...
        spm_out_dir, 'brain_masks', strcat('sub-', subject), ...
        sprintf(pat_mask, subject, 'de')));
    conditions_path = cellstr(fullfile( ...
        analysis_dir, 'events', strcat(subject, '_de.mat')));
    regressors_path = cellstr(fullfile( ...
        analysis_dir, 'confounds', strcat(subject, '_de.mat')));
    out_dir = cellstr(fullfile( ...
        analysis_dir, 'first_level', strcat(subject, '_de')));

    inputs{1, crun} = out_dir; % fMRI model specification: Directory - cfg_files
    inputs{2, crun} = bold_path; % fMRI model specification: Scans - cfg_files
    inputs{3, crun} = conditions_path; % fMRI model specification: Multiple conditions - cfg_files
    inputs{4, crun} = regressors_path; % fMRI model specification: Multiple regressors - cfg_files
    inputs{5, crun} = mask_path; % fMRI model specification: Explicit mask - cfg_files
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
