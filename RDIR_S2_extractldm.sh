#!/bin/bash
#$ -cwd

Sub=$1
Outdir=$2
Subdir=$3
Scriptdir=$4
clusteruser=$5
matlabpath=$6
shopt -s expand_aliases

cmd1=`qsub -V -b n -cwd ${Scriptdir}/RDIR_LM_landmarkextraction_ds.sh ${Sub} ${Outdir} ${Subdir} ${Scriptdir} ${matlabpath}`
cmd2=`qsub -V -b n -cwd ${Scriptdir}/RDIR_LM_landmarkextraction_ds_rh.sh ${Sub} ${Outdir} ${Subdir} ${Scriptdir} ${matlabpath}`

me=${clusteruser}
alias myqstat='qstat | grep $me'
#myqstat
idldm=`echo $cmd1 | awk -F' ' '{print $3}'` # get the jobid
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


echo 'Landmarks extraction Finished'
