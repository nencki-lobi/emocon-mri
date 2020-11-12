% PPI model for anterior insula, OFL

my_config = ini2struct('../../../config.ini');

bids_dir = my_config.default.bids_root;
deriv_dir = my_config.default.deriv_dir;
spm_out_dir = my_config.spm.root;

pat_smoothed = 'sm6_sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';
pat_mask = 'sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-brain_mask.nii';

analysis_dir = fullfile(spm_out_dir, 'mot_out');

subject_table = readtable(fullfile(analysis_dir, 'participants.csv'), ...
    'TextType', 'string');

nrun = height(subject_table);
jobfile = {'ppi_model_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(8, nrun);

for crun = 1:nrun
    
    subject = subject_table.subject(crun);
    bold_path = cellstr(fullfile( ...
        deriv_dir, 'spm', 'smooth', strcat('sub-', subject), ...
        sprintf(pat_smoothed, subject, 'ofl')));
    mask_path = cellstr(fullfile( ...
        spm_out_dir, 'brain_masks', strcat('sub-', subject), ...
        sprintf(pat_mask, subject, 'ofl')));
    regressors_path = cellstr(fullfile( ...
        analysis_dir, 'confounds', strcat(subject, '_ofl.mat')));
    ppi_file = fullfile(...
        analysis_dir, 'first_level', strcat(subject, '_ofl'), ...
        'PPI_AINSxUSDIFF.mat');
    out_dir = cellstr(fullfile( ...
        analysis_dir, 'PPI_OFL_AINSxUS', strcat('sub-', subject)));

    bold = nifti(bold_path);
    frames = subject_table.discard_volumes_ofl(crun) + 1 : bold.dat.dim(4);
    
    load(ppi_file)  % creates PPI variable
    
    inputs{1, crun} = bold_path; % Expand image frames: NIfTI file(s) - cfg_files
    inputs{2, crun} = frames; % Expand image frames: Frames - cfg_entry
    inputs{3, crun} = out_dir; % fMRI model specification: Directory - cfg_files
    inputs{4, crun} = PPI.ppi; % fMRI model specification: Value - cfg_entry
    inputs{5, crun} = PPI.Y; % fMRI model specification: Value - cfg_entry
    inputs{6, crun} = PPI.P; % fMRI model specification: Value - cfg_entry
    inputs{7, crun} = regressors_path; % fMRI model specification: Multiple regressors - cfg_files
    inputs{8, crun} = mask_path; % fMRI model specification: Explicit mask - cfg_files
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
