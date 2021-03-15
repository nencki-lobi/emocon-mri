% ROI analysis template

participants_file = '/Volumes/Transcend/emocon_mri/spm/mot_out/participants.csv';
first_level_dir = '/Volumes/Transcend/emocon_mri/spm/mot_out/first_level';

acc_voi = struct(...
    'def', 'sphere', ...
    'xyz', [6, 20, 38]', ...
    'spec', 8);

amygdala_voi = '/Volumes/Transcend/emocon_mri/spm/roi/amy_bilateral.nii';

acc_ofl = summarise(participants_file, first_level_dir, 'ofl', acc_voi, ...
    'US', 'con_0005.nii', ...
    'noUS', 'con_0007.nii', ...,
    'obs_UR', 'con_0009.nii');

amy_ofl = summarise(participants_file, first_level_dir, 'ofl', amygdala_voi, ...
    'US', 'con_0005.nii', ...
    'noUS', 'con_0007.nii', ...,
    'obs_UR', 'con_0009.nii');

% for de use models from other dir, we have a bit of a mess now
de_level1_dir = '/Volumes/Transcend/emocon_mri/spm/mot_out/first_level_longevent';

acc_de = summarise(participants_file, de_level1_dir, 'de', acc_voi, ...
    'CS_plus', 'con_0001.nii', ...
    'CS_minus', 'con_0002.nii', ...
    'CR', 'con_0003.nii');

amy_de = summarise(participants_file, de_level1_dir, 'de', amygdala_voi, ...
    'CS_plus', 'con_0001.nii', ...
    'CS_minus', 'con_0002.nii', ...
    'CR', 'con_0003.nii');

out_dir = '/Users/michal/Desktop';
writetable(acc_ofl, fullfile(out_dir, 'acc_ofl.csv'));
writetable(amy_ofl, fullfile(out_dir, 'amy_ofl.csv'));
writetable(acc_de, fullfile(out_dir, 'acc_de.csv'));
writetable(amy_de, fullfile(out_dir, 'amy_de.csv'));


function tbl = summarise(participants_file, first_level_dir, task, xY, ...
                         varargin)
    % SUMMARISE extracts parameters averaged within VOI from given files
    % 
    % participants_file - path to a text file containing a table with at
    %                     least two columns: subject & group
    % first_level_dir   - path to the directory with 1st level models;
    %                     should be organised into subfolders named: 
    %                     <subject>_<task>
    % task              - task name
    % xY                - region of interest specification, either VOI
    %                     structure from spm_ROI or a mask image filename;
    %                     spherical voi can be defined as struct(...
    %                     'def', 'sphere', 'xyz', [x, y, z]', 'spec', r)
    %                     where x, y, z are coordinates and r is radius
    % varargin          - possibly multiple pairs of name, filename
    %                     e.g. 'CR', 'con_0001.nii'; the name will be
    %                     used to name output columns

    tbl = readtable(participants_file, 'TextType', 'string');
    tbl = tbl(:, {'subject', 'group'});

    for n = 1:2:length(varargin)
        con_name = varargin{n};
        con_file = varargin{n+1};
        
        file_list = char(fullfile(...
            first_level_dir, tbl.subject + "_" + task, con_file));
        [y, ~] = spm_summarise(file_list, xY, @mean);
        tbl.(con_name) = y;
    end
end