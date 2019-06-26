import argparse
import os
import re
import nipype.interfaces.spm as spm

from nipype.interfaces.utility import IdentityInterface
from nipype.interfaces.io import SelectFiles, DataSink
from nipype.algorithms.misc import Gunzip
from nipype.pipeline.engine import Workflow, Node


# Specify paths
DERIV_DIR = '/opt/ssd/mszczepanik/emocon/derived'
WORK_DIR = '/opt/ssd/mszczepanik/emocon/work'

# Allow specifying participant codes
parser = argparse.ArgumentParser()
parser.add_argument('--participant_label', nargs='+')
args = parser.parse_args()

# If codes are not specified, use all found
if args.participant_label is not None:
    codes = args.participant_label
else:
    pat = re.compile('sub-(\w{6})$')
    codes = []
    for f in os.listdir(os.path.join(DERIV_DIR, 'fmriprep')):
        m = re.match(pat, f)
        if m is not None:
            codes.append(m.group(1))
        codes.sort()


# Set file templates and task names
func_template = os.path.join(
    'fmriprep',
    'sub-{subject_id}',
    'func',
    ('sub-{subject_id}_task-{task_label}_space-MNI152NLin2009cAsym_'
     'desc-preproc_bold.nii.gz'),
    )

task_names = ['ofl', 'de']

# gunzip
gunzip = Node(Gunzip(), name='gunzip')

# smoothing node, with in_files undefined
smooth = Node(spm.Smooth(), name='smooth')
smooth.inputs.fwhm = [8, 8, 8]
smooth.inputs.out_prefix = 'sm8_'

# an identity interface to distribute inputs
infosource = Node(IdentityInterface(fields=['subject_id', 'task_label']),
                  name='infosource')
infosource.iterables = [('subject_id', codes),
                        ('task_label', task_names)]

# SelectFiles
templates = {'func': func_template}
selectfiles = Node(SelectFiles(templates, base_directory=DERIV_DIR),
                   name='selectfiles')

# DataSink
datasink = Node(DataSink(base_directory=DERIV_DIR, container='spm'),
                name='datasink')

# nodes add pre-/postfix to file or folder, change it
datasink.inputs.substitutions  = [('_subject_id_', 'sub-')]
datasink.inputs.regexp_substitutions = [('_task_label_[a-z]+', '')]

# create workflow
wf = Workflow(name='smooth_wf')
wf.base_dir = WORK_DIR

wf.connect([
    (infosource, selectfiles, [('subject_id', 'subject_id'),
                               ('task_label', 'task_label')]),
    (selectfiles, gunzip, [('func', 'in_file')]),
    (gunzip, smooth, [('out_file', 'in_files')]),
    (smooth, datasink, [('smoothed_files', 'smooth')])
    ])

wf.run('MultiProc', plugin_args={'n_procs': 4})
