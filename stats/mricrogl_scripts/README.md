MricroGL scripts to generate crossections.

Need to be run with mricrogl, not regular python, e.g.:
```/Applications/MRIcroGL.app/Contents/MacOS/MRIcroGL script.py```

Paths are hardcoded, because it is hard to work with configparser and
relative paths from a mricrogl script. Uses maps already thresholded
(both for peaks and cluster sizes) in SPM.

Before running, it is good to make sure that the convention is set to
neurological and not radiological (mricrogl preferences), so that left
hemisphere is on the left side. These scripts do most of the work
(background colors, no crosshair, min/max value, selecting a
crossection, etc.) but some changes (colorbar background) need to be
done manually.

On a Mac, mricroGL produced images with 2576 x 2576 resolution. I
cropped the coronal slice to 2576 x 2380 using GIMP, so that it fit
nicely with other elements. I assembled the final graphics using
Inkscape. I also cropped the colorbar (same colormap across images)
and annotated the endpoints manually for most of the graphics.
