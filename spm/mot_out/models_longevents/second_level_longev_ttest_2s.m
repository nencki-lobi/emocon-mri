% Pooled CS+>CS- in DE (2 sample t-test: friend vs stranger)

my_config = ini2struct('../../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'mot_out');
subject_table = readtable(fullfile(analysis_dir, 'participants.csv'), ...
    'TextType', 'string');

sub_friend = subject_table(subject_table.group == "friend", :).subject;
sub_stranger = subject_table(subject_table.group == "stranger", :).subject;

con_pat = fullfile(analysis_dir, 'first_level_longevent', '%s_de', 'con_0003.nii');  % CS+ - CS-

out_dir = cellstr(fullfile(...
    analysis_dir, 'second_level', 'longevent', 'CR_2s'));

jobs = {'second_level_longev_ttest_2s_job.m'};
inputs = cell(3, 1);

inputs{1, 1} = out_dir; % Factorial design specification: Directory - cfg_files
inputs{2, 1} = compose(con_pat, sub_friend); % Factorial design specification: Group 1 scans - cfg_files
inputs{3, 1} = compose(con_pat, sub_stranger); % Factorial design specification: Group 2 scans - cfg_files

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
