% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans - cfg_files
% Contrast Manager: Name - cfg_entry

my_config = ini2struct('../../config.ini');

spm_out_dir = my_config.spm.root;

model_dirs = cellstr(...
    spm_select(...
        'FpList', ...
        fullfile(spm_out_dir, 'modulation', 'level1_tmod1'), ...
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

inputs{1, 1} = fullfile(level2dir, 'tmod1_ofl_csdiff');
inputs{2, 1} = fullfile(model_dirs, 'con_0001.nii');
inputs{3, 1} = 'cs difference (cs+ > cs-)';
inputs{4, 1} = 'inverse cs difference (cs+ < cs-)';

inputs{1, 2} = fullfile(level2dir, 'tmod1_ofl_usdiff');
inputs{2, 2} = fullfile(model_dirs, 'con_0002.nii');
inputs{3, 2} = 'us difference (us > no us)';
inputs{4, 2} = 'inverse us difference (us < no us)';

inputs{1, 3} = fullfile(level2dir, 'tmod1_ofl_plus');
inputs{2, 3} = fullfile(model_dirs, 'con_0003.nii');
inputs{3, 3} = 'tmod cs+';
inputs{4, 3} = 'inverse tmod cs+';

inputs{1, 4} = fullfile(level2dir, 'tmod1_ofl_minus');
inputs{2, 4} = fullfile(model_dirs, 'con_0004.nii');
inputs{3, 4} = 'tmod cs-';
inputs{4, 4} = 'inverse tmod cs-';

inputs{1, 5} = fullfile(level2dir, 'tmod1_ofl_us');
inputs{2, 5} = fullfile(model_dirs, 'con_0005.nii');
inputs{3, 5} = 'tmod us';
inputs{4, 5} = 'inverse tmod us';

inputs{1, 6} = fullfile(level2dir, 'tmod1_ofl_paramdiff');
inputs{2, 6} = fullfile(model_dirs, 'con_0006.nii');
inputs{3, 6} = 'tmod difference (cs)';
inputs{4, 6} = 'inverse tmod difference (cs)';

jobfile = {'second_level_tmod_job.m'};  % reusing the DE batch
jobs = repmat(jobfile, 1, size(inputs, 2));
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
