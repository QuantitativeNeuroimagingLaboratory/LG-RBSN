#!/bin/bash

Sub=$1
projdir=$2

#Sub=P00005982
#projdir=/share/projects/razlighi_lab/users/hengda/RDIR_v2

# lh
for i in {1..3} {5..35}
do
name=$(printf "%03d\n" $i)
echo "Submitting Region-1"${name}

qsub -V -b n -cwd -N P${Sub##*0000}l${name} qsub_applylddmmtoregionsavedisp.sh ${Sub} 1${name} ${projdir}
#sleep 1m

done

# rh
for i in {1..3} {5..35}
do
name=$(printf "%03d\n" $i)
echo "Submitting Region-2"${name}

qsub -V -b n -cwd -N P${Sub##*0000}r${name} qsub_applylddmmtoregionsavedisp.sh ${Sub} 2${name} ${projdir}
#sleep 1m

done
