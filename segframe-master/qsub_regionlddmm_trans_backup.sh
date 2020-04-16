#!/bin/bash
#$ -cwd

region=$1
kernelsize=$2
weight=$3

Sub=$4
Outdir=$5
hm=$6
segframepath=$7
matlabpath=$8
#Sub=P00000001
#Outdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/Workspace_${Sub}

mkdir "${segframepath}/logfile_${Sub}" 2> /dev/null
${matlabpath} -nodesktop -nodisplay -nojvm -r "run ${segframepath}/startup.m;regionLDDMM_trans('${Outdir}',${region},${kernelsize},${weight},'${hm}');quit;" >& ${segframepath}/'logfile_'${Sub}'/qsub_region'${region}'_logfile'${kernelsize}'_w'${weight}'_trans.txt'

#-N matlabtopup
