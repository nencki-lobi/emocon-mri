my_config = ini2struct('../../config.ini');


bids_dir = my_config.default.bids_root;
eda_dir = fullfile(my_config.physio.eda_deriv_dir, 'peak_to_peak', 'scores');
questionnaire_dir = my_config.default.questionnaire_dir;
spm_out_dir = my_config.spm.root;
confounds_dir = my_config.spm.confounds;

% load subjects selected based upon contingency responses
subject_table = struct2table(tdfread(...
    fullfile(questionnaire_dir, 'qualified_observers.tsv')));
subject_table.code = strtrim(string(subject_table.code));
subject_table.group = strtrim(string(subject_table.group));

% make a copy of the subject table
selected = subject_table(:, :);

% load all eda, replacing NaNs with zeros
eda = readtable(fullfile(eda_dir, 'all_scores.csv'));

% on top of that, exclude subjects without eda data
for i = 1:height(subject_table)
    
    subject = subject_table.code(i);
    eda_sub = eda(strcmpi(eda.code, subject), :);

    % skip subjects with no eda data
    % (meaning not processed due to acquisition issues)
    if height(eda_sub) == 0
        fprintf('no eda available for subject %s\n', subject)
        selected(strcmp(selected.code, subject), :) = [];
        continue
    end

    % skip eda nonresponders
    nzplus = eda_sub(...
        strcmp(eda_sub.stimulus, 'direct CS+') & ~isnan(eda_sub.amplitude), :);
    nzminus = eda_sub(...
        strcmp(eda_sub.stimulus, 'direct CS-') & ~isnan(eda_sub.amplitude), :);
    if height(nzplus) < 3 || height(nzminus) < 3
        fprintf('too few eda amplitudes for subject %s\n', subject)
        selected(strcmp(selected.code, subject), :) = [];
    end
end

% calculate and store number of volumes to trim in OFL (if necessary)
% trim and copy the confound files
selected.discard_volumes_ofl = zeros(height(selected), 1);
TR = 2.87;
new_confounds_dir = fullfile(spm_out_dir, 'modulation', 'confounds');
[status, msg, msgID] = mkdir(new_confounds_dir);

for i = 1: height(selected)
    
    subject = selected.code(i);
    
    events = read_event_table(...
        fullfile(...
            bids_dir,...
            strcat('sub-', subject),...
            'func',...
            sprintf('sub-%s_task-ofl_events.tsv', subject)));

    confounds = dlmread(...
        fullfile(...
            confounds_dir, strcat(subject, '_ofl.txt')));
        
    if events.onset(1) > 3*TR
        n_tr = floor(events.onset(1) / TR);
        selected.discard_volumes_ofl(i) = n_tr;
        confounds = confounds(n_tr+1:end, :);
    end
    
    % save (potentially trimmed) ofl confounds to new location
    dlmwrite(...
        fullfile(new_confounds_dir, strcat(subject, '_ofl.txt')), ...
        confounds)
    
    % for de, simply copy confounds to new location
    copyfile(...
        fullfile(confounds_dir, strcat(subject, '_de.txt')), ...
        fullfile(new_confounds_dir, strcat(subject, '_de.txt')));
end

writetable(selected, fullfile(spm_out_dir, 'modulation', 'participants.csv'));
