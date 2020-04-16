#!/bin/bash
# 
# Region based spatial normalization 
# Hengda He
# 

Sub=$1
Outdir=$2
SUBJECTS_DIR=$3
subprojdir=$4

#Sub=P00005982
#Outdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/GlobalInitial/Workspace_${Sub}
#Subdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/GlobalInitial/Subject
#SUBJECTS_DIR=/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects_FS


for i in {1..3} {5..35}
do
name=$(printf "%03d\n" $i)
echo "Global Affine Region-1"${name}

flirt -ref ${Outdir}/region1${name}/aparc+aseg_1${name}_MNI.nii -in ${Outdir}/region1${name}/aparc+aseg_1${name}.nii -applyxfm -init ${subprojdir}/brain2MNI_affine.mat -out ${Outdir}/region1${name}/aparc+aseg_1${name}_Gaffine.nii -interp nearestneighbour

done

#rh
for i in {1..3} {5..35}
do
name=$(printf "%03d\n" $i)
echo "Global Affine Region-2"${name}

flirt -ref ${Outdir}/region2${name}/aparc+aseg_2${name}_MNI.nii -in ${Outdir}/region2${name}/aparc+aseg_2${name}.nii -applyxfm -init ${subprojdir}/brain2MNI_affine.mat -out ${Outdir}/region2${name}/aparc+aseg_2${name}_Gaffine.nii -interp nearestneighbour

done

mri_convert ${SUBJECTS_DIR}/FreeSurfer_${Sub}/mri/aparc+aseg.mgz ${SUBJECTS_DIR}/FreeSurfer_${Sub}/mri/aparc+aseg.nii.gz
flirt -ref ${SUBJECTS_DIR}/FreeSurferMNI152/mri/aparc+aseg.nii.gz -in ${SUBJECTS_DIR}/FreeSurfer_${Sub}/mri/aparc+aseg.nii.gz -applyxfm -init ${subprojdir}/brain2MNI_affine.mat -out ${subprojdir}/aparc+aseg_Gaffine.nii.gz -interp nearestneighbour


