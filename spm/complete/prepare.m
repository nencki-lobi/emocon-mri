% Prepare events, confounds, and a participant list for SPM.

my_config = ini2struct('../../config.ini');

confounds_pattern = fullfile(my_config.default.deriv_dir, ...
    'fmriprep', 'sub-%1$s', 'func', ...
    'sub-%1$s_task-%2$s_desc-confounds_regressors.tsv');

% initialise bids layout - requires matlab-bids on path
b = bids.layout(my_config.default.bids_root);

% fetch participant info
df = readtable(...
    fullfile(my_config.default.questionnaire_dir, 'table.tsv'), ...
    'FileType', 'text', 'Delimiter', '\t', 'TextType', 'string');
df = df(:, {'label', 'group', 'CONT_contingency'});

% limit further processing to contingency-knowing subjects
df = df(df.CONT_contingency == "YES", :);

% Extract events & store number of datapoints to trim
for n = 1:height(df)
    ofl_events_file = bids.query(b, 'data', 'sub', df.label(n), ...
        'task', 'ofl', 'type', 'events');
    de_events_file = bids.query(b, 'data', 'sub', df.label(n), ...
        'task', 'de', 'type', 'events');  % 1x1 cell
   
    [n_discard, events_ofl] = get_ofl_events(ofl_events_file{1});
    events_de = get_de_events(de_events_file{1});
    
    df.discard_volumes_ofl(n) = n_discard;
    df.events_ofl(n) = events_ofl;
    df.events_de(n) = events_de;
end

% Extract confounds for each subject & count motion outlier columns
for n = 1:height(df)
    label = df.label(n);
    
    df.confounds_ofl(n) = extract_confounds(...
        sprintf(confounds_pattern, label, 'ofl'), ...
        df.discard_volumes_ofl(n));
    df.motion_ofl(n) = size(df.confounds_ofl(n).R, 2) - 6;
    
    df.confounds_de(n) = extract_confounds(...
        sprintf(confounds_pattern, label, 'de'), 0);
    df.motion_de(n) = size(df.confounds_de(n).R, 2) - 6;
    
end

% keep number of motion outliers for all subjects for further reference
motion_table = df(:, {'label', 'group', 'motion_ofl', 'motion_de'});

% exclude subjects with excessive motion outliers from further processing
%  90 & 45 volumes correspond roughly to 25 percent volumes; in practice
%  this excludes one subject, who is a clear outlier
df(df.motion_ofl > 90 | df.motion_de > 45, :) = []; 

% keep included participants & number of leading volumes to throw away
trim_table = df(:, {'label', 'group', 'discard_volumes_ofl'});

% make output directories (if not exist)
analysis_dir = fullfile(my_config.spm.root, 'complete');
status = mkdir(analysis_dir);
status = mkdir(analysis_dir, 'confounds');
status = mkdir(analysis_dir, 'events');
status = mkdir(analysis_dir, 'other');

% save tables for further reference
writetable(motion_table, ...
    fullfile(analysis_dir, "other", "motion_outliers.csv"));
writetable(trim_table, ...
    fullfile(analysis_dir, "other", "included_participants.csv"));

% save events and regressors files
for n = 1:height(df)
    s1 = df.confounds_ofl(n);
    s2 = df.confounds_de(n);
    s3 = df.events_ofl(n);
    s4 = df.events_de(n);
    
    save(fullfile(analysis_dir, "confounds", df.label(n) + "_ofl"), ...
        '-struct', 's1');
    save(fullfile(analysis_dir, "confounds", df.label(n) + "_de"), ...
        '-struct', 's2');
    save(fullfile(analysis_dir, "events", df.label(n) + "_ofl"), ...
        '-struct', 's3');
    save(fullfile(analysis_dir, "events", df.label(n) + "_de"), ...
        '-struct', 's4');
end

function confounds = extract_confounds(filename, trim_start)
    rp_names = {'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z'};
    
    confounds = readtable(filename, 'FileType', 'text', 'Delimiter', '\t');
    
    % find which columns contain motion outliers
    mo_cols = startsWith(confounds.Properties.VariableNames, ...
        'motion_outlier');  % may be empty, which is still fine
    mo_names = confounds.Properties.VariableNames(mo_cols);
    mo_names = strrep(mo_names, '_', '');
    
    % get movement (rp) and motion outlier (mo) columns
    rp = confounds{trim_start+1:end, rp_names}; % name indexing for columns
    mo = confounds{trim_start+1:end, mo_cols};  % logical indexing for columns

    confounds = struct();
    confounds.R = [rp mo];
    confounds.names = [rp_names, mo_names];
end

function [n_tr, events] = get_ofl_events(fname)

    TR = 2.87;

    % load and clear event table
    t = readtable(fname, ...
        'FileType', 'text', 'Delimiter', '\t', 'TextType', 'string');
    t.value = [];
    t.trial_type = strrep(t.trial_type, '_', ' ');

    % Shift onsets and report discarded TRs if necessary
    if t.onset(1) > 3 * TR
        % first event is fix, so trim if that is later than 3 TR from start
        n_tr = floor(t.onset(1) / TR);
        t.onset = t.onset - n_tr * TR;
    else
        n_tr = 0;
    end

    % Insert no US events
    no_us = cell(0, 3);
    for n = 1: height(t) - 1  % last cs+ was always reinforced so no worries
        if t.trial_type(n) == "cs plus" && t.trial_type(n+1) ~= "us"
            no_us(end+1, :) = {t.onset(n) + 7.5, 1.5, "no us"};
        end
    end
    t = [t; no_us];  % vertically concatenate
    t = sortrows(t);  % sort by 1st column, which is onset

    % Make names, onsets and durations
    events = struct();
    events.names = {'cs plus', 'cs minus', 'us', 'no us'};
    events.durations = {0, 0, 1.5, 1.5};
    events.onsets = cell(1, 4);
    for n = 1:length(events.names)
        events.onsets{1, n} = t{t.trial_type == events.names{n}, 'onset'}';
    end

end

function events = get_de_events(fname)

    % Load and clear event table
    t = readtable(fname, ...
        'FileType', 'text', 'Delimiter', '\t', 'TextType', 'string');
    t.value = [];
    t.trial_type = strrep(t.trial_type, '_', ' ');

    % Make names, onsets, durations and tmod
    events = struct();
    events.names = {'cs plus', 'cs minus'};
    events.durations = {9, 9};
    events.tmod = {1, 1};
    events.onsets = cell(1,2);
    for n = 1:length(events.names)
        events.onsets{1, n} = t{t.trial_type == events.names{n}, 'onset'}';
    end
    
end
