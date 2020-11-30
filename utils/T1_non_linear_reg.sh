#!/bin/bash

sub=$1
path=$2

export ANTSPATH=/usr/lib/ants/
source /usr/lib/ants/antsRegistrationSyN.sh -d 3 \
	-f ${path}/MNI152_T1_2mm_brain.nii.gz \
	-m ${path}/Preproc/Anat/${sub}.anat/T1_biascorr_brain.nii.gz \
	-o ${path}/Preproc/Anat/${sub}.anat/ants_mat

antsApplyTransforms -d 3 -r ${path}/MNI152_T1_2mm_brain.nii.gz \
	-i ${path}/Preproc/Anat/${sub}.anat/T1_biascorr_brain.nii.gz -e 0 \
	-t ${path}/Preproc/Anat/${sub}.anat/ants_mat1Warp.nii.gz \
	-t ${path}/Preproc/Anat/${sub}.anat/ants_mat0GenericAffine.mat \
	-o ${path}/Preproc/Anat/${sub}.anat/${sub}_nonlin.nii.gz -v 1