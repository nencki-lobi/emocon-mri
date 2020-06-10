% Run the first levels
% using firstLevelFactory with inputs:
% (analysis_dir, task, event_subfolder, model_subfolder)

%% tmod 1st order
firstLevelFactory('allsub-halfdata', 'de', 'events', 'level1_de');
