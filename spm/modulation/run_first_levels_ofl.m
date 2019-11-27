% Run the first levels
% using firstLevelFactory(task, event_subfolder, model_subfolder)

%% OFL pmod & nomod
firstLevelFactory('ofl',  'events_pmod', 'level1_pmod');
firstLevelFactory('ofl',  'events_nomod', 'level1_nomod');

%% DE pmod & nomod
firstLevelFactory('de',  'events_pmod', 'level1_pmod');
firstLevelFactory('de',  'events_nomod', 'level1_nomod');

%% tmod 1st order
firstLevelFactory('ofl', 'events_tmod1', 'level1_tmod1');
firstLevelFactory('de', 'events_tmod1', 'level1_tmod1');

%% tmod 2nd order
firstLevelFactory('ofl', 'events_tmod2', 'level1_tmod2');
firstLevelFactory('de', 'events_tmod2', 'level1_tmod2');
