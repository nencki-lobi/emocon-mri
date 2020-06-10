% Run the first levels
% using firstLevelFactory(task, event_subfolder, model_subfolder)

%% tmod 1st order
firstLevelFactory('allsub', 'ofl', 'events_tmod1', 'level1_tmod1');
firstLevelFactory('allsub', 'de', 'events_tmod1', 'level1_tmod1');
