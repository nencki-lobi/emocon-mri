% First level ofl: specify, estimate, contrast manager
my_config = ini2struct('../../config.ini');

deriv_dir = my_config.default.deriv_dir;
masks_dir = fullfile(my_config.spm.root, 'brain_masks');
analysis_dir = fullfile(my_config.spm.root, 'complete');

pat_smoothed = 'sm6_sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';
pat_mask = 'sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-brain_mask.nii';

subject_table = readtable(...
    fullfile(analysis_dir, 'other', 'included_participants.csv'), ...
    'TextType', 'string');

nrun = height(subject_table);
jobfile = {'first_level_ofl_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(6, nrun);

for crun = 1:nrun
    
    subject = subject_table.label(crun);
    bold_path = cellstr(fullfile(...
        deriv_dir, "spm", "smooth", "sub-" + subject, ...
        sprintf(pat_smoothed, subject, "ofl")));
    mask_path = cellstr(fullfile(...
        masks_dir, "sub-" + subject, sprintf(pat_mask, subject, "ofl")));
    conditions_path = cellstr(fullfile(...
        analysis_dir, 'events', subject + "_ofl.mat"));
    regressors_path = cellstr(fullfile(...
        analysis_dir, 'confounds', subject + "_ofl.mat"));
    out_dir = cellstr(fullfile(...
        analysis_dir, 'first_level', subject + "_ofl"));

    bold = nifti(bold_path);
    frames = subject_table.discard_volumes_ofl(crun) + 1 : bold.dat.dim(4);
    
    inputs{1, crun} = bold_path; % Expand image frames: NIfTI file(s) - cfg_files
    inputs{2, crun} = frames; % Expand image frames: Frames - cfg_entry
    inputs{3, crun} = out_dir; % fMRI model specification: Directory - cfg_files
    inputs{4, crun} = conditions_path; % fMRI model specification: Multiple conditions - cfg_files
    inputs{5, crun} = regressors_path; % fMRI model specification: Multiple regressors - cfg_files
    inputs{6, crun} = mask_path; % fMRI model specification: Explicit mask - cfg_files
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
