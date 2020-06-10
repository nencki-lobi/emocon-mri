% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans - cfg_files

my_config = ini2struct('../../config.ini');

spm_out_dir = my_config.spm.root;

% using recursive spm_select because only ofl should be there
[files, ~] = spm_select('FPListRec', ...
    fullfile(spm_out_dir, 'ppi', 'PPI_AINSxCSDIFF'), ... % misnamed in 1st levels :/
    'con_0001.nii');

% building the second level path
second_level_dir = fullfile(spm_out_dir, 'ppi', 'second_levels', ...
    'AINSxUSDIFF_1sample');

nrun = 1; % enter the number of runs here
jobfile = {'/Users/michal/Documents/emocon_mri_study/spm/ppi/level2_1samp_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(second_level_dir); % Factorial design specification: Directory - cfg_files
    inputs{2, crun} = cellstr(files); % Factorial design specification: Scans - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
