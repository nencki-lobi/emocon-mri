% This script prepares Pulse data for PsPM models.
% It requires PsPM to be present in the path (version 4.2.0 was used).
% It requires ini2struct function by Andriy Nych.
% https://uk.mathworks.com/matlabcentral/fileexchange/17177-ini2struct

my_config = ini2struct('../config.ini');

bids_root = my_config.default.bids_root;
work_dir = fullfile(my_config.physio.pulse_deriv_dir, 'prep');

participants = tdfread(fullfile(bids_root, 'participants.tsv'));
p_ids = string(participants.participant_id);  % string array
codes = strrep(p_ids, 'sub-', '');

for i = 1:length(codes)
    
    code = codes(i);
    
    if code == "Fudoss" || code == "Gptfwi"
        % problem with the data files, must investigate
        continue
    end
    
    if code == "Slcpsu"
        % "No pulse found" error on preprocessing, investigate
       continue
    end

    % check if pulse file is present
    data_file = buildMyPath(bids_root, code, 'de', 'physio', 'tsv.gz');
    if ~isfile(data_file)
        fprintf('Skipping %s - physio data missing\n', code)
        continue
    end
    
    % gunzip the data file and change extension
    data_file = buildMyPath(bids_root, code, 'de', 'physio', 'tsv.gz');
    unz_files = gunzip(data_file, work_dir);
    data_file_txt = regexprep(unz_files{1}, '.tsv$', '.txt');
    movefile(unz_files{1}, data_file_txt);

    % load the events
    event_file = buildMyPath(bids_root, code, 'de', 'events', 'tsv');
    event_table = read_event_table(event_file);

    % load metadata
    metadata = jsondecode(fileread(...
        buildMyPath(bids_root, code, 'de', 'physio', 'json')));

    % figure out trimming values and adjust events if necessary
    if metadata.StartTime < 0
        % pulse recording starts before fMRI
        % trim the beginning to match fMRI
        % no need to shift events in such case
        trim_start = - metadata.StartTime;
    else
        % pulse recording starts after fMRI
        % no trimming at the beginning
        % shift the event onsets to align with pulse
        trim_start = 0;
        event_table.onset = event_table.onset - metadata.StartTime;
    end
    % trim at the end, 5 seconds after last stimulus ends
    trim_end = trim_start + event_table.onset(end) + event_table.duration(end) ...
        + 5;

    % run PsPM import
    options = struct('overwrite', false);
    import = {struct('type', 'ppu', 'sr', metadata.SamplingFrequency, ...
                     'channel', 1)};
    imported = pspm_import(data_file_txt, 'txt', import, options);

    % run PsPM trim
    newdatafile = pspm_trim(imported, trim_start, trim_end, 'file', options);

    % create PsPM's event file
    names = cell(1, 2);
    onsets = cell(1, 2);
    units = 'seconds';

    names{1} = 'cs_plus';
    onsets{1} = event_table(event_table.trial_type == 'cs_plus', :).onset;
    names{2} = 'cs_minus';
    onsets{2} = event_table(event_table.trial_type == 'cs_minus', :).onset;

    save(fullfile(work_dir, sprintf('sub-%s_task-de_pspmevents.mat', code)), ...
        'names', 'onsets', 'units')
end


function myPath = buildMyPath(root_dir, subject, task, suffix, extension)
    rel_path = strcat(...
        'sub-', subject, filesep, 'func', filesep, ...
        'sub-', subject, '_task-', task, '_', suffix, '.', extension);
    myPath = fullfile(root_dir, rel_path);
end
