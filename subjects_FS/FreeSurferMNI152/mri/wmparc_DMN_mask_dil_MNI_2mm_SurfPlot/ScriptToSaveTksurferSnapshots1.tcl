#!/bin/tcl

set pre "wmparc_DMN_mask_dil_MNI_2mm_SurfPlot/snapshots_right"

puts "Taking Snapshots..."
make_lateral_view
rotate_brain_y 90
redraw
set tiff "${pre}_back.tif"
save_tiff $tiff
make_lateral_view
redraw
set tiff "${pre}_lateral.tif"
save_tiff $tiff
rotate_brain_y 180
redraw
set tiff "${pre}_medial.tif"
save_tiff $tiff
make_lateral_view
rotate_brain_x 90
redraw
set tiff "${pre}_inferior.tif"
save_tiff $tiff
rotate_brain_x 180
redraw
set tiff "${pre}_superior.tif"
save_tiff $tiff
make_lateral_view
rotate_brain_y 270
redraw
set tiff "${pre}_front.tif"
save_tiff $tiff

exit
