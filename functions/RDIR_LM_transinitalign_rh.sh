#!/bin/bash
#$ -cwd

Sub=$1
Outdir=$2
Scriptdir=$3
matlabpath=$4
segframepath=$5

#Sub=P00000001
#Outdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/Workspace_${Sub}
mkdir log 2>/dev/null
${matlabpath} -nodesktop -nodisplay -nojvm -r "addpath('${Scriptdir}');checkldm_trans_rh('${Outdir}','${segframepath}');quit;" >& 'log/qsub_transldm_rh_'${Sub}'.txt'


