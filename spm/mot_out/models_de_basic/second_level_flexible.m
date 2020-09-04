% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans - cfg_files
% Factorial design specification: Factor matrix - cfg_entry

my_config = ini2struct('../../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'mot_out');

subject_table = readtable(fullfile(analysis_dir, 'participants.csv'), ...
    'TextType', 'string');

level1dir = fullfile(analysis_dir, 'first_level');
subject_table.cs_plus = fullfile(level1dir, subject_table.subject + "_de", "con_0001.nii");
subject_table.cs_minus = fullfile(level1dir, subject_table.subject + "_de", "con_0003.nii");

% sort to put "friend" group before "stranger"
subject_table = sortrows(subject_table, {'group', 'subject'});

% create long-er form (1 row per con file)
st = stack(subject_table, {'cs_plus', 'cs_minus'}, ...
    'NewDataVariableName', 'conFile', 'IndexVariableName', 'condition');

% index factors in the table
st.subNo = grp2idx(st.subject);
st.grpNo = grp2idx(st.group);
st.conNo = grp2idx(st.condition);

% prepare the design matrix, with first column simply indexing cells
factors = st{:, {'subNo', 'grpNo', 'conNo'}};
factors = horzcat((1:length(factors))', factors);

scans = cellstr(st.conFile);

nrun = 1; % enter the number of runs here

% _interonly: no main effects, 1 interaction (group x condition)
out_dir = cellstr(fullfile(...
    analysis_dir, 'second_level', 'de_basic', 'flexible_factorial'));

jobs = {'second_level_flexible_job.m'};
inputs = cell(3, 1);

inputs{1, 1} = out_dir; % Factorial design specification: Directory - cfg_files
inputs{2, 1} = scans; % Factorial design specification: Scans - cfg_files
inputs{3, 1} = factors; % Factorial design specification: Factor matrix - cfg_entry

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
