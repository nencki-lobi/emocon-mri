% Second level 1 sample t-test (CS+ temporal modulator)

my_config = ini2struct('../../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'complete');

files = dir(fullfile(analysis_dir, 'first_level', '*_de', 'con_0002.nii'));
con_paths = fullfile({files.folder}', {files.name}');

jobfile = {'tmod_1sample_job.m'};
jobs = repmat(jobfile, 1, 1);
inputs = cell(4, 1);

inputs{1, 1} = cellstr(fullfile(...
    analysis_dir, 'second_level', 'de_extra', 'tmod_1sample')); % Factorial design specification: Directory - cfg_files
inputs{2, 1} = con_paths; % Factorial design specification: Scans - cfg_files
inputs{3, 1} = 'CS+ linear decrease'; % Contrast Manager: Name - cfg_entry
inputs{4, 1} = 'CS+ linear increase'; % Contrast Manager: Name - cfg_entry

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
