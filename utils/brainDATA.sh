#!/bin/bash

###########################################################
#                                                         #
#		  VBM launcher                                    #
#                                                         #
###########################################################
#

#SBATCH -n 1 # Number of cores
#SBATCH -p medium # Partition
#SBATCH --mem 4000 # Memory request
#SBATCH -o LOG/anat/measures.out # Standard output
#SBATCH -e LOG/anat/measures.err # Standard error

ml load FSL

export FSLOUTPUTTYPE=NIFTI_GZ

project_root=PROJECT_PATH

if [ -f ${project_root}/DATA/brainMeasures.tsv ]
then
	rm ${project_root}/DATA/brainMeasures.tsv
fi

echo "PARTICIPANT	BRAINSCALE	GRAYMATTERVOL	WHITEMATTERVOL" > ${project_root}/DATA/brainMeasures.tsv

while read line
do
	bids=$( echo ${line} | awk '{ print $1 }')
	orig=$( echo ${line} | awk '{ print $2 }')

	
	sienax ${project_root}/Preproc/Anat/${bids}_acpc/${bids}_acpc.nii.gz -B "-B -f 0.1 -s -m" -d -S "i 20"
	vscale=$(grep VSCALING ${project_root}/Preproc/Anat/${bids}_acpc/${bids}_acpc_sienax/report.sienax | awk '{ print $2 }') 
	gm_scale=$(grep GREY ${project_root}/Preproc/Anat/${bids}_acpc/${bids}_acpc_sienax/report.sienax | awk '{ print $2 }') 
	wm_scale=$(grep WHITE ${project_root}/Preproc/Anat/${bids}_acpc/${bids}_acpc_sienax/report.sienax | awk '{ print $2 }') 
	echo "${orig}	${vscale}	${gm_scale}	${wm_scale}" >> ${project_root}/DATA/brainMeasures.tsv
	
done < ${project_root}/DATA/participants.tsv