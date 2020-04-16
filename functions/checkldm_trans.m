
function out = checkldm_trans(Outdir,segframepath)

addpath([segframepath,'/thirdparty/spm'])
addpath(genpath([segframepath,'/thirdparty/nifti']))

for noofregion = [1:3,5:35]
    
    name = num2str(noofregion,'%03d');

    disp(['Translation for Region-',name,'  ------ ~',num2str(100*noofregion/35),'%'])

    outpath = [Outdir,'/region1',name,'/'];
	unix(['gzip -d ',outpath,'aparc+aseg_1',name,'_Gaffine.nii.gz']);
	unix(['gzip -d ',outpath,'aparc+aseg_1',name,'_MNI.nii.gz']);
    [region regionhdr] = rest_ReadNiftiImage([outpath,'aparc+aseg_1',name,'_Gaffine.nii']);
    [regionMNI MNIhdr] = rest_ReadNiftiImage([outpath,'aparc+aseg_1',name,'_MNI.nii']);
        	unix(['gzip ',outpath,'aparc+aseg_1',name,'_Gaffine.nii']);
	unix(['gzip ',outpath,'aparc+aseg_1',name,'_MNI.nii']);

    regionldm = textread([outpath,'brain-lh-',name,'-VOX-trans.label']);
    regionMNIldm = textread([outpath,'brain-lh-',name,'-MNI-VOX-ds.label']);

    %% trans volume

    [y, x, z] = ind2sub(size(region), find(region));
    [yMNI, xMNI, zMNI] = ind2sub(size(regionMNI), find(regionMNI));
    dtx = round(mean(xMNI) - mean(x));
    dty = round(mean(yMNI) - mean(y));
    dtz = round(mean(zMNI) - mean(z));

     fid0 = fopen([outpath,'trans-',name,'.txt'],'wt');
     fprintf(fid0,'%.0f  %.0f  %.0f',dtx,dty,dtz);
     
    
    xnew = x + dtx;
    ynew = y + dty;
    znew = z + dtz;
    region_trans = zeros(256,256,256);

    for i = 1:length(xnew)

        region_trans(ynew(i),xnew(i),znew(i)) = 1000 + noofregion;

    end

     rest_WriteNiftiImage(region_trans,regionhdr,[outpath,'aparc+aseg_1',name,'_trans.nii']);
     rest_WriteNiftiImage(region_trans,MNIhdr,[outpath,'aparc+aseg_1',name,'_trans_inMNI.nii']);
        unix(['gzip ',outpath,'aparc+aseg_1',name,'_trans.nii']);
	unix(['gzip ',outpath,'aparc+aseg_1',name,'_trans_inMNI.nii']);

    %% Translate landmarks
    regionldmnew = regionldm + [repmat([dty dtx dtz],length(regionldm),1) ones(length(regionldm),1)];

     fid1 = fopen([outpath,'brain-lh-',name,'-VOX-localtrans.label'],'wt');
     for ii = 1:length(regionldmnew)
        fprintf(fid1,'%.3f  %.3f  %.3f %.0f\n',regionldmnew(ii,1),regionldmnew(ii,2),regionldmnew(ii,3),ii-1);
     end

   
  disp(['Landmark RAS for Region-',name,'  ------ ~',num2str(100*noofregion/35),'%'])
	unix(['gzip -d ',outpath,'aparc+aseg_1',name,'_trans.nii.gz']);
    [region regionhdr] = rest_ReadNiftiImage([outpath,'aparc+aseg_1',name,'_trans.nii']);
	unix(['gzip ',outpath,'aparc+aseg_1',name,'_trans.nii']);
    Torig2 = regionhdr.mat;

regionldm = textread([outpath,'brain-lh-',name,'-VOX-localtrans.label']);

    regionldmrasobj = importdata([outpath,'/brain-lh-',name,'-RAS-trans.label']);
    regionldmras = reshape(regionldmrasobj.data(2:end),5,length(regionldm))';
    
    regionldm(:,4) = ones(length(regionldm),1);
    newldmras_nofix = Torig2*regionldm';
    newldmras_nofix = newldmras_nofix';

    fid1 = fopen([outpath,'brain-lh-',name,'-RAS-localtrans.label'],'wt');
    fprintf(fid1,'#!ascii label  , from subject FreeSurfer vox2ras=TkReg \n');
    fprintf(fid1,[num2str(length(newldmras_nofix)),'\n']);
    for ii = 1:length(newldmras_nofix)
       fprintf(fid1,'%.0f %.3f  %.3f  %.3f %.0f\n',regionldmras(ii,1),newldmras_nofix(ii,1),newldmras_nofix(ii,2),newldmras_nofix(ii,3),ii-1);
    end


end


end








