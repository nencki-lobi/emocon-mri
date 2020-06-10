% Run a 2-sample t-test with explicit masking.
%
% The script requires the mask to be created manually (currently no scripts
% for that)
%
% Contrasts:
% Friend US vs Stranger US masked by US > noUS
% ---

% get base path
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

% level 1 files path spec
level1_con07 = fullfile(spm_out_dir, 'modulation', 'level1_tmod1',...
    'sub-%s_task-ofl', 'con_0007.nii'); % us

% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Group 1 scans - cfg_files
% Factorial design specification: Group 2 scans - cfg_files
% Factorial design specification: Explicit Mask - cfg_files
jobfile = {'second_level_2sample_masked_job.m'};

inputs = {};
inputs{1, 1} = fullfile(level2dir, 'group_tmod2_us_masked'); % Factorial design specification: Directory - cfg_files
inputs{2, 1} = compose(level1_con07, group_friend); % Factorial design specification: Group 1 scans - cfg_files
inputs{3, 1} = compose(level1_con07, group_stranger); % Factorial design specification: Group 2 scans - cfg_files
inputs{4, 1} = fullfile(level2dir, 'tmod1_ofl_usdiff',...
    'us gt nous thresholded.nii'); % Factorial design specification: Explicit Mask - cfg_files

jobs = repmat(jobfile, 1, size(inputs, 2));

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
