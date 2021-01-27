% OFL 2 sample t-test: (Friend US) vs (Stranger US)
% Comparison is based on US (i.e. stick contrasts are taken from 1st lvl)

% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Group 1 scans - cfg_files
% Factorial design specification: Group 2 scans - cfg_files

% con_0005 - US

% load the basics
my_config = ini2struct('../../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'mot_out');
subject_table = readtable(fullfile(analysis_dir, 'participants.csv'), ...
    'TextType', 'string');

% select subjects by group
sub_friend = subject_table(subject_table.group == "friend", :).subject;
sub_stranger = subject_table(subject_table.group == "stranger", :).subject;

% con file pattern - to select relevant contrast
con_pat = fullfile(analysis_dir, 'first_level', '%s_ofl', 'con_0005.nii');  % US

% specify outout directory
out_dir = cellstr(fullfile(...
    analysis_dir, 'second_level', 'ofl_basic', 'US_2_sample'));

% init structs for jobman
jobs = {'ttest_2s_us_job.m'};
inputs = cell(3, 1);

% fill in inputs
inputs{1, 1} = out_dir; % Factorial design specification: Directory - cfg_files
inputs{2, 1} = compose(con_pat, sub_friend); % Factorial design specification: Group 1 scans - cfg_files
inputs{3, 1} = compose(con_pat, sub_stranger); % Factorial design specification: Group 2 scans - cfg_files

% run the jobman
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
