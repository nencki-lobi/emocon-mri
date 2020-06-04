% Export statistics for all subjects one-by-one
% The statistics need to be exported separately for each subject because
% the header is based on 1st subject only - this way, the table can be then
% reassembled eg. in R while taking care to keep trials assigned to correct
% conditions (pspm export preserves trial order).

% establish paths
my_config = ini2struct('../config.ini');
pspm_root = my_config.pspm.root;

% list files
listing = dir(fullfile(pspm_root, 'models_scr_dcm', '*.mat'));

% out dir
out_dir = fullfile(pspm_root, 'stats_scr_dcm');
if ~isfolder(out_dir)
    mkdir(out_dir);
end

nrun = length(listing); % enter the number of runs here
jobfile = {'/Users/michal/Documents/emocon_mri_study/pspm/dcm_batch_export_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);

for crun = 1:nrun
    inputs{1, crun} = cellstr(...
        fullfile(listing(crun).folder, listing(crun).name)); % Export Statistics: Model File(s) - cfg_files
    inputs{2, crun} = fullfile(out_dir, strrep(listing(crun).name, '.mat', '.tsv')); % Export Statistics: Filename - cfg_entry
end
job_id = cfg_util('initjob', jobs);
sts    = cfg_util('filljob', job_id, inputs{:});
if sts
    cfg_util('run', job_id);
end
cfg_util('deljob', job_id);
