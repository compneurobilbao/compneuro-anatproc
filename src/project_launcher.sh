#!/bin/bash

###########################################################
#                                                         #
#		  Anat Preprocessing Bash launcher                #
#                                                         #
###########################################################

source activate ICAaroma

while read line
do
    participant=$( echo ${line} | awk '{ print $1 }')

	if [  -f "Preproc/BET/${participant}_T1w_brain.nii.gz" ]; then
        echo "$participant already processed"
    else
        echo "*********************"
        echo "$participant"
        echo "*********************"
 
        source /app/src/anatPreproc.sh $participant

   fi
	
done < /project/data/participants.tsv





