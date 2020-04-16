function Apply2region_savedisp_backup(SUB,regioninput,projectdir)

addpath([projectdir,'/segframe-master/thirdparty/nifti'])
addpath([projectdir,'/segframe-master/thirdparty/functions_nonrigid'])
addpath([projectdir,'/segframe-master/thirdparty/functions_affine'])
addpath([projectdir,'/segframe-master/thirdparty/functions'])
%addpath('/home/hh2699/RDIR_LM/nifti')
%projectdir='/share/projects/razlighi_lab/users/hengda/RDIR_LM';

kernelsize = 4;
weight = 100;

Outdir = [projectdir,'/Workspace_',SUB];
kernelscale = num2str(kernelsize);

sub = zeros(256,256,256);
MNI = zeros(256,256,256);
trans = zeros(length(regioninput),3);

%% LOADING
    region = num2str(regioninput);
    datadir = [Outdir,'/region',region,'/'];
    
    if round(regioninput/1000)==1
        hm = 'lh';
    else if round(regioninput/1000)==2
            hm = 'rh';
        end
    end

    %% Images
    disp('Load NIFTI Images')

    % NIFTI Images
    disp('Load NIFTI Images')
    disp([datadir,'aparc+aseg_',region,'_MNI.nii'])
	    MNIst = load_untouch_nii([datadir,'aparc+aseg_',region,'_MNI.nii.gz']);
    MNI = MNIst.img;

    disp([datadir,'aparc+aseg_',region,'.nii'])
    subst = load_untouch_nii([datadir,'aparc+aseg_',region,'.nii.gz']);
    sub = subst.img;

    MNI(find(MNI~=0))=1;
    sub(find(sub~=0))=1;
     
    %% lddmm
    % Results
    disp('Load LDDMM Results')
    disp([datadir,'LDDMMtransform',kernelscale,'_w',num2str(weight),'_trans.mat'])
    LDDMMres = load([datadir,'LDDMMtransform',kernelscale,'_w',num2str(weight),'_trans.mat']);
    
    %% Ouver all bounding box

[IUyMNI,IUxMNI,IUzMNI] = ind2sub(size(MNI),find(MNI == 1));
[IUy,IUx,IUz] = ind2sub(size(sub),find(sub == 1));

    trans = textread([datadir,'trans-',region(2:end),'.txt']);
    
    IUyall = [];
IUxall = [];
IUzall = [];

for i = 1:length(regioninput)
    IUxall = [IUxall;(IUxMNI - trans(i,1))];
    IUyall = [IUyall;(IUyMNI - trans(i,2))];
    IUzall = [IUzall;(IUzMNI - trans(i,3))];
end

boundingbox = [max(min([IUxMNI;IUx + trans(i,1)])-12,3) ...
min(max([IUxMNI;IUx + trans(i,1)])+12,254)...
    max(min([IUyMNI;IUy+trans(i,2)])-12,3) ...
min(max([IUyMNI;IUy+trans(i,2)])+12,254)...
    max(min([IUzMNI;IUz+trans(i,3)])-12,3) ...
min(max([IUzMNI;IUz+trans(i,3)])+12,254)]; % kuoda bounding box
    
   %% Transformations
Displacement = cell(length(regioninput),3);

    [gridFixedBBX{1} gridFixedBBX{2} gridFixedBBX{3}] = meshgrid((boundingbox(3)-2):(boundingbox(4)+2)...
        ,(boundingbox(1)-2):(boundingbox(2)+2),(boundingbox(5)-2):(boundingbox(6)+2));

    %% transport 
    disp('obtain moving image result')
    transport = LDDMMres.methods.transport;

    var = true(1);
    [gridMovingBBXtransall_back rhott_back gridt_back] = transport(LDDMMres.result,gridFixedBBX,var);
    
    %% Displacement field save

mkdir([Outdir,'/mat'])
save([Outdir,'/mat/',hm,'-gridMovingBBXtransall_back_',num2str(regioninput),'.mat'],'gridMovingBBXtransall_back')


    end


