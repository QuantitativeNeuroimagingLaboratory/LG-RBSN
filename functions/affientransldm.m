
function affientransldm(SUB,Outdir,subjectdir,segframedir,subprojdir)

%SUB = 'P00005982';
%Outdir = '/share/projects/razlighi_lab/users/hengda/RDIR_LM/GlobalInitial/Workspace_P00005982';
%subjectdir = '/share/projects/razlighi_lab/users/hengda/RDIR_LM/subjects_FS';

addpath([segframedir,'/thirdparty/spm'])
addpath([segframedir,'/thirdparty/nifti'])

for noofregion = [1:3,5:35]
    
    name = num2str(noofregion,'%03d');

    disp(['GLobal affine for Region-',name,'  ------ ~',num2str(100*noofregion/35),'%'])

    outpath = [Outdir,'/region1',name,'/'];

    regionldm = textread([outpath,'brain-lh-',name,'-VOX-ds.label']);

    affinetrans=textread([subprojdir,'/brain2MNI_affine.mat']);
    affinetrans = affinetrans(1:4,1:4);

    %% apply transform to ldm
    
    numoflm = length(regionldm);
    Xm = [regionldm(:,1:3)-1,ones(numoflm,1)]; % minus 1
    sublmvoxall_ac_MNI= affinetrans *Xm';
    sublmvoxall_ac_MNI = sublmvoxall_ac_MNI(1:3,:)';
    
    fid1 = fopen([outpath,'brain-lh-',name,'-VOX-trans.label'],'wt');
     for ii = 1:numoflm
        fprintf(fid1,'%.3f  %.3f  %.3f %.0f\n',sublmvoxall_ac_MNI(ii,1)+1,sublmvoxall_ac_MNI(ii,2)+1,sublmvoxall_ac_MNI(ii,3)+1,ii-1);
     end

    %% RAS ldm
    
    [s3,NorigstrMNI]=unix(['mri_info --vox2ras ',subjectdir,'/FreeSurferMNI152/mri/aparc+aseg.mgz']);
    NorigMNI=str2num(NorigstrMNI);

    Output = NorigMNI*[sublmvoxall_ac_MNI ones(numoflm,1)]';
    sublmrasall_ac_affine = Output(1:3,:)';
%     
    %% RAS ldm
    
    
    disp(['Landmark RAS for Region-1',name,'  ------ ~',num2str(100*noofregion/35),'%'])


    regionldmrasobj = importdata([outpath,'/brain-lh-',name,'-RAS-ds-forview.label']);
    regionldmras = reshape(regionldmrasobj.data(2:end),5,length(sublmvoxall_ac_MNI))';

    fid1 = fopen([outpath,'brain-lh-',name,'-RAS-trans.label'],'wt');
    fprintf(fid1,'#!ascii label  , from subject FreeSurfer vox2ras=TkReg \n');
    fprintf(fid1,[num2str(numoflm),'\n']);
    for ii = 1:numoflm
       fprintf(fid1,'%.0f %.3f  %.3f  %.3f %.0f\n',regionldmras(ii,1),sublmrasall_ac_affine(ii,1),sublmrasall_ac_affine(ii,2),sublmrasall_ac_affine(ii,3),ii-1);
    end

end

%% rh
for noofregion = [1:3,5:35]
    
    name = num2str(noofregion,'%03d');
    disp(['GLobal affine for Region-2',name,'  ------ ~',num2str(100*noofregion/35),'%'])
    outpath = [Outdir,'/region2',name,'/']; 
    regionldm = textread([outpath,'brain-rh-',name,'-VOX-ds.label']);
    affinetrans=textread([subprojdir,'/brain2MNI_affine.mat']);
    affinetrans = affinetrans(1:4,1:4);

    %% apply transform to ldm
    
    numoflm = length(regionldm);
    Xm = [regionldm(:,1:3)-1,ones(numoflm,1)]; % minus 1
    sublmvoxall_ac_MNI= affinetrans *Xm';
    sublmvoxall_ac_MNI = sublmvoxall_ac_MNI(1:3,:)';
    
    fid1 = fopen([outpath,'brain-rh-',name,'-VOX-trans.label'],'wt');
     for ii = 1:numoflm
        fprintf(fid1,'%.3f  %.3f  %.3f %.0f\n',sublmvoxall_ac_MNI(ii,1)+1,sublmvoxall_ac_MNI(ii,2)+1,sublmvoxall_ac_MNI(ii,3)+1,ii-1);
     end

    %% RAS ldm
    
    [s3,NorigstrMNI]=unix(['mri_info --vox2ras ',subjectdir,'/FreeSurferMNI152/mri/aparc+aseg.mgz']);
    NorigMNI=str2num(NorigstrMNI);

    Output = NorigMNI*[sublmvoxall_ac_MNI ones(numoflm,1)]';
    sublmrasall_ac_affine = Output(1:3,:)';
%     
    %% RAS ldm
    disp(['Landmark RAS for Region-2',name,'  ------ ~',num2str(100*noofregion/35),'%'])

    regionldmrasobj = importdata([outpath,'/brain-rh-',name,'-RAS-ds-forview.label']);
    regionldmras = reshape(regionldmrasobj.data(2:end),5,length(sublmvoxall_ac_MNI))';

    fid1 = fopen([outpath,'brain-rh-',name,'-RAS-trans.label'],'wt');
    fprintf(fid1,'#!ascii label  , from subject FreeSurfer vox2ras=TkReg \n');
    fprintf(fid1,[num2str(numoflm),'\n']);
    for ii = 1:numoflm
       fprintf(fid1,'%.0f %.3f  %.3f  %.3f %.0f\n',regionldmras(ii,1),sublmrasall_ac_affine(ii,1),sublmrasall_ac_affine(ii,2),sublmrasall_ac_affine(ii,3),ii-1);
    end


end

end








