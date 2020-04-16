#!/bin/bash
# 
# Region based spatial normalization 
# Step 7: inverse distance weighted interpolation (IDW)
# Hengda He

Sub=$1
projdir=$2
matlabpath=$3
Scriptdir=$4
clusteruser=$5
shopt -s expand_aliases

echo $Sub
echo $projdir
echo $matlabpath
echo $Scriptdir
echo $clusteruser

## apply to forward
echo 'forward IDW'
cmd=`qsub -V -b n -cwd ${Scriptdir}/RDIR_idw_forward.sh ${Sub} ${projdir} ${Scriptdir} ${matlabpath}`

## apply to backward
echo 'backward IDW'
cmd2=`qsub -V -b n -cwd ${Scriptdir}/RDIR_idw_backward.sh ${Sub} ${projdir} ${Scriptdir} ${matlabpath}`

me=${clusteruser}
alias myqstat='qstat | grep $me'
idldm=`echo $cmd | awk -F' ' '{print $3}'` # get the jobid
statusldm=`myqstat | grep $idldm` # check to see if job is running
echo $statusldm

idldm2=`echo $cmd2 | awk -F' ' '{print $3}'` # get the jobid
statusldm2=`myqstat | grep $idldm2` # check to see if job is running
echo $statusldm2

while [ -n "$statusldm" ] || [ -n "$statusldm2" ] # while $status is not empty
	do
		sleep 30
		#echo "notfinish"
		statusldm=`myqstat | grep $idldm`
		statusldm2=`myqstat | grep $idldm2`
	done

echo 'IDW Finished'


