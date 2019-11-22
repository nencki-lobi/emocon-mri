
my_config = ini2struct('../../config.ini');


bids_dir = my_config.default.bids_root;
eda_dir = fullfile(my_config.physio.eda_deriv_dir, 'peak_to_peak', 'scores');
questionnaire_dir = my_config.default.questionnaire_dir;
spm_out_dir = my_config.spm.root;

% load subjects to be processed - prepared by select_data.m
subject_table = readtable(...
    fullfile(spm_out_dir, 'modulation', 'participants.csv'),...
    'TextType', 'string');

% load all eda, replacing NaNs with zeros
eda = readtable(fullfile(eda_dir, 'all_scores.csv'));
eda.amplitude(isnan(eda.amplitude)) = 0;

% create output directory
out_dir = fullfile(spm_out_dir, 'modulation', 'events_pmod');
[~, ~] = mkdir(out_dir);

% create output directory for events without pmod
out_dir_nomod = fullfile(spm_out_dir, 'modulation', 'events_nomod');
[status, msg] = mkdir(out_dir_nomod);

TR = 2.87;

%% Direct expression

task = 'de';  % process de only, but be more explicit

for i = 1:height(subject_table)
    
    subject = subject_table.code(i);

    % load events
    events = read_event_table(...
        fullfile(...
            bids_dir,...
            strcat('sub-', subject),...
            'func',...
            sprintf('sub-%s_task-%s_events.tsv', subject, task)));

    % subset the eda amplitudes
    eda_sub = eda(strcmpi(eda.code, subject), :);
    
    % cs plus
    event_q = events(strcmp(events.trial_type, 'cs_plus'), :);
    eda_q = eda_sub(strcmp(eda_sub.stimulus, 'direct CS+'), :);

    names{1} = 'cs plus';
    onsets{1} = event_q.onset';
    durations{1} = 0;
    pmod(1).name{1} = 'eda cs plus';
    pmod(1).param{1} = eda_q.amplitude';
    pmod(1).poly{1} = 1;

    % cs minus
    event_q = events(strcmp(events.trial_type, 'cs_minus'), :);
    eda_q = eda_sub(strcmp(eda_sub.stimulus, 'direct CS-'), :);
    
    names{2} = 'cs minus';
    onsets{2} = event_q.onset';
    durations{2} = 0;
    pmod(2).name{1} = 'eda cs minus';
    pmod(2).param{1} = eda_q.amplitude';
    pmod(2).poly{1} = 1;
    
    % write output
    out_file = fullfile(out_dir, sprintf('%s_%s.mat', subject, task));
    save(out_file, 'names', 'onsets', 'durations', 'pmod');
    
    % write output without pmod
    out_file = fullfile(out_dir_nomod, sprintf('%s_%s.mat', subject, task));
    save(out_file, 'names', 'onsets', 'durations');
    
    clearvars names onsets durations pmod;

end


%% Observational Fear Learning

task = 'ofl';

for i = 1:height(subject_table)
    
    subject = subject_table.code(i);

    % load events
    events = read_event_table(...
        fullfile(...
            bids_dir,...
            strcat('sub-', subject),...
            'func',...
            sprintf('sub-%s_task-%s_events.tsv', subject, task)));
        
    % add correction for dropped early volumes (if needed)
    events.onset = events.onset - subject_table.discard_volumes_ofl(i) * TR;

    % subset the eda amplitudes
    eda_sub = eda(strcmpi(eda.code, subject), :);
    
    % cs plus
    event_q = events(strcmp(events.trial_type, 'cs_plus'), :);
    eda_q = eda_sub(strcmp(eda_sub.stimulus, 'obs CS+'), :);

    names{1} = 'cs plus';
    onsets{1} = event_q.onset';
    durations{1} = 0;
    pmod(1).name{1} = 'eda cs plus';
    pmod(1).param{1} = eda_q.amplitude';
    pmod(1).poly{1} = 1;

    % cs minus
    event_q = events(strcmp(events.trial_type, 'cs_minus'), :);
    eda_q = eda_sub(strcmp(eda_sub.stimulus, 'obs CS-'), :);
    
    names{2} = 'cs minus';
    onsets{2} = event_q.onset';
    durations{2} = 0;
    pmod(2).name{1} = 'eda cs minus';
    pmod(2).param{1} = eda_q.amplitude';
    pmod(2).poly{1} = 1;
    
    % us
    event_q = events(strcmp(events.trial_type, 'us'), :);
    eda_q = eda_sub(strcmp(eda_sub.stimulus, 'obs US present'), :);
    
    names{3} = 'us';
    onsets{3} = event_q.onset';
    durations{3} = 1.5;  % need consensus on that
    pmod(3).name{1} = 'eda us';
    pmod(3).param{1} = eda_q.amplitude';
    pmod(3).poly{1} = 1;
    
    % no us
    no_us_onsets = [];
    for k = 1:height(events)-1
        if events{k, 'trial_type'} == "cs_plus" ...
                && events{k+1, 'trial_type'} ~= "us"
            no_us_onsets(end+1) = events{k, 'onset'} + 7.5; %#ok<SAGROW>
        end
    end
    
    eda_q = eda_sub(strcmp(eda_sub.stimulus, 'obs US absent'), :);

    names{4} = 'no us';
    onsets{4} = no_us_onsets;
    durations{4} = 1.5;  % same as above
    pmod(4).name{1} = 'eda no us';
    pmod(4).param{1} = eda_q.amplitude';
    pmod(4).poly{1} = 1;
    
    % write output
    out_file = fullfile(out_dir, sprintf('%s_%s.mat', subject, task));
    save(out_file, 'names', 'onsets', 'durations', 'pmod');
    
    % write output without pmod
    out_file = fullfile(out_dir_nomod, sprintf('%s_%s.mat', subject, task));
    save(out_file, 'names', 'onsets', 'durations');
    
    clearvars names onsets durations pmod;

end
