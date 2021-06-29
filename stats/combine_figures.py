"""
Combine figures into one, multi-panel figure

Uses Pillow to combine png files and add letter caption. Applied to
the main figures for OFL and DE (where stat maps are generated in
python and bar plots in R).

Requires a locally placed font (ttf file). Currently using Liberation
Sans, one possible alternative is Arimo - both are closely related,
and are metrically compatible with Arial.
"""

from PIL import Image, ImageFont, ImageDraw

def points2pixels(pt, img):
    """ Get pixel size representing a given point size for a given image """
    return int(pt / 72 * img.info['dpi'][0])

def paste_horiz(img_list):
    """ Join images horizontally """
    total_width = sum([img.width for img in img_list])
    new_img = Image.new(img_list[0].mode, (total_width, img_list[0].height))
    current_pos = 0
    for img in img_list:
        new_img.paste(img, (current_pos, 0))
        current_pos += img.width
    return new_img

def combine_horiz(img_list, captions, font, text_pos=(15, 10)):
    """ Caption and join images horizontally """
    for n in range(len(img_list)):
        draw = ImageDraw.Draw(img_list[n])
        draw.text(
            xy = text_pos,
            text = captions[n],
            fill = (0, 0, 0),
            font = font,
        )
    concat_img = paste_horiz(img_list)
    return(concat_img)

# Load images
stat_maps_ofl = Image.open('figures/stat_maps_ofl.png')
stat_maps_de = Image.open('figures/stat_maps_de.png')
roi_ofl = Image.open('figures/roi_ofl.png')
roi_de = Image.open('figures/roi_de.png')

# Set font to be used - dpi is the same for all
font = ImageFont.truetype(
    font = 'fonts/LiberationSans-Bold.ttf',
    size = points2pixels(12, stat_maps_ofl)
    )

# Make combined figure for OFL
path_ofl = 'figures/stat_maps_and_roi_ofl.png'
fig_ofl = combine_horiz([stat_maps_ofl, roi_ofl], 'AB', font)
fig_ofl.save(path_ofl, dpi=(300,300))

# Make combined figure for DE
path_de = 'figures/stat_maps_and_roi_de.png'
fig_de = combine_horiz([stat_maps_de, roi_de], 'AB', font)
fig_de.save(path_de, dpi=(300,300))
