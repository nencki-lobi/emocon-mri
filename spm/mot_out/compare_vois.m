% Compare (correlate) signals extracted with & without motion outliers.
% Uses Right Amygdala VOI.

my_config = ini2struct('../../config.ini');
spm_out_dir = my_config.spm.root;

new_dir = fullfile(my_config.spm.root, 'mot_out');
old_dir = fullfile(my_config.spm.root, 'allsub');

subjects = readtable(fullfile(new_dir, 'participants.csv'));

subjects(strcmp(subjects.subject, 'Qxulid'), :) = [];
subjects(strcmp(subjects.subject, 'Svnpog'), :) = [];

fig = figure();
rvalues = zeros(height(subjects), 1);

for k = 1:height(subjects)
    
    subject = subjects.subject{k};
    
    basic = load(fullfile(old_dir, 'level1_tmod1', ...
        sprintf('sub-%s_task-ofl', subject), ...
        'VOI_HarOxf_RAmy_1.mat'));
    scrubbed = load(fullfile(new_dir, 'first_level', ...
        sprintf('%s_ofl', subject), ...
        'VOI_RAmy_HarOxf_1.mat'));
    
    r = corr(basic.Y, scrubbed.Y);
    rvalues(k) = r;
    
%     hold on
%     plot(basic.Y, 'DisplayName', 'raw');
%     plot(scrubbed.Y, 'DisplayName', 'scrubbed');
%     
%     title(sprintf('sub-%s, r = %.2f', subjects.subject{k}, r));
%     xlabel('volume #');
%     legend
%     
%     fname = fullfile(new_dir, 'pictures', 'scrubbing', ...
%         strcat(subjects.subject{k}, '.png'));
%     
%     saveas(fig, fname);
%     clf(fig)
%     
end

figure
histogram(rvalues);
xlabel('r value');
ylabel('# occurrences');
fname = fullfile(new_dir, 'pictures', 'scrubbing', 'histogram.png');
saveas(gcf, fname)
