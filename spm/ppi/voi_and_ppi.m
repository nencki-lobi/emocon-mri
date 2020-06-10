% List of open inputs
% Volume of Interest: Select SPM.mat - cfg_files
% Volume of Interest: Name of VOI - cfg_entry
% Volume of Interest: Image file - cfg_files
% Physio/Psycho-Physiologic Interaction: Select SPM.mat - cfg_files
% Physio/Psycho-Physiologic Interaction:  Input variables and contrast weights - cfg_entry
% Physio/Psycho-Physiologic Interaction: Name of PPI - cfg_entry

% path specs
my_config = ini2struct('../../config.ini');

spm_out_dir = my_config.spm.root;

subject_table = readtable(...
    fullfile(spm_out_dir, 'allsub', 'participants.csv'),...
    'TextType', 'string');

voi_mask = cellstr(fullfile( ...
    spm_out_dir, 'roi', 'R_S_circular_insula_ant.nii'));

nrun = height(subject_table); % enter the number of runs here

jobfile = {'/Users/michal/Documents/emocon_mri_study/spm/ppi/voi_and_ppi_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(6, nrun);
for crun = 1:nrun
    
    subject = subject_table.subject(crun);
    
    orig_spm = cellstr(fullfile( ...
        spm_out_dir, 'allsub', 'level1_tmod1', ...
            sprintf('sub-%s_task-%s', subject, 'ofl'), 'SPM.mat'));
    
    % Volume of Interest
    inputs{1, crun} = orig_spm; % Volume of Interest: Select SPM.mat - cfg_files
    inputs{2, crun} = 'R_S_Circular_Insula_Ant'; % Volume of Interest: Name of VOI - cfg_entry
    inputs{3, crun} = voi_mask; % Volume of Interest: Image file - cfg_files
    
    % Psycho-Physiologic Interaction
    inputs{4, crun} = orig_spm; % Physio/Psycho-Physiologic Interaction: Select SPM.mat - cfg_files
    inputs{5, crun} = [3 1 1; 4 1 -1]; % Physio/Psycho-Physiologic Interaction:  Input variables and contrast weights - cfg_entry
    inputs{6, crun} = 'AINSxCSDIFF'; % Physio/Psycho-Physiologic Interaction: Name of PPI - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
