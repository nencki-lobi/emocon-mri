import argparse
import configparser
import matplotlib.pyplot as plt
import numpy as np

from bids import BIDSLayout

config = configparser.ConfigParser()
config.read('config.ini')
BIDS_ROOT = config['DEFAULT']['BIDS_ROOT']

parser = argparse.ArgumentParser()
parser.add_argument('participant_label')
args = parser.parse_args()

layout = BIDSLayout(BIDS_ROOT, validate=False)

files = layout.get(
    subject=args.participant_label,
    suffix='physio',
    extension='tsv.gz',
    )

print(files)
print(files[0].entities['task'])
print(files[0].entities['SamplingFrequency'])
print(files[0].entities['StartTime'])
print(files[0].filename)
