% First level with early & late DE trials

my_config = ini2struct('../../../config.ini');

bids_dir = my_config.default.bids_root;
deriv_dir = my_config.default.deriv_dir;
spm_out_dir = my_config.spm.root;

pat_smoothed = 'sm6_sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';
pat_mask = 'sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-brain_mask.nii';

analysis_dir = fullfile(spm_out_dir, 'mot_out');
output_dir = cellstr(fullfile(analysis_dir, 'first_level_earlylate'));

subject_table = readtable(fullfile(analysis_dir, 'participants.csv'), ...
    'TextType', 'string');
nrun = height(subject_table);

jobfile = {'/Users/michal/Documents/emocon_mri_study/spm/mot_out/models_early_late/first_level_de_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(8, nrun);

for crun = 1:nrun
    
    subject = subject_table.subject{crun};
    event_file = fullfile(bids_dir, "sub-" + subject, "func", "sub-" + subject + '_task-de_events.tsv');
    et = readtable(event_file, 'FileType', 'text', 'TextType', 'string');
    
    % fMRI model specification: Directory - cfg_files
    inputs{1, crun} = cellstr(fullfile(...
        analysis_dir, 'first_level_earlylate', strcat(subject, '_de')));
    % fMRI model specification: Scans - cfg_files
    inputs{2, crun} = cellstr(fullfile( ...
        deriv_dir, 'spm', 'smooth', strcat('sub-', subject), ...
        sprintf(pat_smoothed, subject, 'de')));
    % fMRI model specification: Onsets - cfg_entry
    inputs{3, crun} = et{et.trial_type == "cs_plus", 'onset'}(1:6);
    % fMRI model specification: Onsets - cfg_entry
    inputs{4, crun} = et{et.trial_type == "cs_minus", 'onset'}(1:6);
    % fMRI model specification: Onsets - cfg_entry
    inputs{5, crun} = et{et.trial_type == "cs_plus", 'onset'}(7:12);
    % fMRI model specification: Onsets - cfg_entry
    inputs{6, crun} = et{et.trial_type == "cs_minus", 'onset'}(7:12);
    % fMRI model specification: Multiple regressors - cfg_files
    inputs{7, crun} = cellstr(fullfile(...
        analysis_dir, 'confounds', strcat(subject, '_de.mat')));
    % fMRI model specification: Explicit mask - cfg_files
    inputs{8, crun} = cellstr(fullfile( ...
        spm_out_dir, 'brain_masks', strcat('sub-', subject), ...
        sprintf(pat_mask, subject, 'de')));
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
