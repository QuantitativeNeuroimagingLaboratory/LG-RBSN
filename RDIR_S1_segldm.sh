#!/bin/bash
# 
# Region based spatial normalization 
# Hengda He
# Usage: bash RDIR_LM.sh SubectID Outdir Subdir Scriptdir Datadir
# Example: bash RDIR_LM.sh P00000001

Sub=$1
Outdir=$2
Subdir=$3
Scriptdir=$4
Datadir=$5
clusteruser=$6

shopt -s expand_aliases
# Example
#Sub=P00000001
#Outdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/Workspace_${Sub}
#Subdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects_FS
#Scriptdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/Script 
#Datadir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects
SUBJECTS_DIR=${Subdir}

################## Code start

################## generating new segmentation 
# copy necessary FS directory from data folder (copy FS data from $3 to $1 with Freesurfer_$2)
bash ${Scriptdir}/makesubfsdir.sh ${Subdir} ${Sub} ${Datadir}/${Sub}/S0001/T1/FreeSurfer

# corresponding landmarks
stdoutldm=`qsub -V -b n -cwd ${Scriptdir}/TransferFreesurferVerticesToMNI_hengda_morepoints.py ${Subdir} FreeSurferMNI152 FreeSurfer_${Sub} ${Subdir}/FreeSurfer_${Sub}/Vertices 
mkdir ${Outdir}`

###### segmentation
bash ${Scriptdir}/jobhold.sh qsub -V -b n -cwd ${Scriptdir}/TransferFreesurferVerticesToMNI_hengda_morepoints_revmap.py ${Subdir} FreeSurferMNI152 FreeSurfer_${Sub} ${Subdir}/FreeSurfer_${Sub}/Vertices_forseg 

# para version
for i in {1..3} {5..35}
do
name=$(printf "%03d\n" $i)
echo "Segmenting Region-1"${name}
qsub -V -b n -cwd ${Scriptdir}/MNIregionimagefrommanualedit_onereg.sh ${Sub} ${Outdir} ${Subdir} ${i}
done

me=${clusteruser}
alias myqstat='qstat | grep $me'
idldm=`echo $stdoutldm | awk -F' ' '{print $3}'` # get the jobid
statusldm=`myqstat | grep $idldm` # check to see if job is running
echo $statusldm

while [ -n "$statusldm" ] # while $status is not empty
	do
		sleep 30
		statusldm=`myqstat | grep $idldm`
	done

echo 'Segmentation and Landmark Correspondence Finished'












