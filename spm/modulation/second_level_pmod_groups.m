% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Group 1 scans - cfg_files
% Factorial design specification: Group 2 scans - cfg_files

my_config = ini2struct('../../config.ini');

spm_out_dir = my_config.spm.root;

% we want these subjects
subject_table = readtable(...
    fullfile(spm_out_dir, 'modulation', 'participants.csv'),...
    'TextType', 'string');

group_friend = subject_table(subject_table.group == "friend", :).code;
group_stranger = subject_table(subject_table.group == "stranger", :).code;

% level 2 models should go here
level2dir = cellstr(fullfile(spm_out_dir, 'modulation', 'level2'));

% level 1 files path spec (con 0002 is cs+ param)
level1spec = fullfile(spm_out_dir, 'modulation', 'level1_pmod', 'sub-%s_task-de', 'con_0002.nii');

% build the inputs for the batch
inputs{1, 1} = fullfile(level2dir, 'group_pmod_de_plus');
inputs{2, 1} = compose(level1spec, group_friend);
inputs{3, 1} = compose(level1spec, group_stranger);

jobfile = {'second_level_pmod_groups_job.m'};
jobs = repmat(jobfile, 1, size(inputs, 2));

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
