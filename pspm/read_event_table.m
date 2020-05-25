function [event_table] = read_event_table(file_path)
%READ_EVENT_TABLE Read BIDS events file into a table
%   Reads trial_type, onset and duration columns from BIDS events.tsv file.
%   Returns a matlab table. The trial_type column is converted into a
%   string array, so that it can be conveniently queried with:
%   mytable(mytable.trial_type == 'something', :).

% straight up readtable won't work with .tsv file extension
estruct = tdfread(file_path);

% put the obligatory columns in a table
event_table = table(estruct.trial_type, estruct.onset, estruct.duration, ...
    'VariableNames', {'trial_type', 'onset', 'duration'});

% convert trial_type to string array for sane '==' behaviour
event_table.trial_type = strtrim(string(event_table.trial_type));    
    

end

