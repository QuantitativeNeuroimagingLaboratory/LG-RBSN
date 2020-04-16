#!/bin/bash
################################################################################
# Region based spatial normalization 
# Step 8: Bijective constrain and Demons registraion
# Hengda He
################################################################################

Sub=$1
projdir=$2
matlabpath=$3
Scriptdir=$4

echo $Sub
echo $projdir
echo $matlabpath
echo $Scriptdir

#8# Residual compensation and Demons registration
echo 'Residual compensation and Demons registration'
qsub -V -b n -cwd ${Scriptdir}/qsub_demons.sh ${projdir} ${Scriptdir} ${Sub} ${matlabpath}

echo 'Residual compensation and Demons registration Job Submitted'





