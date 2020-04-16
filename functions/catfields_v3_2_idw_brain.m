% Forward Displacement
% use idw function for interpolation of displacement
% with transaction area

% clear all; close all; clc


function catfields_v3_2_idw_brain(projectdir,SUB)

addpath([projectdir,'/segframe-master/thirdparty/nifti'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions_affine'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions_nonrigid'])
addpath(genpath([projectdir,'/segframe-master/thirdparty/fieldoperation/image-registration-master']))

distpower = 4;

partitionrate = 10000;

imagedir = [projectdir,'/Workspace_',SUB];

regioninput = [1001,1002,1003,1005,1006,1007,1008,1009,1010,1011,1012,...
        1013,1014,1015,1016,1017,1018,1019,1020,1021,1022,1023,1024,...
        1025,1026,1027,1028,1029,1030,1031,1032,1033,1034,1035,...
        2001,2002,2003,2005,2006,2007,2008,2009,2010,2011,2012,...
            2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,...
            2025,2026,2027,2028,2029,2030,2031,2032,2033,2034,2035];
    
%% load files
subimage = cell(length(regioninput),1);
MNIimage = cell(length(regioninput),1);
displacement = cell(length(regioninput),3);

for i = 1:length(regioninput)

    region = num2str(regioninput(i));
    datadir = [imagedir,'/region',region,'/'];
    % NIFTI Images
    disp('Load NIFTI Images')
    disp([datadir,'aparc+aseg_',region,'_MNI.nii'])
    MNIst = load_untouch_nii([datadir,'aparc+aseg_',region,'_MNI.nii.gz']);
    MNI = MNIst.img;
    MNI = double(MNI);
    MNIimage{i} = MNI;

    disp([datadir,'aparc+aseg_',region,'.nii'])
    subst = load_untouch_nii([datadir,'aparc+aseg_',region,'.nii.gz']);
    sub = subst.img;
    sub = double(sub);
    subimage{i} = sub;
    
    % transformation 
    disp('Load Deformation Files')
    
    if round(regioninput(i)/1000) == 1
        hmreg = 'lh';
    else 
        hmreg = 'rh';
    end
    
    DISPObj = load([imagedir,'/mat/',hmreg,'-DISP_Fwd_',region,'.mat']);
    for d = 1:3
        displacement{i,d} = DISPObj.DISP_Fwd{d};
%         displacement{i,d} = permute(displacement{i,d},[2 1 3]);
    end
    
end
%% regional displacement linear+nonlinear addup

   suball = zeros(256,256,256);
   MNIall = zeros(256,256,256);
   for i = 1:length(regioninput)
       suball = suball+subimage{i};
       MNIall = MNIall+MNIimage{i};
   end
   suball_bin = suball;
   suball_bin(find(suball_bin~=0)) = 1;
   MNIall_bin = MNIall;
   MNIall_bin(find(MNIall_bin~=0)) = 1;

   clear MNIimage
%% dilation to find transaction area

    suball_dilasum = zeros(256,256,256);
    [xse,yse,zse] = ndgrid(-2:2);
    se = strel(sqrt(xse.^2 + yse.^2 + zse.^2) <=2); 
    
    for i = 1:length(regioninput)
        subimg_bin = subimage{i};
        subimg_bin(find(subimg_bin)) = 1;
        subimg_bin = imdilate(subimg_bin,se);
        suball_dilasum = suball_dilasum + subimg_bin;
    end
    transac = suball_dilasum;
    transac(find(transac<=1)) = 0;
    transac(find(transac>1)) = 1;
    
    % cut sub image and sum up suball with transaction
    
    suball_wtran = zeros(256,256,256);
    subimage_cut = cell(length(regioninput),1);
    for i = 1:length(regioninput)
        subimg_bin = subimage{i};
        subimg_bin(find(subimg_bin)) = 1;
        subimg_bin = subimg_bin - transac;
        subimg_bin(find(subimg_bin<1)) = 0;
        subimage_cut{i} = subimg_bin;
        suball_wtran = suball_wtran + subimg_bin;
    end
            
            clear subimage
% suball_wtran -> binary sum of cut sub img
% subimage_cut -> binary cut sub img
% visual 140 slice
%    
mkdir([projectdir,'/Subject/',SUB])
diary([projectdir,'/Subject/',SUB,'/IDW_Vq_log.txt'])
   %% idw
displacementregionmaskdist = cell(length(regioninput),1);
   for i = 1:length(regioninput)
       disp(['Mask for Region - ',num2str(regioninput(i))])
       submask = subimage_cut{i};    
      
       [regiony,regionx,regionz] = ind2sub(size(submask),find(submask)); 
       imgsize = size(submask);

       chosensubmask = ones(imgsize);     
       chosensubmask = chosensubmask - suball_wtran; % subtract regions -> get background and trascation
           
       [masky,maskx,maskz] = ind2sub(size(chosensubmask),find(chosensubmask)); 
       r = diff(fix(linspace(0,length(masky),partitionrate+1))); % cut 
       masky_cut = mat2cell(masky,r,1);
       maskx_cut = mat2cell(maskx,r,1);
       maskz_cut = mat2cell(maskz,r,1);
            
       displacementregionmaskdist{i} = zeros(size(chosensubmask));
        for k = 1:length(masky_cut)
            distancematrix = pdist2([masky_cut{k},maskx_cut{k},maskz_cut{k}],[regiony,regionx,regionz]);
            distancematrixmin = min(distancematrix,[],2); % should have no zeros

            for t = 1:length(masky_cut{k})
                    % distance calculation for each region inside the regional
                    % mask
                    % c_i distance function
                    % 1/distance^2
                displacementregionmaskdist{i}(masky_cut{k}(t),maskx_cut{k}(t),maskz_cut{k}(t)) = 1/distancematrixmin(t)^distpower;
            end
        end
   end

   %% sum up image and field

   Vq = cell(1,3);
   weightacc = cell(1,3);
   weightmap = cell(1,3);
   weightall = cell(length(regioninput),3);
       for d = 1:3
           Vq{d} = zeros(256,256,256);
           weightacc{d} = zeros(256,256,256);
           for i = 1:length(regioninput)
               weightacc{d} = weightacc{d} +  displacementregionmaskdist{i};
           end
           
           weightmap{d} = 1./weightacc{d};
           weightmap{d}(find(weightmap{d}==inf)) = 0;
           
           for i = 1:length(regioninput)
               
               submask = subimage_cut{i};
               submask(find(submask~=0)) = 1;
       
               weightall{i,d} = displacementregionmaskdist{i}.*weightmap{d}; % weight is dialted mask, taking only the needed region part of the overall weightmap (140,110,137) 
               weightall{i,d} = weightall{i,d} + submask;
               Vq{d} = Vq{d} +  displacement{i,d}.*weightall{i,d}; % tricky when multiply 1s, only apply to corresponded region

           end
       end
       

%% Determinant of Jacobian

jac = jacobian(Vq{1},Vq{2},Vq{3});

jacinmask = jac(find(suball_bin~=0));
numnonposjacinmask = length(find(jacinmask<=0));
disp([' #Non Positive Jac in cerebral cortex Mask = ',num2str(numnonposjacinmask)])

numnonposjac = length(find(jac<=0));

disp([' #Non Positive Jac = ',num2str(numnonposjac)])

jacnonpos = jac;

jacnonpos(find(jacnonpos<=0)) = -1;

jacnonpos(find(jacnonpos>0)) = 0;

jacnonpos(find(jacnonpos==-1)) = 1;

        
     IMBBX = MNIall_bin;
     def{1} = Vq{2};
     def{2} = Vq{1};
     def{3} = Vq{3};
     IMresult = deformation(IMBBX,def,'nearest');
     IFBBX = suball_bin;
     similarity = 2*nnz(IMresult&IFBBX)/(nnz(IMresult) + nnz(IFBBX));

     disp('------------Results---------------')
     disp(['SUB&Deformed MNI, DICE=',num2str(similarity)])
         diary off
     %% save
     
     save([projectdir,'/Subject/',SUB,'/Vq.mat'],'Vq')
     
    
end
     
     
