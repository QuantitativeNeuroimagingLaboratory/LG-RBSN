#!/bin/bash
################################################################################
# Hengda He RDIR_version 2   Date: Sep 6 2019
################################################################################
ReD='\033[91m'
YelloW='\033[93m'
EndC='\033[0m'

echo -e "${YelloW} RDIR Version 2 - Hengda He ${EndC}" 

# Input
Sub=$1
Datadir=$2
Scriptdir=$3
Subdir=$4
projdir=$5
SUBJECTS_DIR=$6
clusteruser=$7
segframepath=$8
matlabpath=$9

# Input Example
# Sub=P00004246
# Datadir=/share/projects/razlighi_lab/studies/NativeSpace/Subjects
# Scriptdir=/share/projects/razlighi_lab/users/hengda/RDIR_v2/Script/functions
# Subdir=/share/projects/razlighi_lab/users/hengda/RDIR_v2/subjects_FS
# projdir=/share/projects/razlighi_lab/users/hengda/RDIR_v2
# SUBJECTS_DIR=/share/projects/razlighi_lab/users/hengda/RDIR_v2/subjects_FS
# clusteruser=hh2699
# segframepath=share/projects/razlighi_lab/users/hengda/RDIR_v2/segframe-master
# matlabpath=

Outdir=${projdir}/Workspace_${Sub}

#1# generate sub FS dir/corresponding ldm/region seg
echo -e "${YelloW} generate sub FS dir/corresponding ldm/region seg ${EndC}" 
bash RDIR_S1_segldm.sh ${Sub} ${Outdir} ${Subdir} ${Scriptdir} ${Datadir} ${clusteruser}

#2# Landmarks extraction
echo -e "${YelloW} Landmarks extraction ${EndC}" 
bash RDIR_S2_extractldm.sh ${Sub} ${Outdir} ${Subdir} ${Scriptdir} ${clusteruser} ${matlabpath}
mkdir ${projdir}/Subject/${Sub}
#print out number of landmarks for each region (if needed)
#wc -l ${Outdir}/region1*/brain-lh-0*-MNI-VOX-ds.label > ${projdir}/Subject/${Sub}/lh_ldm_num.txt
#wc -l ${Outdir}/region2*/brain-rh-0*-MNI-VOX-ds.label > ${projdir}/Subject/${Sub}/rh_ldm_num.txt

#3# Global init affine reg/trans landmarks
echo -e "${YelloW} Global init affine reg/trans landmarks ${EndC}" 
bash RDIR_S3_globalinit.sh ${Sub} ${Subdir} ${projdir} ${Outdir} ${Scriptdir} ${clusteruser} ${matlabpath} ${segframepath}

#4# Local translation volume and landmarks
echo -e "${YelloW} Local translation volume and landmarks ${EndC}" 
bash RDIR_S4_localinit.sh ${Sub} ${Outdir} ${Scriptdir} ${clusteruser} ${matlabpath} ${segframepath}

#5# Local non-linear registration
echo -e "${YelloW} Local non-linear registration ${EndC}" 
bash RDIR_S5_localregistration.sh ${Sub} ${Outdir} ${segframepath} ${clusteruser} ${matlabpath}

#6# Generating local non-linear registration warping field
echo -e "${YelloW} Generating local non-linear registration warping field${EndC}" 
bash RDIR_S6_localwarpingfield.sh ${Sub} ${projdir} ${segframepath} ${clusteruser} ${matlabpath}

#7# IDW interpolation
echo -e "${YelloW} Inverse distance weighted interpolation of local non-liear warping fields${EndC}"
bash RDIR_S7_IDW.sh ${Sub} ${projdir} ${matlabpath} ${Scriptdir} ${clusteruser}

#8# Bijective constrain and Demons registration
echo -e "${YelloW} Residual compensation for bijective constrain and Demons registration${EndC}"
bash RDIR_S8_Demons.sh ${Sub} ${projdir} ${matlabpath} ${Scriptdir}

echo 'Finished'



