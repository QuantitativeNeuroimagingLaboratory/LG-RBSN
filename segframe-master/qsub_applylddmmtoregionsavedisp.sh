#!/bin/bash
#$ -cwd

Sub=$1
region=$2
projectdir=$3
segframepath=$4
matlabpath=$5

mkdir "${segframepath}/logoffinalapply/logfile_${Sub}" 2> /dev/null
${matlabpath} -nodesktop -r "cd ${segframepath};run ${segframepath}/startup.m;Apply2region_savedisp('${Sub}',${region},'${projectdir}');quit;" >& ${segframepath}/'logoffinalapply/logfile_'${Sub}'/qsub_region'${region}'_result.txt'
