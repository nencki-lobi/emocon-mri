DATA_MOUNT="/opt/ssd/mszczepanik/emocon/emotional_contagion:/data:ro"
OUT_MOUNT="/opt/ssd/mszczepanik/emocon/derived:/out"
WORK_MOUNT="/opt/ssd/mszczepanik/emocon/work:/work"

export SINGULARITY_BINDPATH=$DATA_MOUNT,$OUT_MOUNT,$WORK_MOUNT
unset ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

./fmriprep.simg --nthreads 16 \
	       --omp-nthreads 8 \
	       --mem-mb 48000 \
	       --output-spaces MNI152NLin2009cAsym:res-2 \
	       --fs-license-file license.txt \
	       --fs-no-reconall \
	       -w /work \
	       --resource-monitor \
	       /data /out participant
