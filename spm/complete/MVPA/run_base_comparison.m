% This script calls the run_decoding_analysis function to run the classification on the Friend and Stranger groups


results = {};
subjects_a = {'Alamal', 'Assyxo', 'Bcwtzp', 'Cgfiyn', 'Dmptjg', 'Dugicf', 'Erdsok',... 
    'Framwy', 'Gyfxou', 'Hbnkdv', 'Hhlkno', 'Hpjrlq', 'Hqhukz', 'Hvdpmg', 'Hwtfrx',... 
    'Jvbsdn', 'Lgbbcq', 'Pazhlq', 'Phybhi', 'Qecbif', 'Qetwjz', 'Qoqgvr', 'Qxulid',... 
    'Raljam', 'Rjqmzc', 'Rytnow', 'Sytnks', 'Tlfluw', 'Upiyls', 'Wmaqcx', 'Ydtval',... 
    'Yxjduz', 'Zrzxcw', 'Ztlxhi', 'Zuibrx'};
subjects_b = {'Gptfwi', 'Fceasy', 'Indjeu', 'Pulemy', 'Uhbrgt', 'Sbrgwt', 'Becund',...
    'Aqtorp', 'Qyjdla', 'Sopler', 'Rykpol', 'Wratex', 'Dvupak', 'Grodar', 'Makkak',...
    'Fudoss', 'Krulak', 'Glumpy', 'Czuhru', 'Ekrels', 'Frosty', 'Vczzke', 'Efuojl',...
    'Weroxo', 'Yllszo', 'Kjgixp', 'Bgrmus', 'Svnpog', 'Axqftz', 'Jlazpo', 'Aflqrp',...
    'Ddpqrp', 'Xfpolo', 'Rkrtyk'};

% Run decoding analysis
ret_a = run_decoding_analysis(subjects_a, 0, 'friends');
ret_b = run_decoding_analysis(subjects_b, 0, 'strangers');

results{end+1} = {ret_a.accuracy_minus_chance.output, ret_b.accuracy_minus_chance.output};

% Calculate the relative differences between the groups
difference_base=ret_a.accuracy_minus_chance.output-ret_b.accuracy_minus_chance.output;

results