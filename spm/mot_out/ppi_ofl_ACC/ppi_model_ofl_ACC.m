% PPI model for ACC, ofl

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

jobfile = {'ppi_model_ofl_ACC_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(7, nrun);
for crun = 1:nrun
    
    subject = subject_table.subject(crun);
    bold_path = fullfile( ...
        deriv_dir, 'spm', 'smooth', strcat('sub-', subject), ...
        sprintf(pat_smoothed, subject, 'ofl'));
    mask_path = cellstr(fullfile( ...
        spm_out_dir, 'brain_masks', strcat('sub-', subject), ...
        sprintf(pat_mask, subject, 'ofl')));
    regressors_path = cellstr(fullfile( ...
        analysis_dir, 'confounds', strcat(subject, '_ofl.mat')));
    ppi_file = fullfile(...
        analysis_dir, 'first_level', strcat(subject, '_ofl'), ...
        'PPI_ACCxUSDIFF.mat');
    out_dir = cellstr(fullfile( ...
        analysis_dir, 'PPI_OFL_ACCxUS', strcat('sub-', subject)));
    
    bold_files = spm_select('expand', bold_path); % apparently needed
    bold_files = ...
        bold_files(1 + subject_table.discard_volumes_ofl(crun):end, :);
    
    load(ppi_file)  % contains PPI variable

    inputs{1, crun} = out_dir; % fMRI model specification: Directory - cfg_files
    inputs{2, crun} = bold_files; % fMRI model specification: Scans - cfg_files
    inputs{3, crun} = PPI.ppi; % fMRI model specification: Value - cfg_entry
    inputs{4, crun} = PPI.Y; % fMRI model specification: Value - cfg_entry
    inputs{5, crun} = PPI.P; % fMRI model specification: Value - cfg_entry
    inputs{6, crun} = regressors_path; % fMRI model specification: Multiple regressors - cfg_files
    inputs{7, crun} = mask_path; % fMRI model specification: Explicit mask - cfg_files
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
