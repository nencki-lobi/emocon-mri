% Prepares event files with temporal modulation enabled. Takes into account
% OFL being trimmed. Use after select_data.m
%
% INPUT:
%   participants.csv file (generated  by select_data.m)
%   events - BIDS-raw files
% OUTPUT:
%   <analysis_dir>/events_*/... - SPM event files


%% Preparation

my_config = ini2struct('../../config.ini');


bids_dir = my_config.default.bids_root;
spm_out_dir = my_config.spm.root;

% load subjects to be processed - prepared by select_data.m
subject_table = readtable(...
    fullfile(spm_out_dir, 'allsub', 'participants.csv'),...
    'TextType', 'string');

% create output directories for events with tmod (1st & 2nd order);
out_dir_tmod_1st = fullfile(spm_out_dir, 'allsub', 'events_tmod1');
[~, ~] = mkdir(out_dir_tmod_1st);


TR = 2.87;

%% Direct expression

task = 'de';  % process de only, but be more explicit

for i = 1:height(subject_table)
    
    subject = subject_table.subject(i);

    % load events
    events = read_event_table(...
        fullfile(...
            bids_dir,...
            strcat('sub-', subject),...
            'func',...
            sprintf('sub-%s_task-%s_events.tsv', subject, task)));
    
    % cs plus
    event_q = events(strcmp(events.trial_type, 'cs_plus'), :);

    names{1} = 'cs plus';
    onsets{1} = event_q.onset';
    durations{1} = 0;
    tmod{1} = 1;

    % cs minus
    event_q = events(strcmp(events.trial_type, 'cs_minus'), :);
    
    names{2} = 'cs minus';
    onsets{2} = event_q.onset';
    durations{2} = 0;
    tmod{2} = 1;
    
    % create and write output with tmod (1st order)

    out_file = fullfile(out_dir_tmod_1st, sprintf('%s_%s.mat', subject, task));
    save(out_file, 'names', 'onsets', 'durations', 'tmod');
    
    
    clearvars names onsets durations tmod;

end


%% Observational Fear Learning

task = 'ofl';

for i = 1:height(subject_table)
    
    subject = subject_table.subject(i);

    % load events
    events = read_event_table(...
        fullfile(...
            bids_dir,...
            strcat('sub-', subject),...
            'func',...
            sprintf('sub-%s_task-%s_events.tsv', subject, task)));
        
    % add correction for dropped early volumes (if needed)
    events.onset = events.onset - subject_table.discard_volumes_ofl(i) * TR;
    
    % cs plus
    event_q = events(strcmp(events.trial_type, 'cs_plus'), :);

    names{1} = 'cs plus';
    onsets{1} = event_q.onset';
    durations{1} = 0;
    tmod{1} = 1;
    
    % cs minus
    event_q = events(strcmp(events.trial_type, 'cs_minus'), :);
    
    names{2} = 'cs minus';
    onsets{2} = event_q.onset';
    durations{2} = 0;
    tmod{2} = 1;
    
    % us
    event_q = events(strcmp(events.trial_type, 'us'), :);
    
    names{3} = 'us';
    onsets{3} = event_q.onset';
    durations{3} = 1.5;  % need consensus on that
    tmod{3} = 1;
    
    % no us
    no_us_onsets = [];
    for k = 1:height(events)-1
        if events{k, 'trial_type'} == "cs_plus" ...
                && events{k+1, 'trial_type'} ~= "us"
            no_us_onsets(end+1) = events{k, 'onset'} + 7.5; %#ok<SAGROW>
        end
    end
    
    names{4} = 'no us';
    onsets{4} = no_us_onsets;
    durations{4} = 1.5;  % same as above
    tmod{4} = 1;
    
    % create and write output with tmod (1st order)
    out_file = fullfile(out_dir_tmod_1st, sprintf('%s_%s.mat', subject, task));
    save(out_file, 'names', 'onsets', 'durations', 'tmod');
        
    clearvars names onsets durations tmod;

end
