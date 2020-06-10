% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans - cfg_files
% Contrast Manager: Name - cfg_entry

my_config = ini2struct('../../config.ini');

spm_out_dir = my_config.spm.root;

model_dirs = cellstr(...
    spm_select(...
        'FpList', ...
        fullfile(spm_out_dir, 'modulation', 'level1_pmod'), ...
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

inputs{1, 1} = fullfile(level2dir, 'pmod_de');
inputs{2, 1} = fullfile(model_dirs, 'con_0001.nii');
inputs{3, 1} = 'cs difference';

inputs{1, 2} = fullfile(level2dir, 'pmod_de_plus');
inputs{2, 2} = fullfile(model_dirs, 'con_0002.nii');
inputs{3, 2} = 'pmod cs+';

inputs{1, 3} = fullfile(level2dir, 'pmod_de_minus');
inputs{2, 3} = fullfile(model_dirs, 'con_0003.nii');
inputs{3, 3} = 'pmod cs-';

inputs{1, 4} = fullfile(level2dir, 'pmod_de_paramdiff');
inputs{2, 4} = fullfile(model_dirs, 'con_0004.nii');
inputs{3, 4} = 'param difference';

jobfile = {'second_level_pmod_job.m'};
jobs = repmat(jobfile, 1, size(inputs, 2));
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
