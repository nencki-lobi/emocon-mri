% List of open inputs
% Export Statistics: Model File(s) - cfg_files
% Export Statistics: Filename - cfg_entry

% TODO: add column with subjects to the file written by PsPM

my_config = ini2struct('../config.ini');

work_dir = my_config.physio.pulse_deriv_dir;

my_files = dir(fullfile(work_dir, 'models', '*', '*_HPR.mat'));
model_files = cell(size(my_files));
for n = 1:length(my_files)
    model_files{n} = fullfile(my_files(n).folder, my_files(n).name);
end

out_dir = fullfile(work_dir, 'stats');
if ~exist(out_dir, 'dir')
    mkdir(out_dir)
end
out_file = fullfile(out_dir, 'params.tsv');

nrun = 1; % enter the number of runs here
jobfile = {'/Users/michal/Documents/emocon_mri_study/pulse/export_stats_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = model_files; % Export Statistics: Model File(s) - cfg_files
    inputs{2, crun} = out_file; % Export Statistics: Filename - cfg_entry
end
job_id = cfg_util('initjob', jobs);
sts    = cfg_util('filljob', job_id, inputs{:});
if sts
    cfg_util('run', job_id);
end
cfg_util('deljob', job_id);
