% This script randomly assigns subjects to groups A and B 1000 times and calls the run_decoding_analysis function to run the classification


all_subjects = {'Alamal', 'Assyxo', 'Bcwtzp', 'Cgfiyn', 'Dmptjg', 'Dugicf', 'Erdsok',... 
    'Framwy', 'Gyfxou', 'Hbnkdv', 'Hhlkno', 'Hpjrlq', 'Hqhukz', 'Hvdpmg', 'Hwtfrx',... 
    'Jvbsdn', 'Lgbbcq', 'Pazhlq', 'Phybhi', 'Qecbif', 'Qetwjz', 'Qoqgvr', 'Qxulid',... 
    'Raljam', 'Rjqmzc', 'Rytnow', 'Sytnks', 'Tlfluw', 'Upiyls', 'Wmaqcx', 'Ydtval',... 
    'Yxjduz', 'Zrzxcw', 'Ztlxhi', 'Zuibrx', 'Gptfwi', 'Fceasy', 'Indjeu', 'Pulemy',... 
    'Uhbrgt', 'Sbrgwt', 'Becund', 'Aqtorp', 'Qyjdla', 'Sopler', 'Rykpol', 'Wratex',... 
    'Dvupak', 'Grodar', 'Makkak', 'Fudoss', 'Krulak', 'Glumpy', 'Czuhru', 'Ekrels',... 
    'Frosty', 'Vczzke', 'Efuojl', 'Weroxo', 'Yllszo', 'Kjgixp', 'Bgrmus', 'Svnpog',... 
    'Axqftz', 'Jlazpo', 'Aflqrp', 'Ddpqrp', 'Xfpolo', 'Rkrtyk'};

% This is a constant enabling repetition of the analysis and obtaining the same results
rng(190602020);


% Create two matrices for storing the results
wynik_acc_chance=[]; % matrix 6 (ROI) x2 (random groups) x 1000 (permutations)
wynik_conf_mat=[]; %matrix 5d:  6 (ROI) x2 (random groups) x 1000 (permutations) x 2 x 2


% Set the subjects labels in a random order and then split into two groups 
for perm_id = 1:1000
    perm_subjects = all_subjects(randperm(numel(all_subjects)));
    subjects_a = {};
    subjects_b = {};
    midpoint = length(all_subjects)/ 2;
    for idx = 1:length(perm_subjects)
        elem = perm_subjects{idx};
        if (idx <= midpoint)
            subjects_a{end+1} = elem;
        else
            subjects_b{end+1} = elem;
        end
    end

% Run decoding analysis
    perm_subjects
    ret_a = run_decoding_analysis(subjects_a, perm_id, 'A')
    ret_b = run_decoding_analysis(subjects_b, perm_id, 'B')
    
    close all;

% Save the results in the matrices
    wynik_acc_chance(:,1,perm_id)=ret_a.accuracy_minus_chance.output;
    wynik_acc_chance(:,2,perm_id)=ret_b.accuracy_minus_chance.output;
    
    wynik_conf_mat(1,1,perm_id,:,:)= ret_a.confusion_matrix.output{1};
    wynik_conf_mat(2,1,perm_id,:,:)= ret_a.confusion_matrix.output{2};
    wynik_conf_mat(3,1,perm_id,:,:)= ret_a.confusion_matrix.output{3};
    wynik_conf_mat(4,1,perm_id,:,:)= ret_a.confusion_matrix.output{4};
    wynik_conf_mat(5,1,perm_id,:,:)= ret_a.confusion_matrix.output{5};
    wynik_conf_mat(6,1,perm_id,:,:)= ret_a.confusion_matrix.output{6};
    
    wynik_conf_mat(1,2,perm_id,:,:)= ret_b.confusion_matrix.output{1};
    wynik_conf_mat(2,2,perm_id,:,:)= ret_b.confusion_matrix.output{2};
    wynik_conf_mat(3,2,perm_id,:,:)= ret_b.confusion_matrix.output{3};
    wynik_conf_mat(4,2,perm_id,:,:)= ret_b.confusion_matrix.output{4};
    wynik_conf_mat(5,2,perm_id,:,:)= ret_b.confusion_matrix.output{5};
    wynik_conf_mat(6,2,perm_id,:,:)= ret_b.confusion_matrix.output{6};
    
end

% Save the output in the external file
save permutacje_DE wynik_acc_chance wynik_conf_mat

% Calculate the relative differences between the groups
difference_permutations_de=squeeze(wynik_acc_chance(:,1,:)-wynik_acc_chance(:,2,:));

% Calculate p-value of the difference between the real Friend>Stranger
% difference (difference_base calculated in the run_base_comparison.m
% script) and the 1000 random differences calculated above

pval = sum(abs(difference_permutations_de) >= repmat(abs(difference_base), 1, length(difference_permutations_de)), 2) / length(difference_permutations_de);
bonferroni = bonf_holm(pval);

