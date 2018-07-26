echo "Start"
#!/bin/bash


COUNTER=1
for filename in ./S*.nii

do

echo $filename
	#renzo way - make duplicates
	3dTcat -prefix r$COUNTER.Basis.nii $filename'[4..7]' $filename'[4..$]' -overwrite
	3dTcat -prefix r$COUNTER.Basis_a.nii r$COUNTER.Basis.nii'[0..$(2)]'  -overwrite
	3dTcat -prefix r$COUNTER.Basis_b.nii r$COUNTER.Basis.nii'[1..$(2)]'  -overwrite
	3dinfo -nt r$COUNTER.Basis_a.nii >> NT.txt
	3dinfo -nt r$COUNTER.Basis_b.nii >> NT.txt
	
	#or just remove the first 4 TRS
	#3dTcat -prefix r$COUNTER.Basis_a.nii  $filename'[4..$]' -overwrite

	#cp r$COUNTER.Basis_a.nii r$COUNTER.Basis_b.nii
	COUNTER=$[$COUNTER +1]
     


#mv $filename ./Basis_b.nii

done


/usr/local/MATLAB/R2017b/bin/matlab -nodesktop -nosplash -r "mocobatch_VASO2"

#complieMotions
rm comp.motion*
cat rp_r*.Basis_a.txt >> comp.motion_a.txt
cat rp_r*.Basis_b.txt >> comp.motion_b.txt

cp /media/insub/ururru/layers/scripts/repository/motion/gnuplot_moco.txt .
gnuplot "/media/insub/ururru/layers/scripts/repository/motion/gnuplot_moco.txt"

#rm splited*
#echo "hole SPM motion batch"
#cp /media/insub/ururru/layers/scripts/repository/motion/mocobatch100_VASO.m ./mocobatch100_VASO.m
#/usr/local/MATLAB/R2017b/bin/matlab -nodesktop -nosplash -r "mocobatch100_VASO"

#gnuplot "/media/insub/ururru/layers/scripts/repository/motion/gnuplot_moco.txt"

echo "Done"
