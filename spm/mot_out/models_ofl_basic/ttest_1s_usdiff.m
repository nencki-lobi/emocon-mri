% Pooled US > noUS in OFL (1 sample t-test)

my_config = ini2struct('../../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'mot_out');

% select con files for CR (CS+ > CS-)
files = dir(fullfile(analysis_dir, 'first_level', '*_ofl', 'con_0009.nii'));  % us difference

% build a cellstring out of dir output
con_paths = cell(size(files));
for n = 1:size(files, 1)
    con_paths{n} = fullfile(files(n).folder, files(n).name);
end

out_dir = cellstr(fullfile(...
    analysis_dir, 'second_level', 'ofl_basic', 'US-noUS_1_sample'));

jobs = {'/Users/michal/Documents/emocon_mri_study/spm/mot_out/models_ofl_basic/ttest_1s_usdiff_job.m'};
inputs = cell(2, 1);

inputs{1, 1} = out_dir; % Factorial design specification: Directory - cfg_files
inputs{2, 1} = con_paths; % Factorial design specification: Scans - cfg_files

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
