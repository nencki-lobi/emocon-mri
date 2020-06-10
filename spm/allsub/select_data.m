% Prepares trimmed confounds and a list of subjects with # of discarded
% volumes.
%
% INPUT:
%   qualified_observers.tsv - list of subjects & groups
%   events - BIDS-raw files
%   confounds - extracted with utils/extractmotion.py
% OUTPUT:
%   <analysis_dir>/confounds/... - trimmed confounds
%   <analysis_dir>/participants.csv - subject, group, n discarded vols.

my_config = ini2struct('../../config.ini');


bids_dir = my_config.default.bids_root;
questionnaire_dir = my_config.default.questionnaire_dir;
spm_out_dir = my_config.spm.root;
confounds_dir = my_config.spm.confounds;

% load subjects selected based upon contingency responses
subject_table = struct2table(tdfread(...
    fullfile(questionnaire_dir, 'qualified_observers.tsv')));
subject_table.subject = strtrim(string(subject_table.subject));
subject_table.group = strtrim(string(subject_table.group));

% make a copy of the subject table
selected = subject_table(:, :);

% calculate and store number of volumes to trim in OFL (if necessary)
% trim and copy the confound files
selected.discard_volumes_ofl = zeros(height(selected), 1);
TR = 2.87;
new_confounds_dir = fullfile(spm_out_dir, 'allsub', 'confounds');
[status, msg, msgID] = mkdir(new_confounds_dir);

for i = 1: height(selected)
    
    subject = selected.subject(i);
    
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

writetable(selected, fullfile(spm_out_dir, 'allsub', 'participants.csv'));
