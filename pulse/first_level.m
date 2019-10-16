% List of open inputs
% GLM for HP (fear-conditioning): Model Filename - cfg_entry
% GLM for HP (fear-conditioning): Output Directory - cfg_files
% GLM for HP (fear-conditioning): Data File - cfg_files
% GLM for HP (fear-conditioning): Condition File - cfg_files

my_config = ini2struct('../config.ini');

work_dir = my_config.physio.pulse_deriv_dir;

my_files = dir(fullfile(work_dir, 'models', 'tpspm_*'));

nrun = length(my_files); % enter the number of runs here
jobfile = {'/Users/michal/Documents/emocon_mri_study/pulse/first_level_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(4, nrun);
for crun = 1:nrun
    
    m = regexp(my_files(crun).name, 'sub-([A-Za-z]*)_', 'tokens', 'once');
    code = m{1};
    
    data_file = my_files(crun).name;
    cond_file = sprintf("sub-%s_task-de_pspmevents.mat", code);
    
    model_dir = fullfile(work_dir, "models", code);
    if ~isfolder(model_dir)
        mkdir(model_dir)
    end
    
    inputs{1, crun} = char(strcat(code, "_HPR")); % GLM for HP (fear-conditioning): Model Filename - cfg_entry
    inputs{2, crun} = cellstr(model_dir); % GLM for HP (fear-conditioning): Output Directory - cfg_files
    inputs{3, crun} = cellstr(fullfile(work_dir, "prep", data_file)); % GLM for HP (fear-conditioning): Data File - cfg_files
    inputs{4, crun} = cellstr(fullfile(work_dir, "prep", cond_file)); % GLM for HP (fear-conditioning): Condition File - cfg_files
end
job_id = cfg_util('initjob', jobs);
sts    = cfg_util('filljob', job_id, inputs{:});
if sts
    cfg_util('run', job_id);
end
cfg_util('deljob', job_id);
