my_config = ini2struct('../../config.ini');

spm_out_dir = my_config.spm.root;

model_dirs = cellstr(...
    spm_select(...
        'FpList', ...
        fullfile(spm_out_dir, 'allsub', 'level1_tmod1'), ...
        'dir', ...
        'sub-.*task-de' ...
        ) ...
    );

out = {'Nagery', 'Sytnks', 'Kjgixp', 'Yxjduz', 'Sbrgwt', 'Gyfxou', 'Svnpog'};
matches = regexp(model_dirs, 'sub-([A-Za-z]+)_task-de$', 'tokens', 'once');
is_out = zeros(size(model_dirs), 'logical');
for n = 1 : length(model_dirs)
    is_out(n) = ismember(matches{n}{1}, out);
end

model_dirs = model_dirs(~is_out);

% level 2 models should go here
level2dir = cellstr(fullfile(spm_out_dir, 'allsub', 'level2_de_xcl'));

% {open_input, nrun}
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans - cfg_files
% Contrast Manager: Name - cfg_entry
% Contrast Manager: Name - cfg_entry

inputs = {};  % clear to avoid conflicts with existing (larger) variables

inputs{1, 1} = fullfile(level2dir, 'tmod1_de_csdiff');
inputs{2, 1} = fullfile(model_dirs, 'con_0001.nii');
inputs{3, 1} = 'cs difference';
inputs{4, 1} = 'inverse cs difference';

inputs{1, 2} = fullfile(level2dir, 'tmod1_de_plus');
inputs{2, 2} = fullfile(model_dirs, 'con_0002.nii');
inputs{3, 2} = 'tmod cs+';
inputs{4, 2} = 'inverse tmod cs+';

inputs{1, 3} = fullfile(level2dir, 'tmod1_de_minus');
inputs{2, 3} = fullfile(model_dirs, 'con_0003.nii');
inputs{3, 3} = 'tmod cs-';
inputs{4, 3} = 'inverse tmod cs-';

inputs{1, 4} = fullfile(level2dir, 'tmod1_de_tmoddiff');
inputs{2, 4} = fullfile(model_dirs, 'con_0004.nii');
inputs{3, 4} = 'tmod difference (CS+t > CS-t)';
inputs{4, 4} = 'inv tmod difference (CS+t < CS-t)';


jobfile = {'second_level_1samp_job.m'};
jobs = repmat(jobfile, 1, size(inputs, 2));
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
