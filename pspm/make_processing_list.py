""" Processing list maker

Check which subjects are included in MRI analysis, and have
processable skin conductance data, then write a list of calls to
dcm_process_*() which can be later called in parallel.
"""

import configparser
import os
import pandas

config = configparser.ConfigParser()
config.read('../config.ini')

# load and merge mri and pspm tables
mri = pandas.read_csv(os.path.join(
    config['SPM']['ROOT'], 'complete', 'other', 'included_participants.csv'))
scr = pandas.read_csv(os.path.join(
    config['PSPM']['ROOT'], 'process_scr.tsv'), delimiter='\t')

scr.label = scr.label.str.capitalize()
scr = scr.loc[scr.process == "YES", :]

both = pandas.merge(mri, scr, 'inner')

# prepare list of commands
cmds = []
for label in both.label:
    cmds.append('dcm_process_ofl("' + label + '")\n')
    cmds.append('dcm_process_de("' + label + '")\n')
cmds[-1] = cmds[-1].rstrip()

# write the list of commands
with open(os.path.join(config['PSPM']['ROOT'], 'to_call.txt'), 'wt') as f:
    f.writelines(cmds)
