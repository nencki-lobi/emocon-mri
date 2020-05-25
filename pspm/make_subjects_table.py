"""Subject table maker

We have two subject tables: BIDS participants file and excel with all
questionnaires. While they could be organised better, we live in a mess and the
purpose of this script is to merge information from both and output a nice
table of participants which can be used in PsPM scripting.
"""

import configparser
import os
import pandas

config = configparser.ConfigParser()
config.read('config.ini')
qdir = config['DEFAULT']['QUESTIONNAIRE_DIR']

df = pandas.read_excel(os.path.join(qdir, 'ANKIETY_fmri2019_odwrócone.xlsx'))

"""Remove unnecessary rows
The spreadsheet has subjects for whom the same video was reused ("actor"),
as well as 2 participants who should be dropped:
    TRLTDN - massive video playback issues
    CGOTOP - video shown mirrored, replaced by ORTKLP
We should also consider PLARRE, who also saw mirrored video, however he was not
replaced.
"""

df = df[df['Wersja stranger'] != 'aktor']
df = df[~df.Kod.isin(['TRLTDN1', 'CGOTOP1'])]
df.reset_index(inplace=True, drop=True)

# Take only observers i.e. MRI participants and useful columns
obs = df.query('Rola == "OBS"').loc[:, ('Kod', 'Grupa', 'CONTINGENCY')]

# Make table content more sane
obs.rename(
    columns={'Kod': 'label', 'Grupa': 'group', 'CONTINGENCY': 'contingency'},
    inplace=True
    )
obs.label = obs.label.str.capitalize().str.extract('(\D+)')  # \D = non-digit
obs.contingency = obs.contingency.map({'TAK': True, 'NIE': False})

# save
pspmdir = config['PSPM']['ROOT']
if not os.path.exists(pspmdir):
    os.mkdir(pspmdir)
obs.to_csv(os.path.join(pspmdir, 'participants.csv'), index=False)
