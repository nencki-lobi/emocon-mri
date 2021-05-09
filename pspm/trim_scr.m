% Trim SCR data for PsPM
%
% Data are trimmed to the first scanner pulse, so that timings from BIDS
% events.tsv can be directly applied. The R64 marker is used for this
% purpose.
% 
% Interestingly, there are some extraneous or missing R64s in some data
% files, but upon closer inspection, the first ones are almost always
% reliable (MarkerDiffs.mlx live script). Problematic cases are handling
% through manually sifting through markers and trimming by time.
%
% For some reason, time of the first stimulus relative to the 1st MR pulse
% calculated from markers differs from the one calculated from logs by a
% value in the order of 0.020 s. For signal which is going to be
% downsampled to 10 Hz this seems negligible.

% establish paths
my_config = ini2struct('../config.ini');

work_dir = fullfile(my_config.pspm.root, 'scr');

% load subjects
tab = readtable(fullfile(my_config.pspm.root, 'participants.csv'), ...
    'TextType', 'string');
tab.label = upper(tab.label);

% some subjects need to be handled manually or excluded due to marker
% inconsistencies; see file markers_coverage.m for details
manual = ["DDPQRP", "GPTFWI", "RKRTYK", "ZTLXHI"];
excluded = ["YHSGXA", "XFPOLO"];

for n = 1:height(tab)
    
    code = tab.label(n);
    
    if ismember(code, manual) || ismember(code, excluded)
        continue
    end

    datafile = fullfile(work_dir, "pspm_" + code + ".mat");

    % for OFL, trim first pulse to 10 s after task end marker
    trimmed_ofl = pspm_trim(cellstr(datafile), 0, 10, {'64', '14'});

    % rename trimmed file
    movefile(trimmed_ofl, strrep(trimmed_ofl, ...
        code + ".mat", code + "_ofl.mat"));

    % for DE, first trim from start marker, and then pulse to task end
    de_rough = pspm_trim(cellstr(datafile), 0, 'none', {'15', '16'});
    de_exact = pspm_trim(cellstr(de_rough), 0, 10, {'64', '16'});

    % delete intermediate file, rename result
    delete(de_rough)
    movefile(de_exact, strrep(de_exact, ...
        "ttpspm_" + code + ".mat", "tpspm_" + code + "_de.mat"))

end

% for subjects with inconsistent markers, trim by time found by browsing
% manually through the markers; pspm_trim(datafile, from, to, 'file')

ofl_friend_sec = 1036;
ofl_stranger_sec = 1088;
de_sec = 525;

trimmed_ofl = pspm_trim(cellstr(fullfile(work_dir, "pspm_DDPQRP.mat")), ...
    19.716, 19.716 + ofl_stranger_sec, 'file');
movefile(trimmed_ofl, strrep(trimmed_ofl, "DDPQRP.mat", "DDPQRP_ofl.mat"));

trimmed_de = pspm_trim(cellstr(fullfile(work_dir, "pspm_DDPQRP.mat")), ...
    1250.7, 1250.7 + de_sec, 'file');
movefile(trimmed_de, strrep(trimmed_de, "DDPQRP.mat", "DDPQRP_de.mat"));

trimmed_ofl = pspm_trim(cellstr(fullfile(work_dir, "pspm_GPTFWI.mat")), ...
    4.116, 4.116 + ofl_stranger_sec, 'file');
movefile(trimmed_ofl, strrep(trimmed_ofl, "GPTFWI.mat", "GPTFWI_ofl.mat"));

trimmed_de = pspm_trim(cellstr(fullfile(work_dir, "pspm_GPTFWI.mat")), ...
    1199.932, 1199.932 + de_sec, 'file');
movefile(trimmed_de, strrep(trimmed_de, "GPTFWI.mat", "GPTFWI_de.mat"));

trimmed_ofl = pspm_trim(cellstr(fullfile(work_dir, "pspm_RKRTYK.mat")), ...
    20.432, 20.432 + ofl_stranger_sec, 'file');
movefile(trimmed_ofl, strrep(trimmed_ofl, "RKRTYK.mat", "RKRTYK_ofl.mat"));

trimmed_de = pspm_trim(cellstr(fullfile(work_dir, "pspm_RKRTYK.mat")), ...
    1222.516, 1222.516 + de_sec, 'file');
movefile(trimmed_de, strrep(trimmed_de, "RKRTYK.mat", "RKRTYK_de.mat"));

trimmed_ofl = pspm_trim(cellstr(fullfile(work_dir, "pspm_ZTLXHI.mat")), ...
    45.088, 45.088 + ofl_friend_sec, 'file');
movefile(trimmed_ofl, strrep(trimmed_ofl, "ZTLXHI.mat", "ZTLXHI_ofl.mat"));

trimmed_de = pspm_trim(cellstr(fullfile(work_dir, "pspm_ZTLXHI.mat")), ...
    1397.644, 1397.644 + de_sec, 'file');
movefile(trimmed_de, strrep(trimmed_de, "ZTLXHI.mat", "ZTLXHI_de.mat"));
