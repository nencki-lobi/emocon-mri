% Second level 2 sample t-test (friend obs.US > stranger obs.US)

my_config = ini2struct('../../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'complete');

jobfile = {'ttest_2s_job.m'};
jobs = repmat(jobfile, 1, 1);
inputs = cell(3, 1);

subject_table = readtable(...
    fullfile(analysis_dir, 'other', 'included_participants.csv'), ...
    'TextType', 'string');

subject_table.con_files = fullfile(analysis_dir, "first_level", ...
    subject_table.label + "_ofl", "con_0003.nii");

% Factorial design specification: Directory - cfg_files
inputs{1, 1} = cellstr(fullfile(...
    analysis_dir, "second_level", "ofl_extra", "us_only_2sample"));

% Factorial design specification: Group 1 scans - cfg_files
inputs{2, 1} = cellstr(...
    subject_table{subject_table.group == "friend", "con_files"});

% Factorial design specification: Group 2 scans - cfg_files
inputs{3, 1} = cellstr(...
    subject_table{subject_table.group == "stranger", "con_files"});

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
