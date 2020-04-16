#!/bin/bash
# 
# Region based spatial normalization 
# Hengda He
# 

Sub=$1
Outdir=$2
Subdir=$3
i=$4 # region number

#Sub=P00000001
#Outdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/Workspace_${Sub}
#Subdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects_FS
SUBJECTS_DIR=${Subdir}

name=$(printf "%03d\n" $i)
echo "Segmenting Region-"${name}

mkdir ${Outdir}/region1${name}/
mkdir ${Outdir}/region2${name}/

fslmaths ${Subdir}/FreeSurferMNI152/mri/aparc+aseg.nii.gz -thr 1$name -uthr 1$name ${Outdir}/region1${name}/aparc+aseg_1${name}_MNI.nii.gz
fslmaths ${Subdir}/FreeSurferMNI152/mri/aparc+aseg.nii.gz -thr 2$name -uthr 2$name ${Outdir}/region2${name}/aparc+aseg_2${name}_MNI.nii.gz

mris_label2annot --s FreeSurfer_${Sub} --ctab /usr/local/freesurfer/FreeSurferColorLUT.txt --h lh --l ${Subdir}/FreeSurfer_${Sub}/Vertices_forseg/aparc-lh-${name}_5thCol_Reg2MNI.label --annot-path ${Subdir}/FreeSurfer_${Sub}/label/lh.label${name}

mris_label2annot --s FreeSurfer_${Sub} --ctab /usr/local/freesurfer/FreeSurferColorLUT.txt --h rh --l ${Subdir}/FreeSurfer_${Sub}/Vertices_forseg/aparc-rh-${name}_5thCol_Reg2MNI.label --annot-path ${Subdir}/FreeSurfer_${Sub}/label/rh.label${name}

mri_aparc2aseg --s FreeSurfer_${Sub} --new-ribbon --annot label${name}
mri_convert ${Subdir}/FreeSurfer_${Sub}/mri/label${name}+aseg.mgz ${Subdir}/FreeSurfer_${Sub}/mri/label${name}+aseg.nii.gz

fslmaths ${Subdir}/FreeSurfer_${Sub}/mri/label${name}+aseg.nii.gz -thr 1001 -uthr 1001 -bin -mul $(($i+1000)) ${Outdir}/region1${name}/aparc+aseg_1${name}.nii
fslmaths ${Subdir}/FreeSurfer_${Sub}/mri/label${name}+aseg.nii.gz -thr 2001 -uthr 2001 -bin -mul $(($i+2000)) ${Outdir}/region2${name}/aparc+aseg_2${name}.nii

#gzip -d ${Outdir}/region1${name}/aparc+aseg_1*.nii.gz 
#gzip -d ${Outdir}/region2${name}/aparc+aseg_2*.nii.gz 

