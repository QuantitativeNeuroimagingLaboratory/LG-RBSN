%
%  segframe, Copyright (C) 2009-2012, Stefan Sommer (sommer@diku.dk)
%  https://github.com/nefan/segframe.git
% 
%  This file is part of segframe.
% 
%  segframe is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
% 
%  segframe is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
% 
%  You should have received a copy of the GNU General Public License
%  along with segframe.  If not, see <http://www.gnu.org/licenses/>.
%  

function Apply2region_nodisplay_trans(Outdir,regioninput,kernelsize,weight)
%regioninput=1032;
region = num2str(regioninput);
datadir = [Outdir,'/region',region,'/'];
kernelscale = num2str(kernelsize);

%% Images
disp('Load NIFTI Images')

disp([datadir,'aparc+aseg_',region,'_MNI.nii'])
unix(['gzip -d ',datadir,'aparc+aseg_',region,'_MNI.nii.gz']);
[MNI MNIheader] = rest_ReadNiftiImage([datadir,'aparc+aseg_',region,'_MNI.nii']);
unix(['gzip ',datadir,'aparc+aseg_',region,'_MNI.nii']);

disp([datadir,'aparc+aseg_',region,'_trans.nii'])
unix(['gzip -d ',datadir,'aparc+aseg_',region,'_trans.nii.gz']);
[sub subheader] = rest_ReadNiftiImage([datadir,'aparc+aseg_',region,'_trans.nii']);
unix(['gzip ',datadir,'aparc+aseg_',region,'_trans.nii']);

%% lddmm
disp('Load LDDMM Results')
disp([datadir,'LDDMMtransform',kernelscale,'_w',num2str(weight),'_trans.mat'])
load([datadir,'LDDMMtransform',kernelscale,'_w',num2str(weight),'_trans.mat'])

%% Apply to image
IM = sub;
IF = MNI;

MNI(find(MNI~=0))=1;
sub(find(sub~=0))=1;

I_UNION = IM|IF;
[IUy,IUx,IUz] = ind2sub(size(I_UNION),find(I_UNION == 1));
boundingbox = [min(IUx) max(IUx) min(IUy) max(IUy) min(IUz) max(IUz)];

IMBBX = IM((min(IUy)-2):(max(IUy)+2)...
    ,(min(IUx)-2):(max(IUx)+2),(min(IUz)-2):(max(IUz)+2));

[gridFixedBBX{1} gridFixedBBX{2} gridFixedBBX{3}] = meshgrid((min(IUy)-2):(max(IUy)+2)...
    ,(min(IUx)-2):(max(IUx)+2),(min(IUz)-2):(max(IUz)+2));


%% transport

disp('obtain moving image result')
transport = methods.transport;
gridMovingBBX = transport(result,gridFixedBBX);

TransformedLDM = transport(result,moving);
MED = mean(sqrt(sum((TransformedLDM-fixed).^2))); %  mean Ec distance
MEDmax = max(sqrt(sum((TransformedLDM-fixed).^2))); %  mean Ec distance

%% Visualization


num3d = prod(size(gridMovingBBX{1}));
gridMovingBBXtrans{1} = permute(gridMovingBBX{1},[2 1 3]);
gridMovingBBXtrans{2} = permute(gridMovingBBX{2},[2 1 3]);
gridMovingBBXtrans{3} = permute(gridMovingBBX{3},[2 1 3]);
gridFixedBBXtrans{1} = permute(gridFixedBBX{1},[2 1 3]);
gridFixedBBXtrans{2} = permute(gridFixedBBX{2},[2 1 3]);
gridFixedBBXtrans{3} = permute(gridFixedBBX{3},[2 1 3]);

interpolant = scatteredInterpolant(reshape(gridMovingBBXtrans{2},numel(IMBBX),1),...
    reshape(gridMovingBBXtrans{1},numel(IMBBX),1), reshape(gridMovingBBXtrans{3},numel(IMBBX),1)...
    , reshape(IMBBX,numel(IMBBX),1), 'nearest');

vals = interpolant(reshape(gridFixedBBXtrans{2},numel(IMBBX),1),...
    reshape(gridFixedBBXtrans{1},numel(IMBBX),1), reshape(gridFixedBBXtrans{3},numel(IMBBX),1));
IMresult = reshape(vals,size(IMBBX));


IFBBX = IF((min(IUy)-2):(max(IUy)+2)...
    ,(min(IUx)-2):(max(IUx)+2),(min(IUz)-2):(max(IUz)+2));


similarity = 2*nnz(IMresult&IFBBX)/(nnz(IMresult) + nnz(IFBBX));

%similarityMNIman = 2*nnz(IMresult&MNImanBBX)/(nnz(IMresult) + nnz(MNImanBBX));

disp('------------Results---------------')
disp(['IF&Deformed IM, DICE=',num2str(similarity)])

tsimilarity = nnz(IMresult&IFBBX)/(nnz(IFBBX));
disp(['IF&Deformed IM, Target Overlap=',num2str(tsimilarity)])

disp(['Mean Euclidean Distance after Transformation: ',num2str(MED)])
disp(['Max Euclidean Distance after Transformation: ',num2str(MEDmax)])

IMdeformed = zeros(256,256,256);
for i = (min(IUy)-2):(max(IUy)+2)
    for j = (min(IUx)-2):(max(IUx)+2)
       for k = (min(IUz)-2):(max(IUz)+2)
            
           IMdeformed(i,j,k) = IMresult(i-min(IUy)+2+1,j-min(IUx)+2+1,k-min(IUz)+2+1);
        
       end
    end
end

IMdeformed(find(IMdeformed~=0)) = regioninput;

field1 = 'fname';  value1 = [datadir,'/aparc+aseg_',regionstr,'_deformed',kernelscale,'_trans.nii'];
field2 = 'mat';  value2 = [    -1     0     0   128
     0     0     1  -146
     0    -1     0   148
     0     0     0     1];
field3 = 'dim';  value3 = [256 256 256];
field4 = 'dt';  value4 = [16 0]; 
field5 = 'pinfo';  value5 = [1;0;352];
header = struct(field1,value1,field2,value2,field3,value3,field4,value4,...
    field5,value5);

rest_WriteNiftiImage(IMdeformed,header,[datadir,'/aparc+aseg_',regionstr,'_deformed',kernelscale,'_w',num2str(weight),'_trans.nii']);
unix(['gzip ',datadir,'aparc+aseg_',regionstr,'_deformed',kernelscale,'_w',num2str(weight),'_trans.nii']);

