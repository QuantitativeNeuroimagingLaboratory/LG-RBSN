#!/bin/bash

for i in `ls log_debug/Demons_P00005966_simiweight_*_sigma_*_iterations_*_weight2_*.txt`; do echo $i;ii=${i%_w*};iii=${ii#*tions_};cat $i | grep "it-${iii} foreward_bi"; done 
