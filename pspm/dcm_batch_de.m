% Pspm batch/script to run OFL first level (nonlinear model)

% establish paths
my_config = ini2struct('../config.ini');
bids_root = my_config.default.bids_root;
pspm_root = my_config.pspm.root;

nrun = 1; % enter the number of runs here
jobfile = {'dcm_batch_de_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(7, nrun);

subject = "Nagery";

for crun = 1:nrun
    
    model_name = "sub-" + subject + "_task-de";
    out_dir = fullfile(pspm_root, "models_scr_dcm");
    
    data_file = fullfile(pspm_root, ...
        "scr", "tpspm_" + upper(subject) + "_de.mat");
    timing_file = fullfile(pspm_root, ...
        "events_scr_dcm", "sub-" + subject + "_task-de_events.mat");
    epochs_file = fullfile(pspm_root, ...
        "missing_epochs_scr", "tpspm_" + upper(subject) + "_de_artefacts.mat");
    
    if ~isfile(epochs_file)
        epochs_file = fullfile(pspm_root, ...
            "missing_epochs_scr", "empty.mat");
    end
    
    eventinfo = get_condition_info(fullfile(...
        bids_root, ...
        "sub-" + subject, "func", ...
        "sub-" + subject + "_task-de_events.tsv"));
    
    inputs{1, crun} = convertStringsToChars(model_name); % Non-Linear Model: Model Filename - cfg_entry
    inputs{2, crun} = cellstr(out_dir); % Non-Linear Model: Output Directory - cfg_files
    inputs{3, crun} = cellstr(data_file); % Non-Linear Model: Data File - cfg_files
    inputs{4, crun} = cellstr(timing_file); % Non-Linear Model: Timing File - cfg_files
    inputs{5, crun} = eventinfo.index.cs_plus; % Non-Linear Model: Index - cfg_entry
    inputs{6, crun} = eventinfo.index.cs_minus; % Non-Linear Model: Index - cfg_entry
    inputs{7, crun} = cellstr(epochs_file); % Non-Linear Model: Missing Epoch File - cfg_files
end

pspm_init
pspm_jobman('initcfg')

job_id = cfg_util('initjob', jobs);
sts    = cfg_util('filljob', job_id, inputs{:});
if sts
    cfg_util('run', job_id);
end
cfg_util('deljob', job_id);
