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

% some subjects need to be handled manually due to marker inconsistencies
problem = ["ZTLXHI", "GPTFWI", "YHSGXA", "DDPQRP", "XFPOLO", "RKRTYK"];

for n = 1:height(tab)
    
    code = tab.label(n);
    
    if ismember(code, problem)
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

% TODO: for subjects with inconsistent markers, browse manually and trim by
% time / pspm_trim(datafile, from, to, 'file')
