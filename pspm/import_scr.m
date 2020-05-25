% Import scr data into pspm format

% establish paths
my_config = ini2struct('../config.ini');
raw_eda_dir = my_config.default.eda_dir;
pspm_root = my_config.pspm.root;

% fetch subjects for processing
tab = readtable(fullfile(pspm_root, 'participants.csv'), ...
    'TextType', 'string');
tab.label = upper(tab.label);

% set import parameters & options
import_spec = {
    struct('type', 'scr', 'channel', 1, 'transfer', 'none'), ...
    struct('type', 'marker')
    };

import_options = struct('overwrite', false);

% create cell array with all file paths
datafiles = cellstr(fullfile(raw_eda_dir, tab.label + ".eeg"));

% import all files in one call
pspm_import(datafiles, 'brainvision', import_spec, import_options);

% move imported files from raw data folder to pspm folder
movefile(fullfile(raw_eda_dir, 'pspm_*'), fullfile(pspm_root, 'scr'))

%% check markers

n_rows = height(tab);
check_results = false(n_rows, 1);
check_counts = cell(n_rows, 1);

for n = 1:height(tab)
    new_file = fullfile(pspm_root, "scr", "pspm_" + tab.label(n) + ".mat");
    [isFine, hc] = check_markers(new_file, tab.group(n));
    
    check_results(n, 1) = isFine;
    check_counts{n, 1} = hc;
end

tab.isFine = check_results;
tab.markerCount = check_counts;
