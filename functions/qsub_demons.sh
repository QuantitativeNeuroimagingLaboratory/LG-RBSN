#!/bin/bash
#$ -cwd

projectdir=$1
codedir=$2
Sub=$3
matlabpath=$4

mkdir "log" 2> /dev/null
${matlabpath} -nodesktop -r "addpath('${codedir}');Demons_regularization('${Sub}','${projectdir}');quit;" >& 'log/Demons_'${Sub}'_logfile.txt'

