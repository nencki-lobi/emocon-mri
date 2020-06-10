
my_config = ini2struct('../../config.ini');


bids_dir = my_config.default.bids_root;
spm_out_dir = my_config.spm.root;

% load subjects to be processed - prepared by select_data.m
subject_table = readtable(...
    fullfile(spm_out_dir, 'modulation', 'participants.csv'),...
    'TextType', 'string');

task = 'de';  % process de only, but be more explicit

% create output directory
out_dir = fullfile(spm_out_dir, 'modulation', 'events_iti_nomod');
status = mkdir(out_dir);

for i = 1:height(subject_table)
    
    subject = subject_table.code(i);

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

    % cs minus
    event_q = events(strcmp(events.trial_type, 'cs_minus'), :);
    
    names{2} = 'cs minus';
    onsets{2} = event_q.onset';
    durations{2} = 0;
    
    % ITI
    event_q = events(strcmp(events.trial_type, 'fix'), :);
    
    names{3} = 'iti';
    onsets{3} = event_q.onset;
    durations{3} = event_q.duration;
    
    % write output
    out_file = fullfile(out_dir, sprintf('%s_%s.mat', subject, task));
    save(out_file, 'names', 'onsets', 'durations');
    
    clearvars names onsets durations;

end
