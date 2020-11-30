#!/bin/bash

###########################################################
#                                                         #
#		  VBM launcher                                    #
#                                                         #
###########################################################
#

#SBATCH -n 1 # Number of cores
#SBATCH -p medium # Partition
#SBATCH --mem 12000 # Memory request
#SBATCH -o LOG/anat/vbm.out # Standard output
#SBATCH -e LOG/anat/vbm.err # Standard error

ml load FSL

export FSLOUTPUTTYPE=NIFTI_GZ

project_root=PROJECT_PATH
cd ${project_root}

mkdir -p VBM
mkdir -p VBM/struc
mkdir -p VBM/stats

Text2Vest ${project_root}/DATA/design.txt ${project_root}/VBM/stats/design.mat
Text2Vest ${project_root}/DATA/contrast.txt ${project_root}/VBM/stats/design.con
cd VBM

for i in $(ls -l ${project_root}/DATA/RAW | awk '{ print $9 }' | tail -n +2)
do
	echo "${i}.nii.gz" >> template_list
	cp ${project_root}/Preproc/Anat/${i}.anat/T1_biascorr.nii.gz ${project_root}/VBM/${i}.nii.gz
	cp ${project_root}/Preproc/Anat/${i}.anat/T1_biascorr.nii.gz ${project_root}/VBM/struc/${i}_struc.nii.gz
	cp ${project_root}/Preproc/Anat/${i}.anat/T1_biascorr.nii.gz ${project_root}/VBM/struc/${i}_cut.nii.gz
	cp ${project_root}/Preproc/Anat/${i}.anat/T1_biascorr_brain.nii.gz ${project_root}/VBM/struc/${i}_struc_brain.nii.gz
done

fslvbm_2_template -n
fslvbm_3_proc

cd stats
randomise -i GM_mod_merg_s4 -m GM_mask -o fslvbm_randomise -d design.mat -t design.con -T -n 5000

