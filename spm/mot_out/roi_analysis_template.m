% ROI analysis template

condition1 = '';
condition2 = '';
contrast = 'con_0009.nii';

c1_name = '';
c2_name = '';
ctr_name = 'obs_UR';

first_level_dir = '/Volumes/Transcend/emocon_mri/spm/mot_out/first_level';
task = 'ofl';

xY = struct(...
    'def', 'sphere', ...
    'xyz', [6, 24, 36]', ...
    'spec', 8);  % or filename

participants_file = '/Volumes/Transcend/emocon_mri/spm/mot_out/participants.csv';

% analysis starts here

participants = readtable(participants_file, 'TextType', 'string');

% for the contrast
files = char(fullfile(first_level_dir, participants.subject + "_" + task, contrast));

[Y, xY] = spm_summarise(files, xY, @mean);
participants.(ctr_name) = Y;