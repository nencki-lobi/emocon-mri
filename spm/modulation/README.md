# Modulation

This repository contains scripts used when testing effects of applying / not applying modulation to SPM first level models.

## Workflow overview

### Prerequisites
Requires both raw and preprocessed BIDS data, as well as a table of participants to be included and a table of EDA amplitudes.

The scripts also require unzipped brain masks. The unzipping into the right folder is handled by `unpack_brain_masks.py` scripts in the upper `utils` directory.

### Data selection
The `select_data` script rewrites the participant table, taking into account the availability of EDA data. It also checks the event files to count the number of volumes to be discarded at the beginning of DE (in friend group, videos contaied also the instructions displayed to the demonstrator, and the scanner was running throughout the whole video), and creates accordingly trimmed copies of the confound files.

The `create_mod_events` script creates both _vanila_ and modulated condition files for both OFL and DE.

### Modelling
Since the first level model batch requires the same kind of inputs (output directory, selected frames, multiple conditions, multiple regressors, explicit mask) regardless of analysis variant, this is handled by `firstLevelFactory` function and `first_level_job` spm job. The calls to the function should be stored in a script.

The contrast batches differ depending on the analysis variant, and are stored in separate scripts.
