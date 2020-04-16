#!/bin/bash

Sub=$1
Outdir=$2

#Sub=P00005982
#Outdir=/share/projects/razlighi_lab/users/hengda/RDIR_LM/Workspace_${Sub}

# lh
for i in {1..3} {5..35}
do
name=$(printf "%03d\n" $i)
echo "Submitting Region-1"${name}

qsub -V -b n -cwd -N P${Sub##*0000}l${name} qsub_regionlddmm_trans.sh 1${name} 4 100 ${Sub} ${Outdir} lh
#sleep 1m

done

# rh
for i in {1..3} {5..35}
do
name=$(printf "%03d\n" $i)
echo "Submitting Region-2"${name}

qsub -V -b n -cwd -N P${Sub##*0000}r${name} qsub_regionlddmm_trans.sh 2${name} 4 100 ${Sub} ${Outdir} rh
#sleep 1m

done
