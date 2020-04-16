#!/bin/bash
#$ -cwd
#4# Local translation volume and landmarks

Sub=$1
Outdir=$2
Scriptdir=$3
clusteruser=$4
matlabpath=$5
segframepath=$6
shopt -s expand_aliases

cmd=`qsub -V -b n -cwd ${Scriptdir}/RDIR_LM_transinitalign.sh ${Sub} ${Outdir} ${Scriptdir} ${matlabpath} ${segframepath}`
cmd2=`qsub -V -b n -cwd ${Scriptdir}/RDIR_LM_transinitalign_rh.sh ${Sub} ${Outdir} ${Scriptdir} ${matlabpath} ${segframepath}`

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

echo 'Landmarks extraction Finished'
