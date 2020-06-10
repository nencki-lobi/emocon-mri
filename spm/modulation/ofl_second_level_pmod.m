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
        'sub-.*task-ofl' ...
        ) ...
    );

% level 2 models should go here
level2dir = cellstr(fullfile(spm_out_dir, 'modulation', 'ofl_level2'));

% {open_input, nrun}
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans - cfg_files
% Contrast Manager: Name - cfg_entry

inputs{1, 1} = fullfile(level2dir, 'pmod_ofl_cs');
inputs{2, 1} = fullfile(model_dirs, 'con_0001.nii');
inputs{3, 1} = 'cs difference';

inputs{1, 2} = fullfile(level2dir, 'pmod_ofl_us');
inputs{2, 2} = fullfile(model_dirs, 'con_0002.nii');
inputs{3, 2} = 'us difference';

inputs{1, 3} = fullfile(level2dir, 'pmod_ofl_param_csplus');
inputs{2, 3} = fullfile(model_dirs, 'con_0003.nii');
inputs{3, 3} = 'param cs+';

inputs{1, 4} = fullfile(level2dir, 'pmod_ofl_param_csminus');
inputs{2, 4} = fullfile(model_dirs, 'con_0004.nii');
inputs{3, 4} = 'param cs-';

inputs{1, 5} = fullfile(level2dir, 'pmod_ofl_param_us');
inputs{2, 5} = fullfile(model_dirs, 'con_0005.nii');
inputs{3, 5} = 'param us';

inputs{1, 6} = fullfile(level2dir, 'pmod_ofl_paramdiff_cs');
inputs{2, 6} = fullfile(model_dirs, 'con_0006.nii');
inputs{3, 6} = 'param difference (cs)';

jobfile = {'second_level_pmod_job.m'};
jobs = repmat(jobfile, 1, size(inputs, 2));
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
