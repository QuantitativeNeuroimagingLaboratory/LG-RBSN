#!/bin/bash
# 
# Region based spatial normalization 
# Step 3: Global init affine reg/trans landmarks
# Hengda He
# Usage: initial global alignment of brain image

#SUBJECTS=(P00005982)
#subdir="/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects_FS"
#projdir="/share/projects/razlighi_lab/users/hengda/RDIR_LM/GlobalInitial"
#RDIRdir="/share/projects/razlighi_lab/users/hengda/RDIR_LM"
#SUBJECTS_DIR="/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects_FS"

SUB=$1
subdir=$2
projdir=$3
Outdir=$4
Scriptdir=$5
clusteruser=$6
matlabpath=$7
segframepath=$8
shopt -s expand_aliases

SUBJECTS_DIR=$subdir

echo ${SUB}
mkdir ${projdir}/Subject
mkdir ${projdir}/Subject/${SUB}

dataindir=${subdir}/FreeSurfer_${SUB}/mri
subprojdir=${projdir}/Subject/${SUB}

echo 'Freesurfer brain extraction'
mri_convert ${dataindir}/brain.mgz ${subprojdir}/brain.nii.gz

echo 'flirt initial global brain image alignment'
flirt -in ${subprojdir}/brain.nii.gz -ref ${SUBJECTS_DIR}/FreeSurferMNI152/mri/brain.nii.gz -out ${subprojdir}/brain2MNI_affine.nii.gz -omat ${subprojdir}/brain2MNI_affine.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear

############ apply affine to regions
echo 'apply affine to regions'
cmd=`qsub -V -b n -cwd ${Scriptdir}/applyaffine.sh ${SUB} ${Outdir} ${subdir} ${subprojdir}`


### apply affine to landmarks
echo 'apply affine to landmarks'
cmd2=`qsub -V -b n -cwd ${Scriptdir}/RDIR_LM_affientransldm.sh ${SUB} ${Outdir} ${subdir} ${Scriptdir} ${subprojdir} ${matlabpath} ${segframepath}`

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


