% Script for screening data files for scanner markers
%
% Since a choice was made to trim the data based on the scanner markers and
% the DS task start marker, the basic sanity check is to see if the time
% between first and last marker matches the expectation.
% 
% The script was used to screen friend & stranger group separately (can be
% changed in code). It creates a table in the workspace which then can be
% filtered. It also saves the markers to a temporary location (commented
% out) which I screened further for data files raising suspicion. See end
% of file for specific comments.

% paths
my_config = ini2struct('../config.ini');
data_dir = fullfile(my_config.pspm.root, "scr");
behav_dir = my_config.default.questionnaire_dir;

% temporary directory - change as needed
tmpdir = "/Volumes/Transcend/dokumenty/random_notebooks/data/markers";

% load table with behavioral data
tbl = readtable(fullfile(behav_dir, 'table.tsv'), ...
    'FileType', 'Text', 'Delimiter', 'tab', 'TextType', 'string');

% select observers from one group - change as needed
tbl = tbl(...
    tbl.role == "OBS" & tbl.group == "stranger", ...
    ["label", "CONT_contingency"]);

% keep those who have a file - though actually all do
tbl = tbl(isfile(fullfile(data_dir, "pspm_" + tbl.label + ".mat")), :); 

for n = 1:height(tbl)

    eda = load(fullfile(data_dir, "pspm_" + tbl.label(n) + ".mat"));
    timestamps = eda.data{end,1}.data;
    markers = eda.data{end,1}.markerinfo.value;
    
    % write timestamps & markers for further inspection
    % save(fullfile(tmpdir, tbl.label(n) + ".mat"), 'timestamps', 'markers')
    
    tbl.m15(n) = sum(markers == 15);
    
    xpoint = find(markers == 15, 1);
    ofl.ts = timestamps(1:xpoint);
    ofl.mrk = markers(1:xpoint);
    de.ts = timestamps(xpoint:end);
    de.mrk = markers(xpoint:end);
    
    tbl.m1(n) = sum(ofl.mrk == 1);
    tbl.m13(n) = sum(ofl.mrk == 13);
    
    tbl.firstPulseOfl(n) = ofl.ts(find(ofl.mrk==64, 1, 'first'));
    tbl.lastPulseOfl(n) = ofl.ts(find(ofl.mrk==64, 1, 'last'));
    
    tbl.firstPulseDe(n) = de.ts(find(de.mrk == 64, 1, 'first'));
    tbl.lastPulseDe(n) = de.ts(find(de.mrk == 64, 1, 'last'));
    
end

tbl.oflDuration = tbl.lastPulseOfl - tbl.firstPulseOfl;
tbl.oflSec = round(tbl.oflDuration);

tbl.deDuration = tbl.lastPulseDe - tbl.firstPulseDe;
tbl.deSec = round(tbl.deDuration);

% How the resulting table was screened:
% Stranger group, OFL: tbl(tbl.oflSec ~= 1088 | tbl.m1 ~= 1, :)
% Stranger group, DE:  tbl(tbl.deSec ~= 525,:)
% Friend group:        tbl(tbl.oflSec ~= 1036 | tbl.deSec ~= 525, :)

% After further external inspection (stem plot of markers at ofl start, 
% around the task break and at de end) these seem to be the issues causing
% mismatch between task length and scanner pulse coverage:
%
% OFL:
% Gptfwi: "1" marker missing, but scanner pulses are all legit
% Yhsgxa: beginning of OFL seems to be cut off - safest to discard data
% Xfpolo: "64" markers are all over the place - safest to discard data
% Rkrtyk: Two opening "64" markers should go out, all other seem legit
% Ortklp: One additional "64" in the middle of OFL, one in the break, but
%         all other markers seem legit
% 
% DE:
% Indjeu: one "64" missing (at the end?), task starts look OK
% Dvupak: three "64" missing (at the end?), task starts look OK
% Frosty: as above - probably scr was stopped before mri?
% Ddpqrp: Several additional "64"s  inside, but OFL start not affected. One
%         extra "64" at DE start which should go out
% Xfpolo: see OFL
% Ztlxhi: False start in DE, so second to be taken.
