"""Postprocess peak table produced by atlasreader

Makes small changes for better copy-paste-ability. Selects and keeps
only the most probable label from the harvard-oxford atlas.

Numpy and Pandas are dependencies of atlasreader, so this script will
work in the same virtual environment as the atlasreader.
"""

import argparse
import numpy as np
import os
import pandas as pd


def pick_most_likely(entry):
    first = entry.split(";")[0].rstrip()
    _, label = first.split("% ")
    label = label.replace('_', ' ')
    return label


parser = argparse.ArgumentParser()
parser.add_argument('peak_table')
args = parser.parse_args()

CLUSTER_VOL = 2**3

# Read table
df = pd.read_csv(args.peak_table)

# Add column with voxels
df['n_vox'] = (df.volume_mm / CLUSTER_VOL).astype('int')

# Pick most likely label, replace the original column
df['label'] = df.harvard_oxford.map(pick_most_likely)
df.drop(columns='harvard_oxford', inplace=True)

# Find which rows correspond to the cluster above
is_repeat = [False]
for n in range(1, df.shape[0]):
    is_repeat.append(df.cluster_id[n] == df.cluster_id[n-1])

# Convert cluster_id, volume_mm and n_vox to strings for easier handling
df.cluster_id = df.cluster_id.astype('str')
df.volume_mm = df.volume_mm.astype('str')
df.n_vox = df.n_vox.astype('str')

# Make blank the cells which repeat values from above (for clarity)
df.loc[is_repeat, ['cluster_id', 'volume_mm', 'n_vox']] = ""

# Convert peak coordinates to integers
df.peak_x = np.ceil(df.peak_x).astype('int')
df.peak_y = np.ceil(df.peak_y).astype('int')
df.peak_z = np.ceil(df.peak_z).astype('int')

# Save the table in the same directory, with _nice suffix
path, fname = os.path.split(args.peak_table)
df.to_csv(os.path.join(path, fname.replace('_peaks.csv', '_nice.csv')),
          float_format = '%.2f', index=False)
