% List of open inputs
% Expand image frames: NIfTI file(s) - cfg_files
% Expand image frames: Frames - cfg_entry
% fMRI model specification: Directory - cfg_files
% fMRI model specification: Name - cfg_entry
% fMRI model specification: Value - cfg_entry
% fMRI model specification: Name - cfg_entry
% fMRI model specification: Value - cfg_entry
% fMRI model specification: Name - cfg_entry
% fMRI model specification: Value - cfg_entry
% fMRI model specification: Multiple regressors - cfg_files
% fMRI model specification: Explicit mask - cfg_files
% Contrast Manager: Name - cfg_entry
% Contrast Manager: Weights vector - cfg_entry

my_config = ini2struct('../../config.ini');

deriv_dir = my_config.default.deriv_dir;
spm_out_dir = my_config.spm.root;

ofl_pat = 'sm6_sub-%s_task-ofl_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';
mask_pat = 'sub-%s_task-ofl_space-MNI152NLin2009cAsym_desc-brain_mask.nii';
ppi_name = 'PPI_AINSxCSDIFF';

subject_table = readtable(...
    fullfile(spm_out_dir, 'allsub', 'participants.csv'),...
    'TextType', 'string');

nrun = height(subject_table); % enter the number of runs here
jobfile = {'/Users/michal/Documents/emocon_mri_study/spm/ppi/ppi_model_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(13, nrun);
for crun = 1:nrun
    
    subject = subject_table.subject(crun);
    
    ofl_file = cellstr(fullfile(deriv_dir, 'spm', 'smooth', ...
        sprintf('sub-%s', subject), ...
        sprintf(ofl_pat, subject)));
    
    n_discard = subject_table.discard_volumes_ofl(crun);
    if n_discard == 0
        frames = Inf;
    else
        bold = nifti(ofl_file);
        n_frames = bold.dat.dim(4);
        frames = n_discard+1 : n_frames;
    end
    
    ppi_file = fullfile(spm_out_dir, 'allsub', 'level1_tmod1', ...
        sprintf('sub-%s_task-ofl', subject), strcat(ppi_name, '.mat'));
    load(ppi_file);
    
    confounds_file = cellstr(fullfile(spm_out_dir, 'allsub', 'confounds', ...
        sprintf('%s_ofl.txt', subject)));
    mask_file = cellstr(fullfile(spm_out_dir, 'brain_masks', ...
        sprintf('sub-%s', subject), sprintf(mask_pat, subject)));
    
    ppi_model_dir = cellstr(fullfile(spm_out_dir, 'ppi', ppi_name, ...
        sprintf('sub-%s', subject)));
    
    inputs{1, crun} = ofl_file; % Expand image frames: NIfTI file(s) - cfg_files
    inputs{2, crun} = frames; % Expand image frames: Frames - cfg_entry
    inputs{3, crun} = ppi_model_dir; % fMRI model specification: Directory - cfg_files
    
    inputs{4, crun} = 'PPIInteraction'; % fMRI model specification: Name - cfg_entry
    inputs{5, crun} = PPI.ppi; % fMRI model specification: Value - cfg_entry
    inputs{6, crun} = 'AInsBOLD'; % fMRI model specification: Name - cfg_entry
    inputs{7, crun} = PPI.Y; % fMRI model specification: Value - cfg_entry
    inputs{8, crun} = 'US-noUS'; % fMRI model specification: Name - cfg_entry
    inputs{9, crun} = PPI.P; % fMRI model specification: Value - cfg_entry
    inputs{10, crun} = confounds_file; % fMRI model specification: Multiple regressors - cfg_files
    inputs{11, crun} = mask_file; % fMRI model specification: Explicit mask - cfg_files
    inputs{12, crun} = 'RAIns PPI Interaction'; % Contrast Manager: Name - cfg_entry
    inputs{13, crun} = 1; % Contrast Manager: Weights vector - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
