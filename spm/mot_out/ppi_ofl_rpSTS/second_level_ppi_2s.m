% second level with 2 sample t-test for the PPI

jobs = {'second_level_ppi_2s_job.m'};

my_config = ini2struct('../../../config.ini');

spm_out_dir = my_config.spm.root;
analysis_dir = fullfile(spm_out_dir, 'mot_out');

subject_table = readtable(fullfile(analysis_dir, 'participants.csv'), ...
    'TextType', 'string');
sub_friend = subject_table(subject_table.group == "friend", :).subject;
sub_stranger = subject_table(subject_table.group == "stranger", :).subject;

out_dir = fullfile(spm_out_dir, ...
    'mot_out', 'second_level', 'ppi_ofl_rpSTS', '2_sample');
con_pat = fullfile(analysis_dir, 'PPI_OFL_RPSTSxUS', 'sub-%s', 'con_0001.nii');

inputs = cell(3, 1);
inputs{1, 1} = cellstr(out_dir); % Factorial design specification: Directory - cfg_files
inputs{2, 1} = compose(con_pat, sub_friend); % Factorial design specification: Group 1 scans - cfg_files
inputs{3, 1} = compose(con_pat, sub_stranger); % Factorial design specification: Group 2 scans - cfg_files

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
