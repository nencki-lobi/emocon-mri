% Reorders missing epochs stored in files
%
% The data editor saves missing epochs in the order they were created. If
% this is not the chronological order, pspm_dcm crashes at line 433 (inside
% pspm_prepdata, line 109) with an error Output argument "y" (and maybe 
% others) not assigned during call to "pspm_filtfilt".

my_config = ini2struct('../config.ini');
pspm_root = my_config.pspm.root;

listing = dir(fullfile(pspm_root, 'missing_epochs_scr', '*artefacts.mat'));

for n = 1:length(listing)
    fpath = fullfile(listing(n).folder, listing(n).name);
    f = load(fpath);
    if ~issortedrows(f.epochs)
        disp("sorting " + listing(n).name);
        epochs = sortrows(f.epochs);
        save(fpath, 'epochs');
    end
end
