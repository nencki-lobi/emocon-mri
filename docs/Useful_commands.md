Useful commands
===============

This document lists several commands, which do not need to be placed in scripts,
which were used for certain tasks.

### Ffmpeg - converting video

Join two .mp4 files:
`ffmpeg -f concat -i mylist.txt -c copy OUTPUT`

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
