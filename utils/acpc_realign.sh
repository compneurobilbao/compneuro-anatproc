#!/bin/bash

input=$1
output=$2
template=$3

if [ "$#" -eq 0 ]; then
    echo 'USAGE: acpc_realign <INPUT_IMAGE> <OUTPUT_IMAGE_PATH> <PATH_TO_TEMPLATE_IMAGE>' >&2
    exit 1
fi

fslreorient2std $input reoriented_img -copysform2qform
robustfov -i reoriented_img -m roi2full.mat -r input_robustfov.nii.gz
convert_xfm -omat full2roi.mat -inverse roi2full.mat
flirt -interp spline -in input_robustfov.nii.gz -ref $template -omat roi2std.mat -out acpc_mni.nii.gz
convert_xfm -omat full2std.mat -concat roi2std.mat full2roi.mat
aff2rigid full2std.mat outputmatrix
applywarp --rel --interp=spline -i reoriented_img -r $template --premat=outputmatrix -o $output
