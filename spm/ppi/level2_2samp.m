% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Group 1 scans - cfg_files
% Factorial design specification: Group 2 scans - cfg_files

my_config = ini2struct('../../config.ini');

spm_out_dir = my_config.spm.root;

% we want these subjects
subject_table = readtable(...
    fullfile(spm_out_dir, 'allsub', 'participants.csv'),...
    'TextType', 'string');

group_friend = subject_table(subject_table.group == "friend", :).subject;
group_stranger = subject_table(subject_table.group == "stranger", :).subject;

% level 2 models should go here
second_level_dir = fullfile(spm_out_dir, 'ppi', 'second_levels', 'AINSxUSDIFF_2sample');

% 1st level con pattern - again, we live with a misspelling
con_pattern = fullfile(spm_out_dir, 'ppi', 'PPI_AINSxCSDIFF', 'sub-%s', 'con_0001.nii');

nrun = 1; % enter the number of runs here
jobfile = {'/Users/michal/Documents/emocon_mri_study/spm/ppi/level2_2samp_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(3, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(second_level_dir); % Factorial design specification: Directory - cfg_files
    inputs{2, crun} = compose(con_pattern, group_friend); % Factorial design specification: Group 1 scans - cfg_files
    inputs{3, crun} = compose(con_pattern, group_stranger); % Factorial design specification: Group 2 scans - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
