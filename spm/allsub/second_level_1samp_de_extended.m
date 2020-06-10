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

% put the dirs into a table and extract last part
mytab = table(model_dirs);
path_parts = split(model_dirs, filesep);
mytab.bids_name = string(path_parts(:, end));

% load QC metrics
qc_metrics = tdfread(fullfile(my_config.default.deriv_dir, 'mriqc', 'group_bold.tsv'));
fd_table = table(qc_metrics.bids_name, qc_metrics.fd_mean, 'VariableNames', {'bids_name', 'fd_mean'});
fd_table.bids_name = deblank(string(fd_table.bids_name));
fd_table.bids_name = replace(fd_table.bids_name, '_bold', '');

% use join to combine folder names and qc metrics without worrying about
% order
result = join(mytab, fd_table);


level2dir = cellstr(fullfile(spm_out_dir, 'allsub', 'level2_de'));


inputs = {};

inputs{1, 1} = fullfile(level2dir, 'de_csdiff_with_covariate'); % Factorial design specification: Directory - cfg_files
inputs{2, 1} = fullfile(result.model_dirs, 'con_0001.nii'); % Factorial design specification: Scans - cfg_files
inputs{3, 1} = result.fd_mean; % Factorial design specification: Vector - cfg_entry
inputs{4, 1} = 'MeanFD'; % Factorial design specification: Name - cfg_entry
inputs{5, 1} = 'cs_difference'; % Contrast Manager: Name - cfg_entry
inputs{6, 1} = 'inverse cs difference'; % Contrast Manager: Name - cfg_entry

inputs{1, 2} = fullfile(level2dir, 'de_cspxt_with_covariate'); % Factorial design specification: Directory - cfg_files
inputs{2, 2} = fullfile(result.model_dirs, 'con_0002.nii'); % Factorial design specification: Scans - cfg_files
inputs{3, 2} = result.fd_mean; % Factorial design specification: Vector - cfg_entry
inputs{4, 2} = 'MeanFD'; % Factorial design specification: Name - cfg_entry
inputs{5, 2} = 'cs+ tmod'; % Contrast Manager: Name - cfg_entry
inputs{6, 2} = 'inverse cs+ tmod'; % Contrast Manager: Name - cfg_entry

jobfile = {'second_level_1samp_cov_job.m'};
jobs = repmat(jobfile, 1, size(inputs, 2));

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});