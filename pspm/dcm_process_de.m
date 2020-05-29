function dcm_process_de(subject)
%DCM_PROCESS_DE Function to run DE batch in noninteractive mode
%   Should have contents equivalent to dcm_batch_de

% establish paths
my_config = ini2struct('../config.ini');
bids_root = my_config.default.bids_root;
pspm_root = my_config.pspm.root;

% create shells of jobs & inputs
nrun = 1;
jobfile = {'dcm_batch_de_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(7, nrun);

% figure out what inputs are
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

% fill in the inputs
inputs{1, 1} = convertStringsToChars(model_name); % Non-Linear Model: Model Filename - cfg_entry
inputs{2, 1} = cellstr(out_dir); % Non-Linear Model: Output Directory - cfg_files
inputs{3, 1} = cellstr(data_file); % Non-Linear Model: Data File - cfg_files
inputs{4, 1} = cellstr(timing_file); % Non-Linear Model: Timing File - cfg_files
inputs{5, 1} = eventinfo.index.cs_plus; % Non-Linear Model: Index - cfg_entry
inputs{6, 1} = eventinfo.index.cs_minus; % Non-Linear Model: Index - cfg_entry
inputs{7, 1} = cellstr(epochs_file); % Non-Linear Model: Missing Epoch File - cfg_files

% initialise pspm
pspm_init
pspm_jobman('initcfg')

% run using jobman
job_id = cfg_util('initjob', jobs);
sts    = cfg_util('filljob', job_id, inputs{:});
if sts
    cfg_util('run', job_id);
end
cfg_util('deljob', job_id);


end

