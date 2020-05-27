% create event files to be used with pspm dcm for skin conductance
%
% For OFL, describe CS onset as variable, US onset as fixed response,
% and for DE describe CS onset as variable response.

% establish paths
my_config = ini2struct('../config.ini');
bids_root = my_config.default.bids_root;
pspm_root = my_config.pspm.root;

% Stimulus Onset Asynchrony: US was always 7.5 s after CS
SOA = 7.5;

subject = "Aflqrp";

% OFL
event_tab = readtable(...
    fullfile(bids_root, ...
        "sub-" + subject, ...
        "func", ...
        "sub-" + subject + "_task-ofl_events.tsv"), ...
    'FileType', 'text', 'TextType', 'string');

cs_onset = event_tab{startsWith(event_tab.trial_type, 'cs_'), 'onset'};
us_onset = cs_onset + SOA;

events = cell(1, 2);
events{1} = [cs_onset us_onset];
events{2} = us_onset;

save(fullfile(pspm_root, "events_scr_dcm/sub-" + subject + '_task-ofl_events.mat'), ...
    'events');

% DE
event_tab = readtable(...
    fullfile(bids_root, ...
        "sub-" + subject, ...
        "func", ...
        "sub-" + subject + "_task-de_events.tsv"), ...
    'FileType', 'text', 'TextType', 'string');

cs_onset = event_tab{startsWith(event_tab.trial_type, 'cs_'), 'onset'};
us_onset = cs_onset + SOA;  % no US, but keep time window consistent

events = cell(1, 1);
events{1} = [cs_onset, us_onset];

save(fullfile(pspm_root, "events_scr_dcm/sub-" + subject + '_task-de_events.mat'), ...
    'events');
