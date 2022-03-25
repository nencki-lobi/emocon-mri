% ROI analysis
%
% Extracts ROI statistics (average parameter estimates from con files).
% Requires first level models to be estimated, and ROI definitions to be
% available. The ROI definitions are created by prepare_roi.m (in this
% folder).
%
% Creates csv files (one per contrast), which can be analysed in R.

my_config = ini2struct('../../../config.ini');

% what goes where
roi_dir = fullfile(my_config.spm.root, "roi");
fl_dir  = fullfile(my_config.spm.root, "complete", "first_level");
tbl_dir = fullfile(my_config.spm.root, "complete", "other");

subject_table = readtable(fullfile(tbl_dir, "included_participants.csv"), ...
    'TextType', 'string');

% Create a struct array with tasks and respective contrast names
inputs = struct('task', {}, 'con', {}, 'suffix', {});
inputs(1) = struct('task', "ofl", 'con', "con_0005.nii", 'suffix', "");
inputs(2) = struct('task', "de", 'con', "con_0005.nii", 'suffix', "");
inputs(3) = struct('task', "ofl", 'con', "con_0003.nii", 'suffix', "-us");
inputs(4) = struct('task', "ofl", 'con', "con_0004.nii", 'suffix', "-nous");

% Extract from the same ROIs for both tasks
for n = 1:length(inputs)
    stats = subject_table(:, ["label", "group"]);
    
    stats.amygdala = summarise(...
        stats.label, fl_dir, inputs(n).task, inputs(n).con, ...
        fullfile(roi_dir, "merged_seed_amygdala_vox200.nii"));
    stats.AI = summarise(...
        stats.label, fl_dir, inputs(n).task, inputs(n).con, ...
        fullfile(roi_dir, "merged_seed_AI_vox200.nii"));
    stats.aMCC = summarise(...
        stats.label, fl_dir, inputs(n).task, inputs(n).con, ...
        fullfile(roi_dir, "seed_aMCC_vox200.nii"));
    stats.rTPJ = summarise(...
        stats.label, fl_dir, inputs(n).task, inputs(n).con, ...
        fullfile(roi_dir, "seed_rTPJ_vox200.nii"));
    stats.rpSTS = summarise(...
        stats.label, fl_dir, inputs(n).task, inputs(n).con, ...
        fullfile(roi_dir, "seed_rpSTS_vox200.nii"));
    stats.rFFA = summarise(...
        stats.label, fl_dir, inputs(n).task, inputs(n).con, ...
        fullfile(roi_dir, "seed_rFFA_vox200.nii"));

    tbl_name = "roi_stats_" + inputs(n).task + inputs(n).suffix + ".csv";
    writetable(stats, fullfile(tbl_dir, tbl_name))

end


function result = summarise(subjects, first_level_dir, task, con, xY)
    % SUMMARISE extracts parameters averaged within VOI from given files
    % 
    % subjects        - string array containing subject labels
    % first_level_dir - path to the directory with 1st level models;
    %                   should be organised into subfolders named: 
    %                   <subject>_<task>
    % task            - task name
    % con             - con file name (without path), e.g. 'con_0001.nii'
    % xY              - region of interest specification, either VOI
    %                   structure from spm_ROI or a mask image filename;
    %                   spherical voi can be defined as struct(...
    %                   'def', 'sphere', 'xyz', [x, y, z]', 'spec', r)
    %                   where x, y, z are coordinates and r is radius
    %
    % result          - double array with ROI averages

    if isstring(xY)
        % spm expects struct or char but not string, so do string -> char
        xY = char(xY);
    end
    
    file_list = char(...
        fullfile(first_level_dir, subjects + "_" + task, con));
    [result, ~] = spm_summarise(file_list, xY, @mean);
end
