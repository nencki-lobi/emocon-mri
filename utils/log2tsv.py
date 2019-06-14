import pandas

fpat = '/Volumes/MyBookPro/video-ofl/example_logfiles/{}-procedure OFL.log'
code = 'FRAMWY'

df = pandas.read_csv(fpat.format(code), sep='\t', skiprows=3)

rename_dict = {
    'Event Type': 'EventType',
    'Time': 'onset',
    'Duration': 'duration',
    'Code': 'trial_type',
    }

df.rename(columns=rename_dict, inplace=True)

# Find first pulse
first_pulse = df.query('EventType == "Pulse"').iloc[0].onset

# correct onset & duration
df.onset = (df.onset - first_pulse) / 10000
df.duration = df.duration / 10000

# Choose relevant rows & columns
subset = (
    df
    .query('trial_type in ["fix", "cs_plus", "cs_minus", "US_stim_ON"]')
    .loc[:, ['onset', 'duration', 'trial_type']]
    )

# Rename US trial_type
subset.trial_type.replace('US_stim_ON', 'us', inplace=True)

# Set us duration to 1.5 (which approximates how long the reaction lasts)
subset.loc[subset.trial_type == 'us', 'duration'] = 1.5

# Add 'value' column with corresponding port codes
subset.loc[:, 'value'] = subset.trial_type.map(
    {'cs_plus': 1, 'cs_minus': 2, 'fix': 7, 'us': 8}
)

print(subset.head())
