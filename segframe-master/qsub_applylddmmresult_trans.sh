#!/bin/bash
#$ -cwd

region=$1
kernelsize=$2
weight=$3
Sub=$4
Outdir=$5

#Sub=P00000001
#Outdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/Workspace_${Sub}

mkdir "logfile_${Sub}" 2> /dev/null
/usr/local/MATLAB/R2017b/bin/matlab -nodesktop -r "run startup.m;Apply2region_nodisplay_trans('${Outdir}',${region},${kernelsize},${weight});quit;" >& 'logfile_'${Sub}'/qsub_region'${region}'_result'${kernelsize}'_w'${weight}'_trans.txt'
