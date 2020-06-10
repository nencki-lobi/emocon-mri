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
level2dir = cellstr(fullfile(spm_out_dir, 'allsub', 'level2_ofl'));

% level 1 files path spec
level1_con02 = fullfile(spm_out_dir, 'allsub', 'level1_tmod1',...
    'sub-%s_task-ofl', 'con_0002.nii'); % us > noUS
level1_con05 = fullfile(spm_out_dir, 'allsub', 'level1_tmod1',...
    'sub-%s_task-ofl', 'con_0005.nii'); % us tmod
level1_con07 = fullfile(spm_out_dir, 'allsub', 'level1_tmod1',...
    'sub-%s_task-ofl', 'con_0007.nii'); % us

% build the inputs for the batch
inputs = {};
c
inputs{1, 1} = fullfile(level2dir, 'group_tmod1_usdiff');
inputs{2, 1} = compose(level1_con02, group_friend);
inputs{3, 1} = compose(level1_con02, group_stranger);

inputs{1, 2} = fullfile(level2dir, 'group_tmod1_usparam');
inputs{2, 2} = compose(level1_con05, group_friend);
inputs{3, 2} = compose(level1_con05, group_stranger);

inputs{1, 3} = fullfile(level2dir, 'group_tmod1_us');
inputs{2, 3} = compose(level1_con07, group_friend);
inputs{3, 3} = compose(level1_con07, group_stranger);

jobfile = {'second_level_2samp_job.m'};  % same as pmod & de
jobs = repmat(jobfile, 1, size(inputs, 2));

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
