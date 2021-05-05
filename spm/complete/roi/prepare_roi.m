% Prepare ROIs based on Neurovault collection 2462
%
% This script downloads and unpacks files from neurovault, and merges
% some of the roi, if the files are not present already.
%
% Fetches files from Neurovault collection "Computing the Social Brain
% Connectome Across Systems and States", based on a publication with the
% same title from 2017 by Alcala-Lopez Alcalá-López et al.
%   collection: https://identifiers.org/neurovault.collection:2462
%   article doi:10.1093/cercor/bhx121 
%
% Following images are used:
%   left AI:    https://identifiers.org/neurovault.image:45309
%   right AI:   https://identifiers.org/neurovault.image:45325
%   aMCC:       https://identifiers.org/neurovault.image:45306
%   left  FFA:  https://identifiers.org/neurovault.image:45311
%   right FFA:  https://identifiers.org/neurovault.image:45327
%   right pSTS: https://identifiers.org/neurovault.image:45337
%   right TPJ:  https://identifiers.org/neurovault.image:45335
%
% The seeds for AI and the seeds for pSTS are combined to form a single
% ROI per structure (bilateral) using spm_imcalc.
%
% Some ROIs are not created in this script. The regional definition for
% Amygdala is taken from the harvard - Oxford atlas; it is created by the
% script in utils/create_roi_masks.py. An alternative definition of ACC 
% (more extensive, used for PPI but not ROI analysis) was obtained from
% Björn R Lindström.

my_config = ini2struct('../../../config.ini');

roi_dir = fullfile(my_config.spm.root, 'roi');

% Create the ROI dir if it does not exist
if ~ isfolder(roi_dir)
    mkdir(roi_dir);
end

% Expecting to find the following files:
file_names = [
    "seed_lAI_vox200.nii";
    "seed_rAI_vox200.nii";
    "seed_aMCC_vox200.nii";
    "seed_lFFA_vox200.nii";
    "seed_rFFA_vox200.nii";
    "seed_rpSTS_vox200.nii";
    "seed_rTPJ_vox200.nii";
    ];

% If files are missing, download them from Neurovault (collection_id 2462)
base_url = "https://neurovault.org/media/images/2462/";
for n = 1:length(file_names)
    if ~ isfile(fullfile(roi_dir, file_names(n)))
        gunzip(base_url + file_names(n) + ".gz", roi_dir)
    end
end

% Merge left & right AI using imcalc

merged_ai = fullfile(roi_dir, 'merged_seed_AI_vox200.nii');

if ~ isfile(merged_ai)
    vi = [
        fullfile(roi_dir, 'seed_lAI_vox200.nii');
        fullfile(roi_dir, 'seed_rAI_vox200.nii');
        ];
    vo = spm_imcalc(vi, merged_ai, 'i1 + i2');
end

% Merge left & right FFA using imcalc

merged_ffa = fullfile(roi_dir, 'merged_seed_FFA_vox200.nii');

if ~ isfile(merged_ffa)
    vi = [
        fullfile(roi_dir, 'seed_lFFA_vox200.nii');
        fullfile(roi_dir, 'seed_rFFA_vox200.nii');
        ];
    vo = spm_imcalc(vi, merged_ffa, 'i1 + i2');
end
