#!/bin/bash


#################################################################################
##                       ANATOMICAL /project/PreprocESSING OF T1 images                 ##
## Description:                                                                ##
## This code is for /project/Preprocessing the anatomical T1 image and perform brain    ##
## extraction and tissue segmentation                                          ##
#################################################################################

participant=$1

mkdir -p /project/Preproc/Anat/${participant}_acpc
mkdir -p /project/Preproc/BET
mkdir -p /project/Preproc/ProbTissue

cd /project/Preproc/Anat/${participant}_acpc

#Alignment to the ac-pc line
/app/utils/acpc_realign.sh /project/data/${participant}/anat/*.nii.gz \
    /project/Preproc/Anat/${participant}_acpc/${participant}_acpc.nii.gz \
    /app/brain_templates/MNI152_T1_1mm.nii.gz

#Scanner biasfield correction
acpc_path="/project/Preproc/Anat/${participant}_acpc/${participant}_acpc.nii.gz"
biascorr_path="/project/Preproc/Anat/${participant}_acpc/${participant}_biascorr.nii.gz"
N4BiasFieldCorrection -d 3 -i $acpc_path -o $biascorr_path

# Shift histogram of bias-field corrected image (*_biascorr) to the *_acpc image histogram
# This is done to make sure that the bias-field corrected image has the same intensity distribution as the original image
fslmaths $biascorr_path -mul $ratio -output $biascorr_path
# Save ratio in file
# The ratio is the median of the acpc image divided by the median of the bias-field corrected image
ratio=$(echo "scale=10; $(fslstats $acpc_path -p 50)/$(fslstats $biascorr_path -p 50)" | bc)  #scale=10 gives 10 decimal places
echo $ratio > /project/Preproc/Anat/${participant}_acpc/${participant}_acpc_biascorr_medians_ratio.txt

#Brain extraction
antsBrainExtraction.sh -d 3 \
    -a /project/Preproc/Anat/${participant}_acpc/${participant}_biascorr.nii.gz \
    -e /app/brain_templates/MNI152_T1_2mm.nii.gz \
    -m /app/brain_templates/MNI152_T1_2mm_brain_mask.nii.gz \
    -o /project/Preproc/Anat/${participant}_acpc/${participant}_

#Brain tissue segmentation
antsAtroposN4.sh -d 3 \
    -a /project/Preproc/Anat/${participant}_acpc/${participant}_BrainExtractionBrain.nii.gz \
    -x /project/Preproc/Anat/${participant}_acpc/${participant}_BrainExtractionMask.nii.gz \
    -c 4 -o /project/Preproc/Anat/${participant}_acpc/${participant}_

#Copy brain and tissue probability maps to the project folders
echo "Copying files"

cp /project/Preproc/Anat/${participant}_acpc/${participant}_BrainExtractionBrain.nii.gz /project/Preproc/BET/${participant}_T1w_brain.nii.gz
cp /project/Preproc/Anat/${participant}_acpc/${participant}_SegmentationPosteriors1.nii.gz /project/Preproc/ProbTissue/${participant}_T1w_brain_CSF.nii.gz
cp /project/Preproc/Anat/${participant}_acpc/${participant}_SegmentationPosteriors2.nii.gz /project/Preproc/ProbTissue/${participant}_T1w_brain_corticalGM.nii.gz
cp /project/Preproc/Anat/${participant}_acpc/${participant}_SegmentationPosteriors3.nii.gz /project/Preproc/ProbTissue/${participant}_T1w_brain_subcorticalGM.nii.gz
cp /project/Preproc/Anat/${participant}_acpc/${participant}_SegmentationPosteriors4.nii.gz /project/Preproc/ProbTissue/${participant}_T1w_brain_WM.nii.gz
