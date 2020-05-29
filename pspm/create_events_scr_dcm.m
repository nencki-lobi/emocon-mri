% Create event files to be used with pspm dcm for skin conductance
%
% For OFL, describe CS onset as variable, US onset as fixed response,
% and for DE describe CS onset as variable response.

% establish paths
my_config = ini2struct('../config.ini');
bids_root = my_config.default.bids_root;
pspm_root = my_config.pspm.root;

% load subjects
tab = readtable(fullfile(my_config.pspm.root, 'participants.csv'), ...
    'TextType', 'string');

% Stimulus Onset Asynchrony: US was always 7.5 s after CS
SOA = 7.5;

for n = 1:height(tab)
    
    subject = tab.label(n);

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

    fname = "sub-" + subject + '_task-ofl_events.mat';
    save(fullfile(pspm_root, "events_scr_dcm", fname), 'events')

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

    fname = "sub-" + subject + '_task-de_events.mat';
    save(fullfile(pspm_root, "events_scr_dcm", fname), 'events');

end
