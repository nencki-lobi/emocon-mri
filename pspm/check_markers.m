function [isFine, hc] = check_markers(datafile, group)
%CHECK_MARKERS Checks if file contains expected number of key markers
%   Loads marker channel (assumed to be last) and checks if number of
%   markers for task start/end (13, 14, 15, 16) and MR pulse (64) matches
%   expectations for a given group.
%   
%   usage:
%   RES = CHECK_MARKERS(DATAFILE, GROUP)
%   [RES, COUNTS] = CHECK_MARKERS(DATAFILE, GROUP)

if ~any(strcmp(group, ["friend", "stranger"]))
    error('Group should be either "friend" or "stranger"')
end

values = [13 14 15 16 64];

if group == "friend"
    expected_counts = [1 1 1 1 362+184];
else
    expected_counts = [0 1 1 1 380+184];
end

df = load(datafile);
markers = categorical(df.data{end,1}.markerinfo.value);
hc = histcounts(markers, categorical(values));

isFine = all(hc == expected_counts);

end

