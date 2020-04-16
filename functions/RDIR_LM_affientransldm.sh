#!/bin/bash
#$ -cwd

Sub=$1
Outdir=$2
Subdir=$3
Scriptdir=$4
subprojdir=$5
matlabpath=$6
segframepath=$7

mkdir log 2>/dev/null
${matlabpath} -nodesktop -nodisplay -nojvm -r "addpath('${Scriptdir}');affientransldm('${Sub}','${Outdir}','${Subdir}','${segframepath}','${subprojdir}');quit;" >& 'log/qsub_affinetransldm_'${Sub}'.txt'



