function outputArg1 = extractBetas(centre, radius)
%EXTRACTBETAS Extract beta parameters from a location across many subjects
%   Note that this function has some hardcoded elements and will need to be
%   updated.
%   Extract values from a spherical voi with a given centre & radius. If
%   radius is 0, values are extracted from a given voxel coordinates.

subject_table = '/Volumes/MyBookPro/emocon_mri/spm/mot_out/participants.csv'; % must have subject & group column
subjects = readtable(subject_table, 'TextType', 'string');

models_parent_dir = '/Volumes/MyBookPro/emocon_mri/spm/mot_out/PPI_OFL_RTPJxUS';
folder_pattern = 'sub-%s';

V = char(fullfile(...
    models_parent_dir, ...
    compose(folder_pattern, subjects.subject), ...
    'beta_0001.nii'));

% radius = 2;
% centre = [9 -32 43]';
if radius ~= 0
    xY = struct('def', 'sphere', 'spec', radius, 'xyz', centre);
else
    xY = centre;
end

m_beta = spm_summarise(V, xY, @mean);

subjects.m_beta = m_beta;

subjects.barcolor = zeros(height(subjects), 3);
for n = 1:height(subjects)
    % use containers.map in argument?
    if subjects{n, 'group'} == "friend"
        subjects{n, 'barcolor'} = [0 0.4470 0.7410];
    else
        subjects{n, 'barcolor'} = [0.8500 0.3250 0.0980];
    end
end

b = bar(subjects.m_beta);
b.FaceColor = 'flat';
b.CData = subjects.barcolor;

subjects.idx = [1:height(subjects)]';  % ideally sort first
f = subjects(subjects.group == "friend", :);
s = subjects(subjects.group == "stranger", :);

figure
hold on
bar(f.idx, f.m_beta, 'DisplayName', 'Friend');
bar(s.idx, s.m_beta, 'DisplayName', 'Stranger');

xlabel('Subject #');
ylabel('beta');

yline(mean(f.m_beta), 'Color', [0 0.4470 0.7410], 'DisplayName', 'Friend mean')
yline(mean(s.m_beta), 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'Stranger mean')

legend()

hold off

% stdby group can be calculated with:
% grpstats(subjects, 'group', 'std', 'DataVars', {'m_beta'})

outputArg1 = subjects;
end

