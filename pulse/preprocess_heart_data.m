% List of open inputs
% Preprocess heart data: Data File - cfg_files

my_config = ini2struct('../config.ini');
work_dir = fullfile(my_config.physio.pulse_deriv_dir, "prep");

my_files = dir(fullfile(work_dir, 'tpspm_*'));

nrun = length(my_files); % enter the number of runs here

jobfile = {'/Users/michal/Documents/emocon_mri_study/pulse/preprocess_heart_data_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    % Preprocess heart data: Data File - cfg_files
    inputs{1, crun} = cellstr(fullfile(my_files(crun).folder,...
                                       my_files(crun).name));
end
job_id = cfg_util('initjob', jobs);
sts    = cfg_util('filljob', job_id, inputs{:});
if sts
    cfg_util('run', job_id);
end
cfg_util('deljob', job_id);
