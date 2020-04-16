Landmark Guided Region Based Spatial Normalization 
By Hengda He and Ray Razlighi 
April 11 2020 

1. Directory Setup:

Example:
# Sub=P00005982
# Datadir=/share/projects/razlighi_lab/studies/NativeSpace/Subjects
# Scriptdir=/share/projects/razlighi_lab/users/hengda/LG-RBSN/functions
# Subdir=/share/projects/razlighi_lab/users/hengda/LG-RBSN/subjects_FS
# projdir=/share/projects/razlighi_lab/users/hengda/LG-RBSN
# SUBJECTS_DIR=/share/projects/razlighi_lab/users/hengda/LG-RBSN/subjects_FS
# clusteruser=hh2699
# segframepath=/share/projects/razlighi_lab/users/hengda/LG-RBSN/segframe-master
# matlabpath=/usr/local/MATLAB/R2017b/bin/matlab

2. How to run:

bash regionbasedspatialnormalization.sh ${Sub} ${Datadir} ${Scriptdir} ${Subdir} ${projdir} ${SUBJECTS_DIR} ${clusteruser} ${segframepath} ${matlabpath}

Example:
bash regionbasedspatialnormalization.sh P00005982 /share/projects/razlighi_lab/studies/NativeSpace/Subjects /share/projects/razlighi_lab/users/hengda/LG-RBSN/functions /share/projects/razlighi_lab/users/hengda/LG-RBSN/subjects_FS /share/projects/razlighi_lab/users/hengda/LG-RBSN /share/projects/razlighi_lab/users/hengda/LG-RBSN/subjects_FS hh2699 /share/projects/razlighi_lab/users/hengda/LG-RBSN/segframe-master /usr/local/MATLAB/R2017b/bin/matlab



