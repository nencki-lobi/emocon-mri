"""Subject table maker

In theory, the big table with behavioral info could be used by
subsequent scripts, but it is easier to do some wrangling first. This
script extracts the label, group and contingency columns from the big
table, selects the observers, and puts them in 'participants.csv' file
in the pspm analysis directory.
"""

import configparser
import os
import pandas

config = configparser.ConfigParser()
config.read('../config.ini')
qdir = config['DEFAULT']['QUESTIONNAIRE_DIR']

df = pandas.read_csv(os.path.join(qdir, 'table.tsv'), sep='\t')

# Take only observers i.e. MRI participants and useful columns
obs = df.query('role == "OBS"').loc[:, ('label', 'group', 'CONT_contingency')]

# Rename contingency & convert to boolean
obs.rename(
    columns={'CONT_contingency': 'contingency'},
    inplace=True
    )
obs.contingency = obs.contingency.map({'YES': True, 'NO': False})

# save
pspmdir = config['PSPM']['ROOT']
if not os.path.exists(pspmdir):
    os.mkdir(pspmdir)
obs.to_csv(os.path.join(pspmdir, 'participants.csv'), index=False)
