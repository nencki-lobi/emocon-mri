% PPI model for OFL

my_config = ini2struct('../../../config.ini');

% what goes where or from where
deriv_dir = my_config.default.deriv_dir;
msk_dir = fullfile(my_config.spm.root, 'brain_masks');
fl_dir  = fullfile(my_config.spm.root, "complete", "first_level");
tbl_dir = fullfile(my_config.spm.root, "complete", "other");
cfd_dir = fullfile(my_config.spm.root, "complete", "confounds");
ppi_dir = fullfile(my_config.spm.root, "complete", "ppi");

% analysis-specific variables
task = "ofl";                       % task name
ppi_file = "PPI_rTPJxUS.mat";       % name of PPI file
ppi_name = "PPI_ofl_rTPJxUS";       % name of output folder
psych_name = "US - noUS";           % name for PPI.P regressor
physio_name = "rTPJ BOLD";          % name for the PPI.Y regressor
ctr_name = "rTPJ PPI Interaction";  % name for the [1 0 0] contrast

% patterns for BIDS-derivatives file names
pat_smoothed = ...
    'sm6_sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';
pat_mask = 'sub-%s_task-%s_space-MNI152NLin2009cAsym_desc-brain_mask.nii';

% load subject table
subject_table = readtable(...
    fullfile(tbl_dir, 'included_participants.csv'), 'TextType', 'string');

% jobs specification
nrun = height(subject_table);
jobfile = {'../ppi_shared/ppi_model_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(13, nrun);
for crun = 1:nrun
    
    % these inputs refer to standard 1st level (same for all PPIs)
    subject = subject_table.label(crun);
    bold_path = cellstr(fullfile(...
        deriv_dir, "spm", "smooth", "sub-" + subject, ...
        sprintf(pat_smoothed, subject, task)));
    mask_path = cellstr(fullfile(...
        msk_dir, "sub-" + subject, sprintf(pat_mask, subject, task)));
    regressors_path = cellstr(fullfile(...
        cfd_dir, subject + "_" + task + ".mat"));
    
    % pecify range of volumes to use
    bold = nifti(bold_path);
    frames = subject_table.discard_volumes_ofl(crun) + 1 : bold.dat.dim(4);
    
    % PPI input file & output model directory
    ppi_input = load(fullfile(...
        fl_dir, subject + "_" + task, ppi_file));
    out_dir = cellstr(fullfile(...
        ppi_dir, ppi_name, "sub-" + subject));
   
    % fill in the inputs
    inputs{1, crun} = bold_path; % Expand image frames: NIfTI file(s) - cfg_files
    inputs{2, crun} = frames; % Expand image frames: Frames - cfg_entry
    inputs{3, crun} = out_dir; % fMRI model specification: Directory - cfg_files
    inputs{4, crun} = 'PPI Interaction'; % fMRI model specification: Name - cfg_entry
    inputs{5, crun} = ppi_input.PPI.ppi; % fMRI model specification: Value - cfg_entry
    inputs{6, crun} = char(physio_name); % fMRI model specification: Name - cfg_entry
    inputs{7, crun} = ppi_input.PPI.Y; % fMRI model specification: Value - cfg_entry
    inputs{8, crun} = char(psych_name); % fMRI model specification: Name - cfg_entry
    inputs{9, crun} = ppi_input.PPI.P; % fMRI model specification: Value - cfg_entry
    inputs{10, crun} = regressors_path; % fMRI model specification: Multiple regressors - cfg_files
    inputs{11, crun} = mask_path; % fMRI model specification: Explicit mask - cfg_files
    inputs{12, crun} = char(ctr_name); % Contrast Manager: Name - cfg_entry
    inputs{13, crun} = [1 0 0]; % Contrast Manager: Weights vector - cfg_entry
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
