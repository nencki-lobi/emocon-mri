
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

task = 'de';  % process de only, but be more explicit

% create output directory
out_dir = fullfile(spm_out_dir, 'modulation', 'events_pmod');
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
    pmod(2).param{1} = eda_q.amplitude;
    pmod(2).poly{1} = 1;
    
    out_file = fullfile(out_dir, sprintf('%s_%s.mat', subject, task));
    save(out_file, 'names', 'onsets', 'durations', 'pmod');
    
    clearvars names onsets durations pmod;

end
