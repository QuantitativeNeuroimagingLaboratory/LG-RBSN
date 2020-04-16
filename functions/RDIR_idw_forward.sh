#!/bin/bash
#$ -cwd

Sub=$1
projdir=$2
Scriptdir=$3
matlabpath=$4

mkdir log 2>/dev/null
${matlabpath} -nodesktop -nodisplay -r "addpath('${Scriptdir}');catfields_v3_2_idw_brain('${projdir}','${Sub}');quit;" >& 'log/qsub_idw_forward_'${Sub}'.txt'



