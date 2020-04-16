function Apply2region_savedisp(SUB,regioninput,projectdir)

% SUB = 'P00005982';
% regioninput = 1032;
% projectdir='/share/projects/razlighi_lab/users/hengda/RDIR_v2';

addpath([projectdir,'/segframe-master/thirdparty/nifti'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions_nonrigid'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions_affine'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/image-registration-master'])

kernelsize = 4;
weight = 100;

Outdir = [projectdir,'/Workspace_',SUB];
kernelscale = num2str(kernelsize);

%% LOADING
    region = num2str(regioninput);
    datadir = [Outdir,'/region',region,'/'];
    trans = textread([datadir,'trans-',region(2:end),'.txt']);
    
    if round(regioninput/1000)==1
        hm = 'lh';
    else if round(regioninput/1000)==2
            hm = 'rh';
        end
    end

    %% Images
    % NIFTI Images
    disp('Load NIFTI Images')
    disp([datadir,'aparc+aseg_',region,'_MNI.nii'])
    %[MNI MNIheader] = rest_ReadNiftiImage([datadir,'aparc+aseg_',region,'_MNI.nii']);
	    MNIst = load_untouch_nii([datadir,'aparc+aseg_',region,'_MNI.nii.gz']);
    MNI = double(MNIst.img);

    disp([datadir,'aparc+aseg_',region,'_Gaffine.nii'])
    %[sub subheader] = rest_ReadNiftiImage([datadir,'aparc+aseg_',region,'.nii']);
    subst = load_untouch_nii([datadir,'aparc+aseg_',region,'_Gaffine.nii.gz']);
    sub = double(subst.img);
    
    disp([datadir,'aparc+aseg_',region,'.nii'])
    %[sub subheader] = rest_ReadNiftiImage([datadir,'aparc+aseg_',region,'.nii']);
    suborgst = load_untouch_nii([datadir,'aparc+aseg_',region,'.nii.gz']);
    suborg = double(suborgst.img);

    MNI(find(MNI~=0))=1;
    sub(find(sub~=0))=1;
    suborg(find(suborg~=0))=1;  
    %% lddmm
    % Results
    disp('Load LDDMM Results')
    disp([datadir,'LDDMMtransform',kernelscale,'_w',num2str(weight),'_trans.mat'])
    LDDMMres = load([datadir,'LDDMMtransform',kernelscale,'_w',num2str(weight),'_trans.mat']);
    
    %% Ouver all bounding box

[IUyMNI,IUxMNI,IUzMNI] = ind2sub(size(MNI),find(MNI == 1));
[IUy,IUx,IUz] = ind2sub(size(sub),find(sub == 1));
    
boundingbox = [max(min([IUxMNI;IUx + trans(1)])-12,3)...
 min(max([IUxMNI;IUx + trans(1)])+12,254)...
    max(min([IUyMNI;IUy+trans(2)])-12,3)...
 min(max([IUyMNI;IUy+trans(2)])+12,254)...
    max(min([IUzMNI;IUz+trans(3)])-12,3)...
 min(max([IUzMNI;IUz+trans(3)])+12,254)]; % kuoda bounding box
    
   %% Transformations

    [gridFixedBBX{1} gridFixedBBX{2} gridFixedBBX{3}] = meshgrid((boundingbox(3)-2):(boundingbox(4)+2)...
        ,(boundingbox(1)-2):(boundingbox(2)+2),(boundingbox(5)-2):(boundingbox(6)+2));

    %% transport 
    disp('obtain moving image result')
    transport = LDDMMres.methods.transport;
    var = false(1);
    [gridMovingBBXtransall rhott gridt] = transport(LDDMMres.result,gridFixedBBX,var);
    var = true(1);
    [gridMovingBBXtransall_back rhott_back gridt_back] = transport(LDDMMres.result,gridFixedBBX,var);
    
    %% forward transform displacement fields
    field = cell(3,1);
    for d = 1:3
        field{d} = zeros(size(sub));
        field{d}((boundingbox(3)-2):(boundingbox(4)+2)...
                      ,(boundingbox(1)-2):(boundingbox(2)+2),...
                      (boundingbox(5)-2):(boundingbox(6)+2)) = ...
                      permute(gridMovingBBXtransall{d} - gridFixedBBX{d},[2 1 3]);
    end
    
    % translation
    transrev(1) = trans(2);
    transrev(2) = trans(1);
    transrev(3) = trans(3);
    for d = 1:3
       initdisp{d} = transrev(d)*ones(size(sub));
    end
          
    % to before trans space
    for d = 1:3
        compdist{d} = movepixels(field{d},initdisp{1},initdisp{2},initdisp{3});
        compdist{d} = compdist{d}+initdisp{d};
    end
    
    % affine trans (affine displacement from parameters)

    affine = textread([projectdir,'/Subject/',SUB,'/brain2MNI_affine.mat']);
    affine = affine(1:4,1:4);
    displacement = transformation2displacement_hd(affine, [256 256 256]);
    for i = 1:3
        displacement{i} = permute(displacement{i},[2 1 3]);
    end

    % to original space
    for d = 1:3
        DISP_Fwd{d} = movepixels(compdist{d},displacement{1},displacement{2},displacement{3});
        DISP_Fwd{d} = DISP_Fwd{d}+displacement{d};
    end
    
    
        %% backward transform displacement fields
    field_back = cell(3,1);
    for d = 1:3
        field_back{d} = zeros(size(sub));
        field_back{d}((boundingbox(3)-2):(boundingbox(4)+2)...
                      ,(boundingbox(1)-2):(boundingbox(2)+2),...
                      (boundingbox(5)-2):(boundingbox(6)+2)) = ...
                      permute(gridMovingBBXtransall_back{d} - gridFixedBBX{d},[2 1 3]); 
    end
    
    % translation backward
    transrev(1) = trans(2);
    transrev(2) = trans(1);
    transrev(3) = trans(3);
    for d = 1:3
       initdisp{d} = -transrev(d)*ones(size(sub));
    end
          
    % affine backward

    unix(['convert_xfm -omat ',projectdir,'/Subject/',SUB,'/MNI2brain_affine.mat',' -inverse ',projectdir,'/Subject/',SUB,'/brain2MNI_affine.mat']);
    affine = textread([projectdir,'/Subject/',SUB,'/MNI2brain_affine.mat']);
    affine = affine(1:4,1:4);
    displacement_inv = transformation2displacement_hd(affine, [256 256 256]);
    for i = 1:3
    displacement_inv{i} = permute(displacement_inv{i},[2 1 3]);
    end

    % back_affine to after trans space
    for d = 1:3
        compdist{d} = movepixels(displacement_inv{d},initdisp{1},initdisp{2},initdisp{3});
        compdist{d} = compdist{d}+initdisp{d};
    end
    
    % to MNI space
    for d = 1:3
        DISP_Bwd{d} = movepixels(compdist{d},field_back{1},field_back{2},field_back{3});
        DISP_Bwd{d} = DISP_Bwd{d}+field_back{d};
    end
    %% Evaluation forward displacement with backward warp
    
    [IUyMNI,IUxMNI,IUzMNI] = ind2sub(size(MNI),find(MNI == 1));
    [IUy,IUx,IUz] = ind2sub(size(suborg),find(suborg == 1));

    bxapply = [max(min([IUxMNI;IUx])-2,1)...
     min(max([IUxMNI;IUx])+2,256)...
        max(min([IUyMNI;IUy])-2,1)...
     min(max([IUyMNI;IUy])+2,256)...
        max(min([IUzMNI;IUz])-2,1)...
     min(max([IUzMNI;IUz])+2,256)]; % kuoda bounding box

 % Backward Warp
     IMBBX = MNI((bxapply(3)):(bxapply(4))...
        ,(bxapply(1)):(bxapply(2)),(bxapply(5)):(bxapply(6)));
     def{1} = DISP_Fwd{2}((bxapply(3)):(bxapply(4))...
         ,(bxapply(1)):(bxapply(2)),(bxapply(5)):(bxapply(6)));
     def{2} = DISP_Fwd{1}((bxapply(3)):(bxapply(4))...
         ,(bxapply(1)):(bxapply(2)),(bxapply(5)):(bxapply(6)));
     def{3} = DISP_Fwd{3}((bxapply(3)):(bxapply(4))...
         ,(bxapply(1)):(bxapply(2)),(bxapply(5)):(bxapply(6)));
     IMresult = deformation(IMBBX,def,'nearest');
     IFBBX = suborg((bxapply(3)):(bxapply(4))...
        ,(bxapply(1)):(bxapply(2)),(bxapply(5)):(bxapply(6)));
    
         similarity = 2*nnz(IMresult&IFBBX)/(nnz(IMresult) + nnz(IFBBX));

        disp('------------Results---------------')
        disp(['Region-',region,' SUB&Deformed MNI, DICE=',num2str(similarity)])
        
%% Evaluate Backward

    [IUyMNI,IUxMNI,IUzMNI] = ind2sub(size(MNI),find(MNI == 1));
    [IUy,IUx,IUz] = ind2sub(size(suborg),find(suborg == 1));

    bxapply = [max(min([IUxMNI;IUx])-2,1)...
     min(max([IUxMNI;IUx])+2,256)...
        max(min([IUyMNI;IUy])-2,1)...
     min(max([IUyMNI;IUy])+2,256)...
        max(min([IUzMNI;IUz])-2,1)...
     min(max([IUzMNI;IUz])+2,256)]; % kuoda bounding box

    % backward warp
     IMBBX = suborg((bxapply(3)):(bxapply(4))...
        ,(bxapply(1)):(bxapply(2)),(bxapply(5)):(bxapply(6)));
     def{1} = DISP_Bwd{2}((bxapply(3)):(bxapply(4))...
         ,(bxapply(1)):(bxapply(2)),(bxapply(5)):(bxapply(6)));
     def{2} = DISP_Bwd{1}((bxapply(3)):(bxapply(4))...
         ,(bxapply(1)):(bxapply(2)),(bxapply(5)):(bxapply(6)));
     def{3} = DISP_Bwd{3}((bxapply(3)):(bxapply(4))...
         ,(bxapply(1)):(bxapply(2)),(bxapply(5)):(bxapply(6)));
     IMresult = deformation(IMBBX,def,'nearest');
     IFBBX = MNI((bxapply(3)):(bxapply(4))...
        ,(bxapply(1)):(bxapply(2)),(bxapply(5)):(bxapply(6)));
    
           similarity = 2*nnz(IMresult&IFBBX)/(nnz(IMresult) + nnz(IFBBX));

        disp('------------Results---------------')
        disp(['Region-',region,' MNI&Deformed SUB, DICE=',num2str(similarity)])
        
    
    %% Displacement field save

mkdir([Outdir,'/mat'])
save([Outdir,'/mat/',hm,'-DISP_Fwd_',num2str(regioninput),'.mat'],'DISP_Fwd')
save([Outdir,'/mat/',hm,'-DISP_Bwd_',num2str(regioninput),'.mat'],'DISP_Bwd')

    end


