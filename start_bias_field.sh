#!/bin/bash


echo "fange an"

cp $1 uncorr.nii

echo "hole SPM motion batch"
#cp /Users/huberl/NeuroDebian/repository/bias_field_corr/Bias_field_script_job.m ./Bias_field_script_job.m
/usr/local/MATLAB/R2017b/bin/matlab -nodesktop -nosplash -r "Bias_field_script_job"
3dcalc -a muncorr.nii -prefix muncorr.nii -overwrite -expr 'a' -datum short

mv muncorr.nii bico_$1

rm mucorr.nii
rm uncorr.nii

echo "und tschuess"
