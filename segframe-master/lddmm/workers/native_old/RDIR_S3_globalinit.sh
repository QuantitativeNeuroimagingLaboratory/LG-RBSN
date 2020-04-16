#!/bin/bash
# 
# Region based spatial normalization 
# Hengda He
# Usage: initial global alignment of brain image

#SUBJECTS=(P00004955 P00004967 P00004396 P00004368 P00004371 P00004359 P00004414 P00004407 P00004445 P00004961)
#SUBJECTS=(P00005982 P00005939 P00005942 P00005966 P00005980 P00005947 P00005926 P00005941 P00005916 P00005910 P00004955 P00004967 P00004396 P00004368 P00004371 P00004359 P00004414 P00004407 P00004445 P00004961)

#SUBJECTS=(P00005982)
#subdir="/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects_FS"
#projdir="/share/projects/razlighi_lab/users/hengda/RDIR_LM/GlobalInitial"
#RDIRdir="/share/projects/razlighi_lab/users/hengda/RDIR_LM"
#SUBJECTS_DIR="/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects_FS"

SUBJECTS=$1
subdir=$2
projdir=$3
Outdir=$4
Scriptdir=$5

SUBJECTS_DIR=$subdir

#cp /usr/local/fsl/5.0/data/standard/MNI152_T1_1mm_brain.nii.gz ${projdir}/

for SUB in ${SUBJECTS[*]}; 
do

echo ${SUB}
mkdir ${projdir}/Subject
mkdir ${projdir}/Subject/${SUB}

dataindir=${subdir}/FreeSurfer_${SUB}/mri
subprojdir=${projdir}/Subject/${SUB}

#echo 'Generating a dilated brain mask using the aparc+aseg file in the directory and the multiplying to existing nu.nii file to extract the brain'
#mri_convert ${dataindir}/aparc+aseg.mgz ${dataindir}/aparc+aseg.nii.gz
#mri_convert ${dataindir}/nu.mgz ${dataindir}/nu.nii.gz
#fslmaths ${dataindir}/aparc+aseg.nii.gz -bin -dilM -mul ${dataindir}/nu.nii.gz ${subprojdir}/brain.nii.gz

echo 'Freesurfer brain extraction'
# ANTS initial alignment works better than flirt on Freesurfer segmented brain
mri_convert ${dataindir}/brain.mgz ${subprojdir}/brain.nii.gz
#cp ${subjectdir}/T1_${SUB}_S0001_brain.nii.gz ${subprojdir}/brain.nii.gz

echo 'flirt initial global brain image alignment'
#flirt -ref ${projdir}/MNI152_T1_1mm_brain.nii.gz -in ${subprojdir}/brain.nii.gz -out ${subprojdir}/brain2MNI_affine_rayseg_flirt.nii.gz -omat ${subprojdir}/brain2MNI_affine.mat
#flirt -in ${subprojdir}/brain.nii.gz -ref ${projdir}/MNI152_T1_1mm_brain.nii.gz -out ${subprojdir}/brain2MNI_affine.nii.gz -omat ${subprojdir}/brain2MNI_affine.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear
flirt -in ${subprojdir}/brain.nii.gz -ref ${SUBJECTS_DIR}/FreeSurferMNI152/mri/brain.nii.gz -out ${subprojdir}/brain2MNI_affine.nii.gz -omat ${subprojdir}/brain2MNI_affine.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear

############ apply affine to regions
echo 'apply affine to regions'
qsub -V -b n -cwd ${Scriptdir}/applyaffine.sh ${SUB} ${Outdir} ${subdir} ${subprojdir}


### apply affine to landmarks
echo 'apply affine to landmarks'
qsub -V -b n -cwd ${Scriptdir}/RDIR_LM_affientransldm.sh ${SUB} ${Outdir} ${subdir} ${Scriptdir} ${subprojdir}


done

