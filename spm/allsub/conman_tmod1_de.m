% Create contrasts for de with temporal modulation

my_config = ini2struct('../../config.ini');

deriv_dir = my_config.default.deriv_dir;
spm_out_dir = my_config.spm.root;

model_dirs = cellstr(...
    spm_select(...
        'FpList', ...
        fullfile(spm_out_dir, 'allsub', 'level1_tmod1'), ...
        'dir', ...
        'sub-.*task-de' ...
        ) ...
    );

nrun = length(model_dirs);

jobfile = {'conman_tmod1_de_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    % Contrast Manager: Select SPM.mat - cfg_files
    inputs{1, crun} = fullfile(model_dirs(crun), 'SPM.mat');
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
