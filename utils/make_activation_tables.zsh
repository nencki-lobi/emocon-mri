# Prepare activation tables using atlasreader
#
# NOTE: this is a record of commands used more than a regular script.
# Requires a python environment with atlasreader & crudini python
# packages, which is NOT the environment created with the requirements
# file. I used a separate virtualenv under python 3.7.9.

SPMROOT=`crudini --get ../config.ini SPM ROOT`
BASEDIR=$SPMROOT/complete
DIST=16

WORKDIR=$BASEDIR/atlasreader/obsUR
atlasreader -a harvard_oxford -t 5.42 -x pos -o $WORKDIR -d $DIST \
	    $BASEDIR/second_level/ofl_basic/obsUR_1sample/spmT_0001.nii \
	    30
python postprocess_peaks.py $WORKDIR/spmT_0001_peaks.csv

WORKDIR=$BASEDIR/atlasreader/deCR
atlasreader -a harvard_oxford -t 5.40 -x pos -o $WORKDIR -d $DIST \
	    $BASEDIR/second_level/de_basic/CR_1sample/spmT_0001.nii \
	    1
python postprocess_peaks.py $WORKDIR/spmT_0001_peaks.csv

WORKDIR=$BASEDIR/atlasreader/deCSPxTimePooled
atlasreader -a harvard_oxford -t 3.21 -x pos -o $WORKDIR -d $DIST \
	    $BASEDIR/second_level/de_extra/tmod_1sample/spmT_0001.nii \
	    105
python postprocess_peaks.py $WORKDIR/spmT_0001_peaks.csv

WORKDIR=$BASEDIR/atlasreader/deCSPxTimeBetween
atlasreader -a harvard_oxford -t 3.21 -x pos -o $WORKDIR -d $DIST \
	    $BASEDIR/second_level/de_extra/tmod_2sample/spmT_0001.nii \
	    95
python postprocess_peaks.py $WORKDIR/spmT_0001_peaks.csv

WORKDIR=$BASEDIR/atlasreader/ppiInsula
atlasreader -a harvard_oxford -t 3.21 -x pos -o $WORKDIR -d $DIST \
	    $BASEDIR/ppi_group/PPI_ofl_AIxUS/1_sample/spmT_0001.nii \
	    93
python postprocess_peaks.py $WORKDIR/spmT_0001_peaks.csv

WORKDIR=$BASEDIR/atlasreader/ppiPSTS
atlasreader -a harvard_oxford -t 3.21 -x pos -o $WORKDIR -d $DIST \
	    $BASEDIR/ppi_group/PPI_ofl_rpSTSxUS/1_sample/spmT_0001.nii \
	    91
python postprocess_peaks.py $WORKDIR/spmT_0001_peaks.csv

WORKDIR=$BASEDIR/atlasreader/ppiPSTSsvc
atlasreader -a harvard_oxford -t 2.1 -x pos -o $WORKDIR -d $DIST \
	    $BASEDIR/ppi_group/PPI_ofl_rpSTSxUS/1_sample/spmT_0001_thr_svc.nii\
	    1
python postprocess_peaks.py $WORKDIR/spmT_0001_thr_svc_peaks.csv
