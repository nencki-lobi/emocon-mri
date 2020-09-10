% second level with 1 sample (pooled) t-test for the PPI

my_config = ini2struct('../../../config.ini');

spm_out_dir = my_config.spm.root;

jobfile = {'second_level_ppi_1s_job.m'};
jobs = jobfile;
inputs = cell(3, 1);

out_dir = fullfile(spm_out_dir, ...
    'mot_out', 'second_level', 'ppi_de_insula', '1_sample');
[scans, ~] = spm_select(...
    'FPListRec', fullfile(spm_out_dir, 'mot_out', 'PPI_DE_AINSxCS'), ...
    'con_0001.nii');
ctr_name = 'AINS x CS';

inputs{1, 1} = cellstr(out_dir); % Factorial design specification: Directory - cfg_files
inputs{2, 1} = cellstr(scans); % Factorial design specification: Scans - cfg_files
inputs{3, 1} = ctr_name; % Contrast Manager: Name - cfg_entry

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
