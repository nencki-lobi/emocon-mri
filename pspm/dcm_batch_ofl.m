% Pspm batch/script to run OFL first level (nonlinear model)

% establish paths
my_config = ini2struct('../config.ini');
bids_root = my_config.default.bids_root;
pspm_root = my_config.pspm.root;

% load subjects
tab = readtable(fullfile(my_config.pspm.root, 'participants.csv'), ...
    'TextType', 'string');

% load subjects to be processed
% this annotation was made manually, based on which data files caused no
% problems for processing (artefact removal, overall recording present)
to_process = readtable(fullfile(my_config.pspm.root, 'process_scr.tsv'), ...
    'FileType', 'text', 'TextType', 'string');
to_process.label = extractBefore(to_process.label, 2) ...
    + lower(extractAfter(to_process.label, 1));  % capitalise

% limit analysis to process-able subjects
tab = join(tab, to_process);
tab = tab(tab.process == "YES", :);

% further limit analysis to CA friend - not sure how long it takes
tab = tab(tab.group == "friend" & tab.contingency=="True", :);

nrun = height(tab); % enter the number of runs here
jobfile = {'dcm_batch_ofl_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(8, nrun);

for crun = 1:nrun
    subject = tab.label(crun);
    
    model_name = "sub-" + subject + "_task-ofl";
    out_dir = fullfile(pspm_root, "models_scr_dcm");
    
    data_file = fullfile(pspm_root, ...
        "scr", "tpspm_" + upper(subject) + "_ofl.mat");
    timing_file = fullfile(pspm_root, ...
        "events_scr_dcm", "sub-" + subject + "_task-ofl_events.mat");
    epochs_file = fullfile(pspm_root, ...
        "missing_epochs_scr", "tpspm_" + upper(subject) + "_ofl_artefacts.mat");


    if ~isfile(epochs_file)
        epochs_file = fullfile(pspm_root, ...
            "missing_epochs_scr", "empty.mat");
    end
    
    eventinfo = get_condition_info(fullfile(...
        bids_root, ...
        "sub-" + subject, "func", ...
        "sub-" + subject + "_task-ofl_events.tsv"));

    
    inputs{1, crun} = convertStringsToChars(model_name); % Non-Linear Model: Model Filename - cfg_entry
    inputs{2, crun} = cellstr(out_dir); % Non-Linear Model: Output Directory - cfg_files
    inputs{3, crun} = cellstr(data_file); % Non-Linear Model: Data File - cfg_files
    inputs{4, crun} = cellstr(timing_file); % Non-Linear Model: Timing File - cfg_files
    inputs{5, crun} = eventinfo.index.cs_plus_reinforced; % Non-Linear Model: Index - cfg_entry (CS+r)
    inputs{6, crun} = eventinfo.index.cs_plus_nonreinforced; % Non-Linear Model: Index - cfg_entry (CS+nr)
    inputs{7, crun} = eventinfo.index.cs_minus; % Non-Linear Model: Index - cfg_entry (CS-)
    inputs{8, crun} = cellstr(epochs_file); % Non-Linear Model: Missing Epoch File - cfg_files
end

pspm_init
pspm_jobman('initcfg')

job_id = cfg_util('initjob', jobs);
sts    = cfg_util('filljob', job_id, inputs{:});
if sts
    cfg_util('run', job_id);
end
cfg_util('deljob', job_id);
