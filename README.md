Emotional Contagion MRI study
======

Setting up
------

### Python

Create a virtual environment and then install packages using:
```
pip install -r requirements.txt
```

To install a kernel for this environment in jupyter, run:
```
python -m ipykernel install --user --name EmoConEnv --display-name "Python 3 (EmoCon)"
```
Detailed explanation [here](https://ipython.readthedocs.io/en/stable/install/kernel_install.html#kernels-for-different-environments).

### Matlab

[PsPM toolbox](http://pspm.sourceforge.net/) version 4.2.0 is needed for physiological data analysis.
[SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) is needed for fMRI data analysis. Update revision number 7487 was used.
[BIDS-Matlab](https://github.com/bids-standard/bids-matlab) toolbox and [ini2struct](https://www.mathworks.com/matlabcentral/fileexchange/17177-ini2struct) function are required by some scripts. They need to be added to the path.

### Troubleshooting

On Fedora 29, running files which were supposed to save feather files resulted in `ImportError: pyarrow is not installed` (even though if pyarrow was installed). Apparently this is not due to pyarrow itself and could be mitigated, according to [this discussion](https://issues.apache.org/jira/browse/BEAM-8110) by installing a system package `libnsl`:
```
dnf install libnsl
```
