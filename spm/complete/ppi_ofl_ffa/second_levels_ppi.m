% Secend levels for PPI - both 1 sample and 2 sample design

my_config = ini2struct('../../../config.ini');

% what goes where or from where
tbl_dir = fullfile(my_config.spm.root, "complete", "other");
ppi_dir = fullfile(my_config.spm.root, "complete", "ppi");
sl_dir  = fullfile(my_config.spm.root, "complete", "ppi_group");

% the only analysis-specific variables
ppi_name = "PPI_ofl_FFAxUS";  % used for folder names
ctr_name = "FFA x US";        % used for contrast manager

% load subject table
subject_table = readtable(...
    fullfile(tbl_dir, 'included_participants.csv'), 'TextType', 'string');

% build paths to con - for PPI this is con_0001
subject_table.con_files = fullfile(ppi_dir, ppi_name, ...
    "sub-" + subject_table.label, "con_0001.nii");

% the usual batch specification, using the above inputs - 1 run
jobfile = {'../ppi_shared/second_levels_ppi_job.m'};
jobs = repmat(jobfile, 1, 1);
inputs = cell(6, 1);

inputs{1, 1} = cellstr(fullfile(sl_dir, ppi_name, "1_sample")); % Factorial design specification: Directory - cfg_files
inputs{2, 1} = cellstr(subject_table.con_files); % Factorial design specification: Scans - cfg_files
inputs{3, 1} = char(ctr_name); % Contrast Manager: Name - cfg_entry
inputs{4, 1} = cellstr(fullfile(sl_dir, ppi_name, "2_sample")); % Factorial design specification: Directory - cfg_files
inputs{5, 1} = cellstr(...
    subject_table{subject_table.group == "friend", "con_files"}); % Factorial design specification: Group 1 scans - cfg_files
inputs{6, 1} = cellstr(...
    subject_table{subject_table.group == "stranger", "con_files"}); % Factorial design specification: Group 2 scans - cfg_files

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
