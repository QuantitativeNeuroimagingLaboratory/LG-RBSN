#!/bin/env python
# encoding: utf-8

"""
This scripts use freesurfer surface based registration to transfer the region-wise 
vertices from subject space to MNI152 space 

Usage: TransferFreesurferVerticesToMNI.py <FreeSurefrSubjectDir> <MovingSubject> <ReferrenceSubject> <OutputDir>


Created by Ray Razlighi on 2010-09-08.
Copyright (c) 2010 __MyCompanyName__. All rights reserved.
"""

import sys
import glob
import nibabel as nb
import numpy as np
import subprocess as sp
import os


ReD = "\033[91m"
YelloW = "\033[93m"
EndC = "\033[0m"

# The MNI152 freesurfer needs to be in the SUBJECTS_DIR

FS_SubjectDir=sys.argv[1]
MovingSubject=sys.argv[2]
ReferrenceSubject=sys.argv[3]
OutputDir=sys.argv[4]

'''
For Testing purpose only
FS_SubjectDir = '/share/users/ray/Data/Hengda/'
MovingSubject = 'FreeSurfer'
ReferrenceSubject = 'FreeSurferMNI152'
OutputDir = '/share/users/ray/Data/Hengda/FreeSurfer/Vertices'
'''


os.environ["SUBJECTS_DIR"] = FS_SubjectDir

if (sp.call(['mkdir', '-p', OutputDir])!=0):
	print ReD +'Creating output directory failed'+EndC 
	sys.exit(4)


if (sp.call(['mri_annotation2label', '--subject', MovingSubject, '--hemi', 'lh', '--labelbase', OutputDir+'/aparc-lh' ])!=0):
	print ReD +'Extracting the vertex for all the cortical region in left hemisphere failed'+EndC 
	sys.exit(4)

if (sp.call(['mri_annotation2label', '--subject', MovingSubject, '--hemi', 'rh', '--labelbase', OutputDir+'/aparc-rh' ])!=0):
	print ReD +'Extracting the vertex for all the cortical region in right hemisphere failed'+EndC 
	sys.exit(4)


if (sp.call(['mri_annotation2label', '--subject', MovingSubject, '--hemi', 'lh', '--surf', 'pial',  '--labelbase', OutputDir+'/pial-aparc-lh' ])!=0):
	print ReD +'Extracting the vertex for all the cortical region in left hemisphere pial surface failed'+EndC 
	sys.exit(4)

if (sp.call(['mri_annotation2label', '--subject', MovingSubject, '--hemi', 'rh', '--surf', 'pial',  '--labelbase', OutputDir+'/pial-aparc-rh' ])!=0):
	print ReD +'Extracting the vertex for all the cortical region in right hemisphere pial surface failed'+EndC 
	sys.exit(4)

for Hemi in ['lh', 'rh']:
	print 'Generating the coorespondance map for hemisphere ' + Hemi

        for k in range(1,4)+range(5,36):

		# Load vertecies again
		Vertices = np.loadtxt(OutputDir+'/aparc-'+Hemi+'-%.3d.label' %k, skiprows=2)
		PialVertices = np.loadtxt(OutputDir+'/pial-aparc-'+Hemi+'-%.3d.label' %k, skiprows=2)
	
		# Add the fifth columns for the correpondance
		Vertices[:,-1] = np.arange(1,Vertices.shape[0]+1,1)
		PialVertices[:,-1] = np.arange(1,PialVertices.shape[0]+1,1)

		# Save the vertices with fith column
		with open(OutputDir+'/aparc-'+Hemi+'-%.3d_5thCol.label' %k,'wb') as f:
		 f.write('#!ascii label  , from subject FreeSurfer vox2ras=TkReg\n')
		 f.write(str(Vertices.shape[0])+'\n')
		 np.savetxt(f, Vertices, fmt='%d  %.3f  %.3f  %.3f %d', delimiter=' ', newline='\n')

		with open(OutputDir+'/pial-aparc-'+Hemi+'-%.3d_5thCol.label' %k,'wb') as f2:
		 f2.write('#!ascii label  , from subject FreeSurfer vox2ras=TkReg\n')
		 f2.write(str(PialVertices.shape[0])+'\n')
		 np.savetxt(f2, PialVertices, fmt='%d  %.3f  %.3f  %.3f %d', delimiter=' ', newline='\n')


		if (sp.call(['mri_label2label', '--srclabel', OutputDir+'/aparc-'+Hemi+'-%.3d_5thCol.label' %k,'--srcsubject', MovingSubject, '--trglabel', OutputDir+'/aparc-'+Hemi+'-%.3d_5thCol_Reg2MNI.label' %k,  '--trgsubject', ReferrenceSubject, '--regmethod', 'surface', '--hemi', Hemi])!=0):
			print ReD +'Transfering white-matter vertices to MNI space failed'+EndC 
			sys.exit(4)

		if (sp.call(['mri_label2label', '--srclabel', OutputDir+'/pial-aparc-'+Hemi+'-%.3d_5thCol.label' %k,'--srcsubject', MovingSubject, '--trglabel', OutputDir+'/pial-aparc-'+Hemi+'-%.3d_5thCol_Reg2MNI.label' %k,  '--trgsubject', ReferrenceSubject, '--regmethod', 'surface', '--trgsurf', 'pial', '--hemi', Hemi])!=0):
			print ReD +'Transfering pial-matter vertices to MNI space failed'+EndC 
			sys.exit(4)

		# Generating the vertices coorespondance map for white matter surface
		Vertices_reg=np.loadtxt(OutputDir+'/aparc-'+Hemi+'-%.3d_5thCol_Reg2MNI.label' %k, skiprows=2)
		Vertex_Map = np.zeros((Vertices_reg.shape[0],10))
		j = 0
		for i in xrange(Vertices.shape[0]):
			if(Vertices_reg[:,4]==i+1).sum():
                                hek = (Vertices_reg[:,4]==i+1).sum()
                                for hei in range(0,hek):
				  Vertex_Map[j,:5] = Vertices[i,:5]
				  Vertex_Map[j,5:10] = Vertices_reg[(Vertices_reg[:,4]==i+1)][hei]
				  j += 1

		# Saving the correspondance map for white matter surface	
		np.savetxt(OutputDir+'/aparc-'+Hemi+'-%.3d_CorrespondanceMap2MNI.label' %k, Vertex_Map, fmt='%d  %.4f  %.4f  %.4f  %d    %d  %.4f  %.4f  %.4f  %d', delimiter=' ', newline='\n')
	
	
		# Generating the vertices coorespondance map for pial matter surface
		PialVertices_reg=np.loadtxt(OutputDir+'/pial-aparc-'+Hemi+'-%.3d_5thCol_Reg2MNI.label' %k, skiprows=2)
		PialVertex_Map = np.zeros((PialVertices_reg.shape[0],10))
		j = 0

		for i in xrange(PialVertices.shape[0]):
			if(PialVertices_reg[:,4]==i+1).sum():
                                hek = (PialVertices_reg[:,4]==i+1).sum()
                                for hei in range(0,hek):
				  PialVertex_Map[j,:5] = PialVertices[i,:5]
				  PialVertex_Map[j,5:10] = PialVertices_reg[(PialVertices_reg[:,4]==i+1)][hei]
				  j += 1
		# Saving the correspondance map for pial matter surface		
		np.savetxt(OutputDir+'/pial-aparc-'+Hemi+'-%.3d_CorrespondanceMap2MNI.label' %k, PialVertex_Map, fmt='%d  %.4f  %.4f  %.4f  %d    %d  %.4f  %.4f  %.4f  %d', delimiter=' ', newline='\n')

	


