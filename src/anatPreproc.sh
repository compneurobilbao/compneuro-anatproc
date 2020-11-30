#!/bin/bash

###########################################################
#                                                         #
#		  Anat Preprocessing launcher             #
#                                                         #
###########################################################
#
#SBATCH -J anatPreproc # A single job name for the array
#SBATCH -n 1 # Number of cores
#SBATCH -p medium # Partition
#SBATCH --mem 12000 # Memory request
#SBATCH -o LOG/anat/anat_%A_%a.out # Standard output
#SBATCH -e LOG/anat/anat_%A_%a.err # Standard error

ml load FSL
ml load Python
ml load Anaconda2

export FSLOUTPUTTYPE=NIFTI_GZ

cd PROJECT_PATH

patients=( DATA/RAW/* )

patientsRoot=PROJECT_PATH/DATA/RAW
patient="${patients[${SLURM_ARRAY_TASK_ID}]}"
patientname=$( basename $patient )

if [  -f "PROJECT_PATH/Preproc/Anat/${patientname}" ]; then
   echo "$patientname already processed"
else
   echo "*********************"
   echo "$patientname"
   echo "*********************"
 
   mkdir -p PROJECT_PATH/Preproc/Anat/${patientname}_acpc
   cd PROJECT_PATH/Preproc/Anat/${patientname}_acpc
   source PROJECT_PATH/Scripts/acpc_realign.sh ${patientsRoot}/${patientname}/anat/*.nii.gz PROJECT_PATH/Preproc/Anat/${patientname}_acpc/${patientname}_acpc.nii.gz $FSLDIR/data/standard/MNI152_T1_1mm.nii.gz 

    singularity exec /home/biocruces/comp-neuro/compneuro_wICA_AROMA.simg antsBrainExtraction.sh -d 3 -a PROJECT_PATH/Preproc/Anat/${patientname}_acpc/${patientname}_acpc.nii.gz \
	-e PROJECT_PATH/DATA/Standard/MNI152_T1_2mm.nii.gz -m PROJECT_PATH/DATA/Standard/MNI152_T1_2mm_brain_mask.nii.gz -o PROJECT_PATH/Preproc/Anat/${patientname}_acpc/${patientname}_
    singularity exec /home/biocruces/comp-neuro/compneuro_wICA_AROMA.simg antsAtroposN4.sh -d 3 -a PROJECT_PATH/Preproc/Anat/${patientname}_acpc/${patientname}_BrainExtractionBrain.nii.gz \
	-x PROJECT_PATH/Preproc/Anat/${patientname}_acpc/${patientname}_acpc_BrainExtractionMask.nii.gz -c 4 -o PROJECT_PATH/Preproc/Anat/${patientname}_acpc/${patientname}_

    echo "Copying files"

    cp PROJECT_PATH/Preproc/Anat/${patientname}_acpc/${patientname}_BrainExtractionBrain.nii.gz PROJECT_PATH/Preproc/BET/${patientname}_T1w_brain.nii.gz
    cp PROJECT_PATH/Preproc/Anat/${patientname}_acpc/${patientname}_SegmentationPosteriors2.nii.gz PROJECT_PATH/Preproc/ProbTissue/${patientname}_T1w_brain_CSF.nii.gz
    cp PROJECT_PATH/Preproc/Anat/${patientname}_acpc/${patientname}_SegmentationPosteriors3.nii.gz PROJECT_PATH/Preproc/ProbTissue/${patientname}_T1w_brain_GM.nii.gz
    cp PROJECT_PATH/Preproc/Anat/${patientname}_acpc/${patientname}_SegmentationPosteriors4.nii.gz PROJECT_PATH/Preproc/ProbTissue/${patientname}_T1w_brain_WM.nii.gz



fi


