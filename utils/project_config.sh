#!/bin/bash


#################################################################################
##                    DATA AND CODE REESTRUCTURE SCRIPT                        ##
## Description:                                                                ##
## This code is for creating the folder structure and to copying the original  ##
## subject images in the new folders following the BIDS basis                  ##
#################################################################################

Usage() {
    echo ""
    echo "Usage: project_config <project_path> <data_folder> <name_anat_dir>"
    echo ""
    echo "project_path: path in where data for the project is placed"
	echo "data_folder: folder in where the .nii.gz images are (without BIDS structure)"
    echo "It's needed that all the subject folders are under the same root (including patients and controls)"
	echo "name_anat_dir: name of the folder which contains T1 image under the subject root"
	echo "the format of the T1 has to be <.nii.gz>"
	exit 1
}

[ "$1" = "" ] && Usage

#Repo's folder

project_path=$1
data_folder=$2
name_anat=$3


cd ${project_path}

ls -l ${data_folder} | grep '^d' | awk '{ print $9 }' > patient_list.txt

mkdir -p DATA/RAW


count=1

for i in $(cat ${project_path}/patient_list.txt)
do

	cd ${project_path}/DATA/RAW
	
	subject_code=sub-$(printf "%03d" $count)
	mkdir -p ${subject_code}
	cd ${subject_code}
	#In this .tsv file you can trace the original subject code and the new BIDS one
	echo "${subject_code}	${i}" >> ${project_path}/DATA/participants.tsv

	if [ -d "${project_path}/${data_folder}/${i}/${name_anat}" ]; then
		mkdir -p anat
		cp ${project_path}/${data_folder}/${i}/${name_anat}/*.nii.gz ${project_path}/DATA/RAW/${subject_code}/anat/${subject_code}_T1w.nii.gz
	else
	    echo "Anatomical acquisition does not found for the subject ${i}"
	fi
	
	count=$[$count +1]
done
