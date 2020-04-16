#!/bin/bash
# 
# Region based spatial normalization 
# Step 6: Generating local warping field
# Hengda He

Sub=$1
projdir=$2
segframepath=$3
clusteruser=$4
matlabpath=$5
shopt -s expand_aliases

#Sub=P00005982
#projdir=/share/projects/razlighi_lab/users/hengda/RDIR_v2
# clusteruser=hh2699
# segframepath=share/projects/razlighi_lab/users/hengda/RDIR_v2/segframe-master

mkdir "${segframepath}/logoffinalapply"

# lh
for i in {1..3} {5..35}
do
name=$(printf "%03d\n" $i)
echo "Submitting Region-1"${name}

cmd[$i]=`qsub -V -b n -cwd -N P${Sub##*0000}l${name} ${segframepath}/qsub_applylddmmtoregionsavedisp.sh ${Sub} 1${name} ${projdir} ${segframepath} ${matlabpath}`
#sleep 1m

done

# rh
for i in {1..3} {5..35}
do
name=$(printf "%03d\n" $i)
echo "Submitting Region-2"${name}

cmd2[$i]=`qsub -V -b n -cwd -N P${Sub##*0000}r${name} ${segframepath}/qsub_applylddmmtoregionsavedisp.sh ${Sub} 2${name} ${projdir} ${segframepath} ${matlabpath}`
#sleep 1m

done


me=${clusteruser}
alias myqstat='qstat | grep $me'

for i in {1..3} {5..35}
do

	idldm=`echo ${cmd[$i]} | awk -F' ' '{print $3}'` # get the jobid
	statusldm=`myqstat | grep $idldm` # check to see if job is running
	echo $statusldm

	idldm2=`echo ${cmd2[$i]} | awk -F' ' '{print $3}'` # get the jobid
	statusldm2=`myqstat | grep $idldm2` # check to see if job is running
	echo $statusldm2

	while [ -n "$statusldm" ] || [ -n "$statusldm2" ] # while $status is not empty
		do
			sleep 3m
			#echo "notfinish"
			statusldm=`myqstat | grep $idldm`
			statusldm2=`myqstat | grep $idldm2`
		done

done
