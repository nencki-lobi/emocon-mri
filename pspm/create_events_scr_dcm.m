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
event_tab = read_event_table(fullfile(...
    bids_root, ...
    "sub-" + subject, ...
    "func", ...
    "sub-" + subject + "_task-ofl_events.tsv"));

cs_onset = event_tab{startsWith(event_tab.trial_type, 'cs_'), 'onset'};
us_onset = cs_onset + SOA;

events{1} = [cs_onset us_onset];
events{2} = us_onset;

% TODO save in the right place
save('/Volumes/Transcend/emocon_mri/pspm/events_scr_dcm/sub-Aflqrp_task-ofl_events.mat', ...
    'events');

% DE
events = cell(1);  % avoid copying OFL events
event_tab = read_event_table(fullfile(...
    bids_root, ...
    "sub-" + subject, ...
    "func", ...
    "sub-" + subject + "_task-de_events.tsv"));

cs_onset = event_tab{startsWith(event_tab.trial_type, 'cs_'), 'onset'};
us_onset = cs_onset + SOA  % no US, but keep time window consistent

events{1} = [cs_onset, us_onset];

% --- cut below --- 
% probably I'll put it in a function which returns a struct ?\_(?)_/?

trial_idx = 1;
idx_cspr = [];
idx_csp = [];
idx_csm = [];

for n = 1:height(event_tab)
    if event_tab.trial_type(n) == "cs_plus" && event_tab.trial_type(n+1) == "us"
        % last cs+ always reinforced, so won't go OOB
        idx_cspr(end+1) = trial_idx;
        trial_idx = trial_idx + 1;
    elseif event_tab.trial_type(n) == "cs_plus"
        idx_csp(end+1) = trial_idx;
        trial_idx = trial_idx + 1;
    elseif event_tab.trial_type(n) == "cs_minus"
        idx_csm(end+1) = trial_idx;
        trial_idx = trial_idx + 1;
    end
end

weights_us = zeros(length(cs_onset), 1);  % shouldn't be horizontal?
weights_us(idx_cspr) = 1;
weights_us(idx_csp) = -1;

weights_cs = ones(length(cs_onset), 1);
weights_cs(idx_csm) = -1;

% --- cut below ---
cs_trials = event_tab{startsWith(event_tab.trial_type, "cs"), "trial_type"}';
idx_csp = find(cs_trials == "cs_plus");
idx_csm = find(cs_trials == "cs_minus");

weights_cs = ones(1, length(cs_trials));
weights_cs(1, idx_csm) = -1;

