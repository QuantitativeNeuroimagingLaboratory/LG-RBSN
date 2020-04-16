#--------------------------------------------
#@# Mask BFS Wed Dec 16 09:55:17 EST 2015

 mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz 

#--------------------------------------------
#@# Fill Wed Dec 16 09:55:19 EST 2015

 mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.auto_noCCseg.mgz wm.mgz filled.mgz 

#--------------------------------------------
#@# Tessellate lh Wed Dec 16 09:56:21 EST 2015

 mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz 


 mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix 


 rm -f ../mri/filled-pretess255.mgz 


 mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix 

#--------------------------------------------
#@# Smooth1 lh Wed Dec 16 09:56:30 EST 2015

 mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 lh Wed Dec 16 09:56:36 EST 2015

 mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix 

#--------------------------------------------
#@# QSphere lh Wed Dec 16 09:57:24 EST 2015

 mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix 

#--------------------------------------------
#@# Fix Topology lh Wed Dec 16 10:03:28 EST 2015

 cp ../surf/lh.orig.nofix ../surf/lh.orig 


 cp ../surf/lh.inflated.nofix ../surf/lh.inflated 


 mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 FreeSurfer lh 


 mris_euler_number ../surf/lh.orig 


 mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 


 rm ../surf/lh.inflated 

#--------------------------------------------
#@# Make White Surf lh Wed Dec 16 10:39:54 EST 2015

 mris_make_surfaces -noaparc -whiteonly -mgz -T1 brain.finalsurfs FreeSurfer lh 

#--------------------------------------------
#@# Smooth2 lh Wed Dec 16 10:46:08 EST 2015

 mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white ../surf/lh.smoothwm 

#--------------------------------------------
#@# Inflation2 lh Wed Dec 16 10:46:13 EST 2015

 mris_inflate ../surf/lh.smoothwm ../surf/lh.inflated 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/lh.inflated 


#-----------------------------------------
#@# Curvature Stats lh Wed Dec 16 10:48:38 EST 2015

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm FreeSurfer lh curv sulc 

#--------------------------------------------
#@# Sphere lh Wed Dec 16 10:48:43 EST 2015

 mris_sphere -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

#--------------------------------------------
#@# Surf Reg lh Wed Dec 16 12:01:04 EST 2015

 mris_register -curv ../surf/lh.sphere /usr/local/freesurfer/5.1/average/lh.average.curvature.filled.buckner40.tif ../surf/lh.sphere.reg 

#--------------------------------------------
#@# Jacobian white lh Wed Dec 16 12:39:15 EST 2015

 mris_jacobian ../surf/lh.white ../surf/lh.sphere.reg ../surf/lh.jacobian_white 

#--------------------------------------------
#@# AvgCurv lh Wed Dec 16 12:39:17 EST 2015

 mrisp_paint -a 5 /usr/local/freesurfer/5.1/average/lh.average.curvature.filled.buckner40.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv 

#-----------------------------------------
#@# Cortical Parc lh Wed Dec 16 12:39:19 EST 2015

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 FreeSurfer lh ../surf/lh.sphere.reg /usr/local/freesurfer/5.1/average/lh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ../label/lh.aparc.annot 

#--------------------------------------------
#@# Make Pial Surf lh Wed Dec 16 12:40:37 EST 2015

 mris_make_surfaces -white NOWRITE -mgz -T1 brain.finalsurfs FreeSurfer lh 

#--------------------------------------------
#@# Surf Volume lh Wed Dec 16 12:53:09 EST 2015

 mris_calc -o lh.area.mid lh.area add lh.area.pial 


 mris_calc -o lh.area.mid lh.area.mid div 2 


 mris_calc -o lh.volume lh.area.mid mul lh.thickness 

#-----------------------------------------
#@# Parcellation Stats lh Wed Dec 16 12:53:09 EST 2015

 mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab FreeSurfer lh white 

#-----------------------------------------
#@# Cortical Parc 2 lh Wed Dec 16 12:53:43 EST 2015

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 FreeSurfer lh ../surf/lh.sphere.reg /usr/local/freesurfer/5.1/average/lh.destrieux.simple.2009-07-29.gcs ../label/lh.aparc.a2009s.annot 

#-----------------------------------------
#@# Parcellation Stats 2 lh Wed Dec 16 12:55:09 EST 2015

 mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab FreeSurfer lh white 

#--------------------------------------------
#@# Tessellate rh Wed Dec 16 12:55:45 EST 2015

 mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz 


 mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix 


 rm -f ../mri/filled-pretess127.mgz 


 mris_extract_main_component ../surf/rh.orig.nofix ../surf/rh.orig.nofix 

#--------------------------------------------
#@# Smooth1 rh Wed Dec 16 12:55:54 EST 2015

 mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 rh Wed Dec 16 12:55:59 EST 2015

 mris_inflate -no-save-sulc ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix 

#--------------------------------------------
#@# QSphere rh Wed Dec 16 12:56:48 EST 2015

 mris_sphere -q -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix 

#--------------------------------------------
#@# Fix Topology rh Wed Dec 16 13:02:52 EST 2015

 cp ../surf/rh.orig.nofix ../surf/rh.orig 


 cp ../surf/rh.inflated.nofix ../surf/rh.inflated 


 mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 FreeSurfer rh 


 mris_euler_number ../surf/rh.orig 


 mris_remove_intersection ../surf/rh.orig ../surf/rh.orig 


 rm ../surf/rh.inflated 

#--------------------------------------------
#@# Make White Surf rh Wed Dec 16 13:26:13 EST 2015

 mris_make_surfaces -noaparc -whiteonly -mgz -T1 brain.finalsurfs FreeSurfer rh 

#--------------------------------------------
#@# Smooth2 rh Wed Dec 16 13:32:42 EST 2015

 mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white ../surf/rh.smoothwm 

#--------------------------------------------
#@# Inflation2 rh Wed Dec 16 13:32:48 EST 2015

 mris_inflate ../surf/rh.smoothwm ../surf/rh.inflated 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/rh.inflated 


#-----------------------------------------
#@# Curvature Stats rh Wed Dec 16 13:35:22 EST 2015

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm FreeSurfer rh curv sulc 

#--------------------------------------------
#@# Sphere rh Wed Dec 16 13:35:27 EST 2015

 mris_sphere -seed 1234 ../surf/rh.inflated ../surf/rh.sphere 

#--------------------------------------------
#@# Surf Reg rh Wed Dec 16 14:48:17 EST 2015

 mris_register -curv ../surf/rh.sphere /usr/local/freesurfer/5.1/average/rh.average.curvature.filled.buckner40.tif ../surf/rh.sphere.reg 

#--------------------------------------------
#@# Jacobian white rh Wed Dec 16 15:33:14 EST 2015

 mris_jacobian ../surf/rh.white ../surf/rh.sphere.reg ../surf/rh.jacobian_white 

#--------------------------------------------
#@# AvgCurv rh Wed Dec 16 15:33:16 EST 2015

 mrisp_paint -a 5 /usr/local/freesurfer/5.1/average/rh.average.curvature.filled.buckner40.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv 

#-----------------------------------------
#@# Cortical Parc rh Wed Dec 16 15:33:19 EST 2015

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 FreeSurfer rh ../surf/rh.sphere.reg /usr/local/freesurfer/5.1/average/rh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ../label/rh.aparc.annot 

#--------------------------------------------
#@# Make Pial Surf rh Wed Dec 16 15:34:40 EST 2015

 mris_make_surfaces -white NOWRITE -mgz -T1 brain.finalsurfs FreeSurfer rh 

#--------------------------------------------
#@# Surf Volume rh Wed Dec 16 15:47:46 EST 2015

 mris_calc -o rh.area.mid rh.area add rh.area.pial 


 mris_calc -o rh.area.mid rh.area.mid div 2 


 mris_calc -o rh.volume rh.area.mid mul rh.thickness 

#-----------------------------------------
#@# Parcellation Stats rh Wed Dec 16 15:47:46 EST 2015

 mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab FreeSurfer rh white 

#-----------------------------------------
#@# Cortical Parc 2 rh Wed Dec 16 15:48:21 EST 2015

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 FreeSurfer rh ../surf/rh.sphere.reg /usr/local/freesurfer/5.1/average/rh.destrieux.simple.2009-07-29.gcs ../label/rh.aparc.a2009s.annot 

#-----------------------------------------
#@# Parcellation Stats 2 rh Wed Dec 16 15:49:50 EST 2015

 mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab FreeSurfer rh white 

#--------------------------------------------
#@# Cortical ribbon mask Wed Dec 16 15:50:28 EST 2015

 mris_volmask --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon FreeSurfer 

#--------------------------------------------
#@# ASeg Stats Wed Dec 16 16:00:00 EST 2015

 mri_segstats --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol --totalgray --ctab /usr/local/freesurfer/5.1/ASegStatsLUT.txt --subject FreeSurfer 

#-----------------------------------------
#@# AParc-to-ASeg Wed Dec 16 16:10:52 EST 2015

 mri_aparc2aseg --s FreeSurfer --volmask 


 mri_aparc2aseg --s FreeSurfer --volmask --a2009s 

#-----------------------------------------
#@# WMParc Wed Dec 16 16:15:08 EST 2015

 mri_aparc2aseg --s FreeSurfer --labelwm --hypo-as-wm --rip-unknown --volmask --o mri/wmparc.mgz --ctxseg aparc+aseg.mgz 


 mri_segstats --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brain-vol-from-seg --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject FreeSurfer --surf-wm-vol --ctab /usr/local/freesurfer/5.1/WMParcStatsLUT.txt --etiv 

#--------------------------------------------
#@# BA Labels lh Wed Dec 16 16:37:30 EST 2015

 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.BA1.label --trgsubject FreeSurfer --trglabel ./lh.BA1.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.BA2.label --trgsubject FreeSurfer --trglabel ./lh.BA2.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.BA3a.label --trgsubject FreeSurfer --trglabel ./lh.BA3a.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.BA3b.label --trgsubject FreeSurfer --trglabel ./lh.BA3b.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.BA4a.label --trgsubject FreeSurfer --trglabel ./lh.BA4a.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.BA4p.label --trgsubject FreeSurfer --trglabel ./lh.BA4p.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.BA6.label --trgsubject FreeSurfer --trglabel ./lh.BA6.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.BA44.label --trgsubject FreeSurfer --trglabel ./lh.BA44.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.BA45.label --trgsubject FreeSurfer --trglabel ./lh.BA45.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.V1.label --trgsubject FreeSurfer --trglabel ./lh.V1.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.V2.label --trgsubject FreeSurfer --trglabel ./lh.V2.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/lh.MT.label --trgsubject FreeSurfer --trglabel ./lh.MT.label --hemi lh --regmethod surface 


 mris_label2annot --s FreeSurfer --hemi lh --ctab /usr/local/freesurfer/5.1/average/colortable_BA.txt --l lh.BA1.label --l lh.BA2.label --l lh.BA3a.label --l lh.BA3b.label --l lh.BA4a.label --l lh.BA4p.label --l lh.BA6.label --l lh.BA44.label --l lh.BA45.label --l lh.V1.label --l lh.V2.label --l lh.MT.label --a BA --maxstatwinner --noverbose 


 mris_anatomical_stats -mgz -f ../stats/lh.BA.stats -b -a ./lh.BA.annot -c ./BA.ctab FreeSurfer lh white 

#--------------------------------------------
#@# BA Labels rh Wed Dec 16 16:40:07 EST 2015

 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.BA1.label --trgsubject FreeSurfer --trglabel ./rh.BA1.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.BA2.label --trgsubject FreeSurfer --trglabel ./rh.BA2.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.BA3a.label --trgsubject FreeSurfer --trglabel ./rh.BA3a.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.BA3b.label --trgsubject FreeSurfer --trglabel ./rh.BA3b.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.BA4a.label --trgsubject FreeSurfer --trglabel ./rh.BA4a.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.BA4p.label --trgsubject FreeSurfer --trglabel ./rh.BA4p.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.BA6.label --trgsubject FreeSurfer --trglabel ./rh.BA6.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.BA44.label --trgsubject FreeSurfer --trglabel ./rh.BA44.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.BA45.label --trgsubject FreeSurfer --trglabel ./rh.BA45.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.V1.label --trgsubject FreeSurfer --trglabel ./rh.V1.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.V2.label --trgsubject FreeSurfer --trglabel ./rh.V2.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/ray/Data/FreeSurferMNI152/fsaverage/label/rh.MT.label --trgsubject FreeSurfer --trglabel ./rh.MT.label --hemi rh --regmethod surface 


 mris_label2annot --s FreeSurfer --hemi rh --ctab /usr/local/freesurfer/5.1/average/colortable_BA.txt --l rh.BA1.label --l rh.BA2.label --l rh.BA3a.label --l rh.BA3b.label --l rh.BA4a.label --l rh.BA4p.label --l rh.BA6.label --l rh.BA44.label --l rh.BA45.label --l rh.V1.label --l rh.V2.label --l rh.MT.label --a BA --maxstatwinner --noverbose 


 mris_anatomical_stats -mgz -f ../stats/rh.BA.stats -b -a ./rh.BA.annot -c ./BA.ctab FreeSurfer rh white 

#--------------------------------------------
#@# Ex-vivo Entorhinal Cortex Label lh Wed Dec 16 16:42:45 EST 2015

 mris_spherical_average -erode 1 -orig white -t 0.4 -o FreeSurfer label lh.entorhinal lh sphere.reg lh.EC_average lh.entorhinal_exvivo.label 


 mris_anatomical_stats -mgz -f ../stats/lh.entorhinal_exvivo.stats -b -l ./lh.entorhinal_exvivo.label FreeSurfer lh white 

#--------------------------------------------
#@# Ex-vivo Entorhinal Cortex Label rh Wed Dec 16 16:43:02 EST 2015

 mris_spherical_average -erode 1 -orig white -t 0.4 -o FreeSurfer label rh.entorhinal rh sphere.reg rh.EC_average rh.entorhinal_exvivo.label 


 mris_anatomical_stats -mgz -f ../stats/rh.entorhinal_exvivo.stats -b -l ./rh.entorhinal_exvivo.label FreeSurfer rh white 

