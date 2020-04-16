function Apply2region_savedisp(SUB,regioninput,projectdir)

% SUB = 'P00005982';
% regioninput = 1032;
% projectdir='/share/projects/razlighi_lab/users/hengda/RDIR_v2';

addpath([projectdir,'/segframe-master/thirdparty/nifti'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions_nonrigid'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions_affine'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions'])

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
	    MNIst = load_untouch_nii([datadir,'aparc+aseg_',region,'_MNI.nii.gz']);
    MNI = double(MNIst.img);

    disp([datadir,'aparc+aseg_',region,'_Gaffine.nii'])
    subst = load_untouch_nii([datadir,'aparc+aseg_',region,'_Gaffine.nii.gz']);
    sub = double(subst.img);
    
    disp([datadir,'aparc+aseg_',region,'.nii'])
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

    %% transform displacement fields
    field = cell(3,1);
    field_back = cell(3,1);
    for d = 1:3
        field{d} = zeros(size(sub));
        field_back{d} = zeros(size(sub));
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
    
    % affine trans
    displacement = load([projectdir,'/Subject/',SUB,'/displacement.mat']);
    displacement = displacement.displacement;
    % to original space
    for d = 1:3
        DISP_Fwd{d} = movepixels(compdist{d},displacement{1},displacement{2},displacement{3});
        DISP_Fwd{d} = DISP_Fwd{d}+displacement{d};
    end
    
    %% Evaluation
    
    [gridFixedimage{1} gridFixedimage{2} gridFixedimage{3}] = meshgrid(1:256,1:256,1:256);
    for d = 1:3
        gridFixedimage{d} = permute(gridFixedimage{d},[2 1 3]);
    end
    for d = 1:3
        gridMovingimage{d} = gridFixedimage{d} + DISP_Fwd{d};
    end    

    IMBBX = suborg;
       
        interpolant = scatteredInterpolant(reshape(gridMovingimage{2},numel(IMBBX),1),...
            reshape(gridMovingimage{1},numel(IMBBX),1), reshape(gridMovingimage{3},numel(IMBBX),1)...
            , reshape(IMBBX,numel(IMBBX),1), 'nearest');

        vals = interpolant(reshape(gridFixedimage{2},numel(IMBBX),1),...
            reshape(gridFixedimage{1},numel(IMBBX),1), reshape(gridFixedimage{3},numel(IMBBX),1));
        IMresult = reshape(vals,size(IMBBX));
     
        IFBBX = MNI; 
           similarity = 2*nnz(IMresult&IFBBX)/(nnz(IMresult) + nnz(IFBBX));

        disp('------------Results---------------')
        disp([' IF&Deformed IM, DICE=',num2str(similarity)])
    
    %% Displacement field save
    end


