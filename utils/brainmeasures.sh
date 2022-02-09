#!/bin/bash


#################################################################################
##          STRUCTURAL BRAIN MEASURES: VSCALE, GM volume and WM volume         ##
## Description:                                                                ##
## This code is for calculate the brain volume escale comparing to MNI152      ##
## brain template, the gray matter volume and the white mater volume           ##
#################################################################################


if [ -f /project/data/brainMeasures.tsv ]
then
	rm /project/data/brainMeasures.tsv
fi

echo "PARTICIPANT	BRAINSCALE	GRAYMATTERVOL	WHITEMATTERVOL" > /data/brainMeasures.tsv

while read line
do
	participant=$( echo ${line} | awk '{ print $1 }')

	sienax Preproc/Anat/${participant}_acpc/${participant}_acpc.nii.gz -B "-B -f 0.1 -s -m" -d -S "i 20"
	vscale=$(grep VSCALING Preproc/Anat/${participant}_acpc/${participant}_acpc_sienax/report.sienax | awk '{ print $2 }') 
	gm_scale=$(grep GREY Preproc/Anat/${participant}_acpc/${participant}_acpc_sienax/report.sienax | awk '{ print $2 }') 
	wm_scale=$(grep WHITE Preproc/Anat/${participant}_acpc/${participant}_acpc_sienax/report.sienax | awk '{ print $2 }') 
	echo "${participant}	${vscale}	${gm_scale}	${wm_scale}" >> /project/data/brainMeasures.tsv
	
done < /project/data/participants.tsv
