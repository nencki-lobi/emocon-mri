% Pooled early CR (CS+>CS-) in DE (1 sample t-test)

my_config = ini2struct('../../../config.ini');
analysis_dir = fullfile(my_config.spm.root, 'mot_out');

% con_0003 is the CR [1 0 -1 0]
files = dir(fullfile(analysis_dir, 'first_level_longevent', '*_de', 'con_0003.nii'));

con_paths = cell(size(files));
for n = 1:size(files, 1)
    con_paths{n} = fullfile(files(n).folder, files(n).name);
end

out_dir = fullfile(analysis_dir, 'second_level', 'longevent', 'CR_1s');

nrun = 1;
jobfile = {'second_level_longev_ttest_1s_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(out_dir); % Factorial design specification: Directory - cfg_files
    inputs{2, crun} = con_paths; % Factorial design specification: Scans - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
