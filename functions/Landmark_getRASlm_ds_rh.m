

function outputnum=Landmark_getRASlm_ds_rh(subjectID,subjectdir,Outdir)

path = [subjectdir,'/FreeSurfer_',subjectID,'/FinalVertices/'];
disp(path)

for noofregion = [1:3,5:35]
    
name = num2str(noofregion,'%03d');

disp(['Generating Landmarks for rh Region-',name,'  ------ ~',num2str(100*noofregion/35),'%'])

outpath = [Outdir,'/region2',name,'/'];
disp(outpath)

Corrpoints = textread([path,'aparc-rh-',name,'_CorrespondanceMap2MNI_ds.label']);

if (find(Corrpoints(:,10)==0))
numoflm = min(find(Corrpoints(:,10)==0))-1;
else
numoflm = size(Corrpoints,1); 
end

  sublm = Corrpoints(1:numoflm,[7:9]);
  MNIlm = Corrpoints(1:numoflm,[2:4]);
  subverno = Corrpoints(1:numoflm,6);
  MNIverno = Corrpoints(1:numoflm,1);

[s1,Norigstr]=unix(['mri_info --vox2ras ',subjectdir,'/FreeSurfer_',subjectID,'/mri/aseg.mgz']);
[s2,Torigstr]=unix(['mri_info --vox2ras-tkr ',subjectdir,'/FreeSurfer_',subjectID,'/mri/aseg.mgz']);
[s3,NorigstrMNI]=unix(['mri_info --vox2ras ',subjectdir,'/FreeSurferMNI152/mri/aparc+aseg.mgz']);
[s4,TorigstrMNI]=unix(['mri_info --vox2ras-tkr ',subjectdir,'/FreeSurferMNI152/mri/orig.mgz']);

Norig=str2num(Norigstr);
Torig=str2num(Torigstr);
NorigMNI=str2num(NorigstrMNI);
TorigMNI=str2num(TorigstrMNI);

sublmRAS = zeros(numoflm,3);
MNIlmRAS = zeros(numoflm,3);
sublmvox = zeros(numoflm,3);
MNIlmvox = zeros(numoflm,3);

% RAS2RAS
sublmX = [sublm ones(numoflm,1)];
sublmRASX = Norig*inv(Torig)*sublmX';
sublmvoxX = inv(Norig)*sublmRASX;
sublmRAS = sublmRASX(1:3,:)';
sublmvox = sublmvoxX(1:3,:)';

MNIlmX = [MNIlm ones(numoflm,1)];
MNIlmRASX = NorigMNI*inv(TorigMNI)*MNIlmX';
MNIlmvoxX = inv(NorigMNI)*MNIlmRASX;
MNIlmRAS = MNIlmRASX(1:3,:)';
MNIlmvox = MNIlmvoxX(1:3,:)';


Corrpoints2 = textread([path,'pial-aparc-rh-',name,'_CorrespondanceMap2MNI_ds.label']);

if (find(Corrpoints2(:,10)==0))
numoflm2 = min(find(Corrpoints2(:,10)==0))-1;
else
numoflm2 = size(Corrpoints2,1); 
end

 sublm2 = Corrpoints2(1:numoflm2,[7:9]);
  MNIlm2 = Corrpoints2(1:numoflm2,[2:4]);
  subverno2 = Corrpoints2(1:numoflm2,6);
  MNIverno2 = Corrpoints2(1:numoflm2,1);

[s1,Norigstr2]=unix(['mri_info --vox2ras ',subjectdir,'/FreeSurfer_',subjectID,'/mri/aseg.mgz']);
[s2,Torigstr2]=unix(['mri_info --vox2ras-tkr ',subjectdir,'/FreeSurfer_',subjectID,'/mri/aseg.mgz']);
[s3,NorigstrMNI2]=unix(['mri_info --vox2ras ',subjectdir,'/FreeSurferMNI152/mri/aparc+aseg.mgz']);
[s4,TorigstrMNI2]=unix(['mri_info --vox2ras-tkr ',subjectdir,'/FreeSurferMNI152/mri/orig.mgz']);

Norig2=str2num(Norigstr2);
Torig2=str2num(Torigstr2);
NorigMNI2=str2num(NorigstrMNI2);
TorigMNI2=str2num(TorigstrMNI2);

sublmRAS2 = zeros(numoflm2,3);
MNIlmRAS2 = zeros(numoflm2,3);
sublmvox2 = zeros(numoflm2,3);
MNIlmvox2 = zeros(numoflm2,3);

sublmX2 = [sublm2 ones(numoflm2,1)];
sublmRASX2 = Norig2*inv(Torig2)*sublmX2';
sublmvoxX2 = inv(Norig2)*sublmRASX2;
sublmRAS2 = sublmRASX2(1:3,:)';
sublmvox2 = sublmvoxX2(1:3,:)';

MNIlmX2 = [MNIlm2 ones(numoflm2,1)];
MNIlmRASX2 = NorigMNI2*inv(TorigMNI2)*MNIlmX2';
MNIlmvoxX2 = inv(NorigMNI2)*MNIlmRASX2;
MNIlmRAS2 = MNIlmRASX2(1:3,:)';
MNIlmvox2 = MNIlmvoxX2(1:3,:)';

sublmvoxall_ac = [sublmvox' sublmvox2']';

MNIlmvoxall_ac = [MNIlmvox' MNIlmvox2']';

sublmRASall = [sublmRAS' sublmRAS2']';
MNIlmRASall = [MNIlmRAS' MNIlmRAS2']';
subvernoall = [subverno' subverno2']';
MNIvernoall = [MNIverno' MNIverno2']';


%% transformation est


Xm = [sublmvoxall_ac,ones(numoflm+numoflm2,1)];
sublmvoxall_ac_MNI= Xm';
sublmvoxall_ac_MNI = sublmvoxall_ac_MNI(1:3,:)';

Output = Norig*[sublmvoxall_ac_MNI ones(numoflm+numoflm2,1)]';

sublmrasall_ac_affine = Output(1:3,:)';

selectlabel = ones(numoflm+numoflm2,1);

outputindex = find(selectlabel==1);
outputnum = length(outputindex);

fid3 = fopen([outpath,'brain-rh-',name,'-RAS-ds-forview.label'],'wt');
fprintf(fid3,'#!ascii label  , from subject FreeSurfer vox2ras=TkReg \n');
fprintf(fid3,[num2str(outputnum),'\n']);
for ii = 1:outputnum
   fprintf(fid3,'%.0f %.3f  %.3f  %.3f %.0f\n',subvernoall(outputindex(ii)),sublmrasall_ac_affine(outputindex(ii),1),sublmrasall_ac_affine(outputindex(ii),2),sublmrasall_ac_affine(outputindex(ii),3),ii-1);
end

fid4 = fopen([outpath,'brain-rh-',name,'-MNI-RAS-ds-forview.label'],'wt');
fprintf(fid4,'#!ascii label  , from subject FreeSurferMNI152 vox2ras=TkReg \n');
fprintf(fid4,[num2str(outputnum),'\n']);
for ii = 1:outputnum
   fprintf(fid4,'%.0f %.3f  %.3f  %.3f %.0f\n',MNIvernoall(outputindex(ii)),MNIlmRASall(outputindex(ii),1),MNIlmRASall(outputindex(ii),2),MNIlmRASall(outputindex(ii),3),ii-1);
end

fid1 = fopen([outpath,'brain-rh-',name,'-VOX-ds.label'],'wt');
for ii = 1:outputnum
   fprintf(fid1,'%.3f  %.3f  %.3f %.0f\n',sublmvoxall_ac_MNI(outputindex(ii),1)+1,sublmvoxall_ac_MNI(outputindex(ii),2)+1,sublmvoxall_ac_MNI(outputindex(ii),3)+1,ii-1);
end

fid2 = fopen([outpath,'brain-rh-',name,'-MNI-VOX-ds.label'],'wt');
for ii = 1:outputnum
   fprintf(fid2,'%.3f  %.3f  %.3f %.0f\n',MNIlmvoxall_ac(outputindex(ii),1)+1,MNIlmvoxall_ac(outputindex(ii),2)+1,MNIlmvoxall_ac(outputindex(ii),3)+1,ii-1);
end


disp(['region2',name,'---landmarks number',num2str(outputnum)])

end

end



