#!/bin/bash
#$ -cwd

Sub=$1
Outdir=$2
Subdir=$3
Scriptdir=$4
matlabpath=$5
#Sub=P00000001
#Outdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/Workspace_${Sub}
#Subdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects_FS
#/usr/local/MATLAB/R2013b/bin/matlab

mkdir log 2>/dev/null
${matlabpath} -nodesktop -nodisplay -nojvm -r "addpath('${Scriptdir}');Bridge_vertices_correspondence_downsample('${Sub}','${Subdir}');quit;" >& 'log/qsub_dslandmarkbridge_'${Sub}'.txt'

#wc -l ${Subdir}/FreeSurfer_${Sub}/FinalVertices/aparc-lh-0*_CorrespondanceMap2MNI_ds.label 

${matlabpath} -nodesktop -nodisplay -nojvm -r "addpath('${Scriptdir}');Landmark_getRASlm_ds('${Sub}','${Subdir}','${Outdir}');quit;" >& 'log/qsub_dslandmarkextraction_'${Sub}'.txt'


