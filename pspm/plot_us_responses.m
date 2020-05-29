% Plot responses to US to visually assess whether they can be explained
% with a fixed response

% establish paths
my_config = ini2struct('../config.ini');
bids_root = my_config.default.bids_root;
pspm_root = my_config.pspm.root;

mkdir('figures');  % put output right here

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

for n = 1: height(tab)
    subject = tab.label(n);
    
    % fetch events
    event_tab = readtable(...
        fullfile(bids_root, ...
            "sub-" + subject, ...
            "func", ...
            "sub-" + subject + "_task-ofl_events.tsv"), ...
        'FileType', 'text', 'TextType', 'string');

    us_onsets = event_tab{event_tab.trial_type == "us", "onset"};

    % fetch data
    trimmed_data = load(fullfile(pspm_root, "scr", ...
        "tpspm_" + upper(subject) + "_ofl.mat"));
    eda = trimmed_data.data{1,1}.data;
    sr = trimmed_data.data{1,1}.header.sr;

    % filter & downsample
    fn = sr / 2;

    [b, a] = butter(1, 5/fn, 'low');
    eda = filtfilt(b, a, eda);

    [b, a] = butter(1, 0.0159/fn, 'high');
    eda = filtfilt(b, a, eda);

    newsr = 10;
    eda = resample(eda, newsr, sr);
    sr = int64(newsr);  % update & convert to int for indexing

    % extract responses
    resp_sec = 10;
    resp_len = resp_sec * sr;
    tp = linspace(0, resp_sec, resp_len);

    data = zeros(resp_len, length(us_onsets)); % trials in columns
    for n = 1:length(us_onsets)
        s = us_onsets(n) * sr;
        data(:, n) = eda(s: s+resp_len-1);
    end

    mresp = mean(data, 2);

    f = figure;
    hold on
    plot(tp, data)
    plot(tp, mresp, 'Color', 'black', 'LineWidth', 3)
    title(subject)
    xlabel('time after US onset (s)')
    ylabel('SCR (\muS)')
    hold off
    exportgraphics(f, fullfile('figures', subject + ".pdf"), ...
        'ContentType', 'vector');
    close(f)
    
    % can merge with pdfunite *.pdf all.pdf
    
end