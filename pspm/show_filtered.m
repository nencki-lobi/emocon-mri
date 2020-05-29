% Show raw & filtered signal

% establish paths
my_config = ini2struct('../config.ini');
bids_root = my_config.default.bids_root;
pspm_root = my_config.pspm.root;

subject = "Ortklp";
task = "ofl";

% fetch data
trimmed_data = load(fullfile(pspm_root, "scr", ...
    "tpspm_" + upper(subject) + "_" + task + ".mat"));
eda = trimmed_data.data{1,1}.data;
sr = trimmed_data.data{1,1}.header.sr;

raw = eda;

% filter & downsample
fn = sr / 2;

[b, a] = butter(1, 5/fn, 'low');
eda = filtfilt(b, a, eda);

[b, a] = butter(1, 0.0159/fn, 'high');
eda = filtfilt(b, a, eda);

newsr = 10;
eda = resample(eda, newsr, sr);
sr = newsr;

duration = length(eda) / sr;
t_raw = linspace(0, duration, length(raw));
t_res = linspace(0, duration, length(eda));

tiledlayout(2,1)

ax1 = nexttile;
plot(t_raw, raw)

ax2 = nexttile;
plot(t_res, eda)

linkaxes([ax1 ax2], 'x')
