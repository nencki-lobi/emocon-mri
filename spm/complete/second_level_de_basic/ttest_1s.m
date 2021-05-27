% Second level 1 sample t-test (direct CR)

my_config = ini2struct('../../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'complete');

files = dir(fullfile(analysis_dir, 'first_level', '*_de', 'con_0005.nii'));
con_paths = fullfile({files.folder}', {files.name}');

jobfile = {'ttest_1s_job.m'};
jobs = repmat(jobfile, 1, 1);
inputs = cell(3, 1);

inputs{1, 1} = cellstr(fullfile(...
    analysis_dir, 'second_level', 'de_basic', 'CR_1sample')); % Factorial design specification: Directory - cfg_files
inputs{2, 1} = con_paths; % Factorial design specification: Scans - cfg_files
inputs{3, 1} = 'CR (pooled)'; % Contrast Manager: Name - cfg_entry

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
