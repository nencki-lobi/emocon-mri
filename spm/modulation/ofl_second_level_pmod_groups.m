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
level2dir = cellstr(fullfile(spm_out_dir, 'modulation', 'ofl_level2'));

% level 1 files path spec (con 0003 is cs+ param)
level1spec = fullfile(spm_out_dir, 'modulation', 'level1_pmod', 'sub-%s_task-ofl', 'con_0003.nii');

% build the inputs for the batch
inputs{1, 1} = fullfile(level2dir, 'group_pmod_ofl_csplus');
inputs{2, 1} = compose(level1spec, group_friend);
inputs{3, 1} = compose(level1spec, group_stranger);

% level 1 files path spec (con 0005 is us present)
level1spec = fullfile(spm_out_dir, 'modulation', 'level1_pmod', 'sub-%s_task-ofl', 'con_0005.nii');

% inputs for 2nd batch cycle
inputs{1, 2} = fullfile(level2dir, 'grup_pmod_ofl_us');
inputs{2, 2} = compose(level1spec, group_friend);
inputs{3, 2} = compose(level1spec, group_stranger);

% reusing jobfile from de - this is generic 2nd level with 2 sample ttest
jobfile = {'second_level_pmod_groups_job.m'};
jobs = repmat(jobfile, 1, size(inputs, 2));

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
