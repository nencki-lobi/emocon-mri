def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes


def infotodict(seqinfo):
    """Heuristic evaluator for determining which runs belong where

    A few fields are defined by default:

    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group
    """

    t1w = create_key(
        'sub-{subject}/anat/sub-{subject}_T1w')
    obs = create_key(
        'sub-{subject}/func/sub-{subject}_task-ofl_bold')
    direct = create_key(
        'sub-{subject}/func/sub-{subject}_task-de_bold')

    info = {t1w: [], obs: [], direct: []}

    for idx, s in enumerate(seqinfo):

        # s is a namedtuple with fields equal to the names of the columns
        # found in dicominfo.txt
        if 'T1w' in s.protocol_name and not s.is_derived:
            info[t1w] = [s.series_id]
        elif 'task-ofl' in s.protocol_name and s.dim4 > 300:
            info[obs].append(s.series_id)
        elif 'task-de' in s.protocol_name and s.dim4 == 184:
            info[direct].append(s.series_id)
    return info
