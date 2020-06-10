my_config = ini2struct('../../config.ini');

tr = 2.87;

% Copy / edit events & confounds for DE

participants = readtable(fullfile(...
    my_config.spm.root, 'allsub', 'participants.csv'));
participants.use_volumes = zeros(height(participants), 1);

for n =1:height(participants)

    % load events & confounds (already account for start time!)
    events = load(fullfile(...
        my_config.spm.root, 'allsub', 'events_tmod1',...
        sprintf('%s_de.mat', participants.subject{n})));

    confounds = load(fullfile(...
        my_config.spm.root, 'allsub', 'confounds',...
        sprintf('%s_de.txt', participants.subject{n})));

    % trim events
    events.onsets{1} = events.onsets{1}(1:6);
    events.onsets{2} = events.onsets{2}(1:6);

    % trim confounds & store n_vols
    total_duration = max(cell2mat(events.onsets)) + 15;
    n_vols = ceil(total_duration / tr);
    participants.use_volumes(n) = n_vols;
    R = confounds(1:n_vols, :);

    % save files
    new_dir = fullfile(my_config.spm.root, 'allsub-halfdata');
    if n == 1
        % no need to try more than once
        [~, ~] = mkdir(new_dir, 'events');
        [~, ~] = mkdir(new_dir, 'confounds');
    end

    events_path = fullfile(new_dir, 'events', ...
        sprintf('%s_de.mat', participants.subject{n}));
    confounds_path = fullfile(new_dir, 'confounds', ...
        sprintf('%s_de.mat', participants.subject{n}));

    save(events_path, '-struct', 'events');
    save(confounds_path, 'R');
end

writetable(participants, fullfile(new_dir, 'participants.csv'))

