#!/bin/bash
# # Hengda He
# make subject freesurfer directory

Subdir=$1
Sub=$2
DataFSdir=$3

#Subdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects_FS
#Sub=P00000001
#DataFSdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects/${Sub}/S0001/T1/FreeSurfer

mkdir ${Subdir}/FreeSurfer_${Sub}; mkdir ${Subdir}/FreeSurfer_${Sub}/mri;  mkdir ${Subdir}/FreeSurfer_${Sub}/label; mkdir ${Subdir}/FreeSurfer_${Sub}/surf;  
#mkdir ${Subdir}/FreeSurfer_${Sub}/Vertices;  

cp ${DataFSdir}/mri/aseg.mgz ${Subdir}/FreeSurfer_${Sub}/mri/; 

cp ${DataFSdir}/mri/nu.mgz ${Subdir}/FreeSurfer_${Sub}/mri/; 

cp ${DataFSdir}/mri/brain.mgz ${Subdir}/FreeSurfer_${Sub}/mri/; 

cp ${DataFSdir}/mri/aparc+aseg.mgz ${Subdir}/FreeSurfer_${Sub}/mri/; 

cp ${DataFSdir}/mri/ribbon.mgz ${Subdir}/FreeSurfer_${Sub}/mri/; 

cp ${DataFSdir}/surf/*h.white ${Subdir}/FreeSurfer_${Sub}/surf/; 

cp ${DataFSdir}/surf/*h.orig ${Subdir}/FreeSurfer_${Sub}/surf/; 

cp ${DataFSdir}/surf/*h.pial ${Subdir}/FreeSurfer_${Sub}/surf/; 

cp ${DataFSdir}/surf/*h.sphere.reg ${Subdir}/FreeSurfer_${Sub}/surf/; 

