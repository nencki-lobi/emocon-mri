my_config = ini2struct('../../config.ini');

spm_out_dir = my_config.spm.root;

model_dirs = cellstr(...
    spm_select(...
        'FpList', ...
        fullfile(spm_out_dir, 'modulation', 'level1_tmod2'), ...
        'dir', ...
        'sub-.*task-de' ...
        ) ...
    );

% level 2 models should go here
level2dir = cellstr(fullfile(spm_out_dir, 'modulation', 'level2'));

% {open_input, nrun}
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans - cfg_files
% Contrast Manager: Name - cfg_entry
% Contrast Manager: Name - cfg_entry

inputs = {};  % clear to avoid conflicts with existing (larger) variables

inputs{1, 1} = fullfile(level2dir, 'tmod2_de_csdiff');
inputs{2, 1} = fullfile(model_dirs, 'con_0001.nii');
inputs{3, 1} = 'cs difference';
inputs{4, 1} = 'inverse cs difference';

inputs{1, 2} = fullfile(level2dir, 'tmod2_de_plus_linear');
inputs{2, 2} = fullfile(model_dirs, 'con_0002.nii');
inputs{3, 2} = 'tmod cs+ (linear)';
inputs{4, 2} = 'inverse tmod cs+ (linear)';

inputs{1, 3} = fullfile(level2dir, 'tmod2_de_plus_quadratic');
inputs{2, 3} = fullfile(model_dirs, 'con_0003.nii');
inputs{3, 3} = 'tmod cs+ (quadratic)';
inputs{4, 3} = 'inverse tmod cs+ (quadratic)';

inputs{1, 4} = fullfile(level2dir, 'tmod2_de_plus_all');
inputs{2, 4} = fullfile(model_dirs, 'con_0004.nii');
inputs{3, 4} = 'cs+ all (constant + linear + quadratic)';
inputs{4, 4} = 'inverse cs+ all';


jobfile = {'second_level_tmod_job.m'};
jobs = repmat(jobfile, 1, size(inputs, 2));
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
