% Runs util.voi & stats.ppi batch modules

my_config = ini2struct('../../../config.ini');

% what goes where
roi_dir = fullfile(my_config.spm.root, "roi");
fl_dir  = fullfile(my_config.spm.root, "complete", "first_level");
tbl_dir = fullfile(my_config.spm.root, "complete", "other");

subject_table = readtable(fullfile(tbl_dir, "included_participants.csv"), ...
    'TextType', 'string');


nrun = height(subject_table);
jobfile = {'../ppi_shared/timeseries_extraction_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(8, nrun);

% subject - independent variables
task = "de";
voi_name = 'aMCC';
voi_image = cellstr(fullfile(roi_dir, 'seed_aMCC_vox200.nii'));
weights = [1 1 1; 2 1 -1];  % CS+ (1), CS- (-1)
ppi_name = 'aMCCxCS';


for crun = 1:nrun
    
    base_model = cellstr(fullfile(...
        fl_dir, subject_table.label(crun) + "_" + task, "SPM.mat"));
    
    inputs{1, crun} = base_model; % Volume of Interest: Select SPM.mat - cfg_files
    inputs{2, crun} = 6; % Volume of Interest: Adjust data - cfg_entry
    inputs{3, crun} = 1; % Volume of Interest: Which session - cfg_entry
    inputs{4, crun} = voi_name; % Volume of Interest: Name of VOI - cfg_entry
    inputs{5, crun} = voi_image; % Volume of Interest: Image file - cfg_files
    inputs{6, crun} = base_model; % Physio/Psycho-Physiologic Interaction: Select SPM.mat - cfg_files
    inputs{7, crun} = weights; % Physio/Psycho-Physiologic Interaction:  Input variables and contrast weights - cfg_entry
    inputs{8, crun} = ppi_name; % Physio/Psycho-Physiologic Interaction: Name of PPI - cfg_entry
end

% Setting voi_adjust to 6 because the F contrast was added last, and
% therefore it is 6th inside SPM.xCon

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
