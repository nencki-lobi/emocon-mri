% Prepare confound files to be used by SPM.

my_config = ini2struct('../../config.ini');


bids_dir = my_config.default.bids_root;
deriv_dir = my_config.default.deriv_dir;
spm_out_dir = my_config.spm.root;


analysis_dir = fullfile(spm_out_dir, 'mot_out');

% The list of subjects remains the same as for 'allsub' analysis, with the
% exception that subject Nagery was manually discarded from the list due to
% having 105 motion outliers (> 25% of total volumes).
subject_table = readtable(fullfile(analysis_dir, 'participants.csv'), ...
    'TextType', 'string');

% Confounds will be created based on the fmriprep outputs.
confounds_path = fullfile(deriv_dir, 'fmriprep', 'sub-%1$s', 'func', ...
    'sub-%1$s_task-%2$s_desc-confounds_regressors.tsv');
out_path = fullfile(analysis_dir, 'confounds', '%s_%s');
rp_names = {'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z'};

%% Extract confounds for OFL

for k = 1:height(subject_table)
    subject = subject_table.subject(k);
    n_disc = subject_table.discard_volumes_ofl(k);
    
    confounds_file = sprintf(confounds_path, subject, 'ofl');
    confounds = struct2table(tdfread(confounds_file));
    
    mo_cols = startsWith(confounds.Properties.VariableNames, ...
        'motion_outlier');  % may be empty, which is still fine
    mo_names = confounds.Properties.VariableNames(mo_cols);
    mo_names = strrep(mo_names, '_', '');
    
    rp = confounds{n_disc+1:end, rp_names};
    mo = confounds{n_disc+1:end, mo_cols}; % using logical indexing
    
    R = [rp mo];
    names = [rp_names, mo_names];
    
    matfile = sprintf(out_path, subject, 'ofl');
    save(matfile, 'R', 'names');
    
end

%% Same as above, but without trimming, for DE
for k = 1:height(subject_table)
    subject = subject_table.subject(k);
    
    confounds_file = sprintf(confounds_path, subject, 'de');
    confounds = struct2table(tdfread(confounds_file));
    
    mo_cols = startsWith(confounds.Properties.VariableNames, ...
        'motion_outlier');  % may be empty, which is still fine
    mo_names = confounds.Properties.VariableNames(mo_cols);
    mo_names = strrep(mo_names, '_', '');
    
    rp = confounds{:, rp_names}; % using name indexing
    mo = confounds{:, mo_cols}; % using logical indexing
    
    R = [rp mo];
    names = [rp_names, mo_names];
    
    matfile = sprintf(out_path, subject, 'de');
    save(matfile, 'R', 'names');
    
end
