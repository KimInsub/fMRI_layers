#!/bin/bash


echo "It starts now:    I expect two files Not_Nulled_Basis_a.nii and Nulled_Basis_b.nii that are motion corrected with SPM"

run=( 1 2 3 4 ) 

for t in "${run[@]}"
do
NumVol=`3dinfo -nv Nulled_r$t.Basis_b.nii`
echo $NumVol
3dTcat -prefix r$t.combined.nii -overwrite Nulled_r$t.Basis_b.nii'[3..$]' Not_Nulled_r$t.Basis_a.nii'[3..'`expr $NumVol - 1`']'
3dTstat -cvarinv -prefix r$t.T1_weighted.nii -overwrite r$t.combined.nii 
cp Nulled_r$t.Basis_b.nii Nulled.nii
cp Not_Nulled_r$t.Basis_a.nii BOLD.nii

3drefit -space ORIG -view orig -TR 3 BOLD.nii
3drefit -space ORIG -view orig -TR 3 Nulled.nii

NumVol=`3dinfo -nv BOLD.nii`
3dTcat BOLD.nii'[0..'`expr $NumVol - 2`']' -prefix BOLD.nii -overwrite

3dTstat -mean -prefix mean_nulled.nii Nulled.nii -overwrite
3dTstat -mean -prefix mean_notnulled.nii BOLD.nii -overwrite


# Then calculate the mean, stdev, & cvarinv (detrended mean/stdev) for BOLD & Nulled volumes
# I was mainly doing this as a check to make sure motion correction worked reasonably.
# A TSNR calculation should probably be done after non-linear drift removal.

# Calculate VASO!


  # The first vaso volume is first nulled volume divided by the 2nd BOLD volume
  3dcalc -prefix tmp.VASO_vol1.nii \
         -a      BOLD.nii'[1]' \
         -b      Nulled.nii'[0]' \
         -expr 'b/a' -overwrite

  # Calculate all VASO volumes after the first one
  # -a goes from the 2nd BOLD volume to the 2nd-to-last BOLD volume
  # -b goes from the 3rd BOLD volume to the last BOLD volume
  # -c goes from the 2nd Nulled volume to the last Nulled volume
  NumVol=`3dinfo -nv BOLD.nii` 
  3dcalc -prefix tmp.VASO_othervols.nii \
         -a      BOLD.nii'[0..'`expr $NumVol - 2`']' \
         -b      BOLD.nii'[1..$]' \
         -c      Nulled.nii'[1..$]' \
         -expr 'c*2/(a+b)' -overwrite

   # concatinate the first VASO volume with the rest of the sequence
   3dTcat -overwrite -prefix VASO.nii tmp.VASO_vol1.nii tmp.VASO_othervols.nii


# Remove the temporary seprate files for the first VASO volume and the rest of the VASO volumes
rm tmp.VASO_vol1*.nii tmp.VASO_othervols*.nii


# BOLD and VASO now have 3s or 312s TRs
# Use 3drefit to make this change in the file headers

 
#echo ' remove last time point in BOLD'
#NumVol=`3dinfo -nv BOLD.nii`
#echo "NumVol of BOLD is '$Numvol'  "
#3dcalc -prefix BOLD.nii \
#         -a      BOLD.nii'[1..'`expr $NumVol - 1`']' \
#         -expr 'a' -overwrite

  3dTstat  -overwrite -mean  -prefix r$t.BOLD.Mean.nii \
     BOLD.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix r$t.BOLD.tSNR.nii \
     BOLD.nii'[1..$]'
  3dTstat  -overwrite -mean  -prefix r$t.VASO.Mean.nii \
     VASO.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix r$t.VASO.tSNR.nii \
     VASO.nii'[1..$]'

done

#make complied tsnr
3dTcat -overwrite r?.BOLD.tSNR.nii r?.VASO.tSNR.nii -prefix comp.tSNR.nii
3dTstat -overwrite -mean -prefix comp.T1.nii r*.T1_weighted.nii



