function eventinfo = get_condition_info(events_file)
%GET_CONDITION_INFO Get condition info from events file
%   Detailed explanation goes here

event_tab = readtable(events_file, 'FileType', 'text', 'TextType', 'string');

% decompose file path to get task name
[~, name, ~] = fileparts(events_file);
tok = regexp(name, 'task-([a-zA-Z]+)', 'tokens');
task = tok{1}{1};

eventinfo = struct();

if strcmp(task, 'ofl')
    % go trial by trial with lookahead to determine if reinf. or not
    
    event_tab.condition = strings(height(event_tab), 1);

    for n = 1:height(event_tab)
        if event_tab.trial_type(n) == "cs_plus" && event_tab.trial_type(n+1) == "us"
            % last cs+ always reinforced, so won't go OOB
            event_tab.condition(n) = "cs_plus_reinforced";
        elseif event_tab.trial_type(n) == "cs_plus"
            event_tab.condition(n) = "cs_plus_nonreinforced";
        elseif event_tab.trial_type(n) == "cs_minus"
            event_tab.condition(n) = "cs_minus";
        end
    end

    cs_trials = event_tab{startsWith(event_tab.trial_type, "cs"), "condition"}';
    
    % find trial indices for each condition
    idx_cspr = find(cs_trials == "cs_plus_reinforced");
    idx_cspn = find(cs_trials == "cs_plus_nonreinforced");
    idx_csm = find(cs_trials == "cs_minus");
    
    % build weights for CS+ > CS-
    weights_cs = ones(1, length(cs_trials));
    weights_cs(idx_csm) = -1;
    
    % build weights for US (apparently that's CS+ reinf > CS+ nonreinf)
    weights_us = zeros(1, length(cs_trials));
    weights_us(idx_cspr) = 1;
    weights_us(idx_cspn) = -1;
    
    % pack everything into a struct
    eventinfo.index.cs_plus_reinforced = idx_cspr;
    eventinfo.index.cs_plus_nonreinforced = idx_cspn;
    eventinfo.index.cs_minus = idx_csm;
    eventinfo.weights.cs = weights_cs;
    eventinfo.weights.us = weights_us;
    
else
    % de: just CSs, so finding indices is straightforward
    cs_trials = event_tab{startsWith(event_tab.trial_type, "cs"), "trial_type"}';
    idx_csp = find(cs_trials == "cs_plus");
    idx_csm = find(cs_trials == "cs_minus");

    % weights for CS+ > CS-
    weights_cs = ones(1, length(cs_trials));
    weights_cs(1, idx_csm) = -1;
    
    % pack everything into a struct
    eventinfo.index.cs_plus = idx_csp;
    eventinfo.index.cs_minus = idx_csm;
    eventinfo.weights.cs = weights_cs;

end

end
