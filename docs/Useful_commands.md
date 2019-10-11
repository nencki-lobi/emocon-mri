Useful commands
===============

This document lists several commands, which do not need to be placed in scripts,
which were used for certain tasks.

### Ffmpeg - converting video

Join two .mp4 files:
```
ffmpeg -f concat -i mylist.txt -c copy OUTPUT
```

Convert a video, selecting a fragment (18:03 long) and changing resolution:
```
../ffmpeg-4.1.3/ffmpeg -ss 00:27.367 -i INFILE.mp4 -t 18:03 \
  -vf scale=1440:1080 -c:v libx264 -an -strict -experimental OUTFILE.avi
```

### Heudiconv - conversion to BIDS

```
docker run --rm -it \
-v /Volumes/MyBookPro/emocon_mri/dicom:/dicomdir:ro \
-v /Volumes/MyBookPro/emocon_mri/emotional_contagion:/out \
-v /Users/michal/Documents/emocon_mri_study/utils/emocon_heuristic.py:/emocon_heuristic.py:ro \
nipy/heudiconv:0.5.4 \
-d "/dicomdir/Ec_{subject}/*/*/*.dcm" \
-o /out \
-f /emocon_heuristic.py \
-c dcm2niix \
-b --overwrite --minmeta \
-s Qetwjz Raljam Rjqmzc Slcpsu Wjydns Yxjduz Ztlxhi Zuibrx Zvcapy
```

When working with data obtained through XNAT, use the following dicom dir
template instead:

```
-d "/dicomdir/Ec_{subject}/*/*/DICOM/*.dcm"
```

### Sed - fixing vhdr files

There is a missing whitespace between _Name_ and _Phys. Chn._ columns in the vhdr
files saved in our study, which confuses mne-python (at least version 0.18).
This can be fixed by:
```
sed -i .bak 's/GSR_MR_100_R_hand9/GSR_MR_100_R_hand    9/' *.vhdr
```
The `-i` option means inplace and accepts extension for creating copies of
original files (`-i` without extension means inplace, no copies).

When renaming files, the following can be helpful:
```
sed 's/OLDCODE/NEWCODE/' OLDCODE.vhdr > NEWCODE.vhdr
rm OLDCODE.vhdr
```


### Installing iPython kernel for a virtual environment

To be able to use use the virtual environment in Jupyter notebooks, run the
following within the activated environment:
```
python -m ipykernel install --user --name myenv --display-name "Python (myenv)"
```
The `--name` value is used by Jupyter internally. These commands will overwrite
any existing kernel with the same name. `--display-name` is what you see in the
notebook menus.

To uninstall kernel when no longer needed, probably this is the way:
```
jupyter kernelspec remove <name>
```
