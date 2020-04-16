
function regionLDDMM_trans(Outdir,region,kernelsize,weight,hm)

% LDDMM options
clear lddmmoptions
%region=1032;
lddmmoptions.energyweight = [1 weight]; % weighting between energy of curve and match
lddmmoptions.energyweight = lddmmoptions.energyweight/sum(lddmmoptions.energyweight);

% scale, Gaussian kernels
lddmmoptions.scales = [kernelsize];  

% sparsity
lddmmoptions.sparsity = false;
lddmmoptions.sparseoptions.alpha = 0;

% output options
clear visoptions
visoptions.dim = 3;

datadir = [Outdir,'/region',num2str(region),'/'];
% resultdir = ['./tests/data/region',num2str(region),'/'];
% moving points

%% fixiation
% % moving
% [regionsub hdr] = rest_ReadNiftiImage([datadir,'aparc+aseg_1033_Affine.nii.gz']);
% [region1033MNI hdr] = rest_ReadNiftiImage([datadir,'aparc+aseg_1033_MNI.nii.gz']);
% I_UNION = region1033|region1033MNI;
% [x,y,z] = ind2sub(size(I_UNION),find(I_UNION ~= 0));
fixldm = [];
fixldmmni = [];
% % z
% for i = linspace(min(z),max(z),10)
%     fixldm = [fixldm,[16 240 i]',[16 16 i]',[240 16 i]',[240 240 i]'];
% fixldmmni = [fixldmmni,[16 240 i]',[16 16 i]',[240 16 i]',[240 240 i]'];
% end
% % y
% for i = linspace(min(y),max(y),10)
%     fixldm = [fixldm,[16 i 240]',[16 i 16]',[240 i 16]',[240 i 240]'];
% fixldmmni = [fixldmmni,[16 i 240]',[16 i 16]',[240 i 16]',[240 i 240]'];
% end
% % x
% for i = linspace(min(x),max(x),10)
%     fixldm = [fixldm,[i 16 240]',[i 16 16]',[i 240 16]',[i 240 240]'];
% fixldmmni = [fixldmmni,[i 16 240]',[i 16 16]',[i 240 16]',[i 240 240]'];
% end
fixldm = [fixldm,[16 16 240]',[16 16 16]',[16 240 16]',[16 240 240]'];
fixldm = [fixldm,[240 16 240]',[240 16 16]',[240 240 16]',[240 240 240]'];
% % scatter()
% clear region1033
% clear region1033MNI

% MNI

fixldmmni = [fixldmmni,[16 16 240]',[16 16 16]',[16 240 16]',[16 240 240]'];
fixldmmni = [fixldmmni,[240 16 240]',[240 16 16]',[240 240 16]',[240 240 240]'];

%% Landmarks

regionstr = num2str(region);
MNIldm = textread([datadir,'brain-',hm,'-',regionstr(2:end),'-MNI-VOX-ds.label']);
sourceldm = textread([datadir,'brain-',hm,'-',regionstr(2:end),'-VOX-localtrans.label']);
disp(['Reading -> ',datadir,'brain-',hm,'-',regionstr(2:end),'-MNI-VOX-ds.label'])
disp(['Reading -> ',datadir,'brain-',hm,'-',regionstr(2:end),'-VOX-localtrans.label'])
fixed = MNIldm(:,1:3)';
moving = sourceldm(:,1:3)';
moving = [moving,fixldm];
fixed = [fixed,fixldmmni];

%% lddmm

options = getDefaultOptions();

[methods lddmmoptions] = setupPointLDDMM(moving,fixed,[],lddmmoptions);

result = runRegister(methods, options);

%% save results

save([Outdir,'/region',num2str(region),'/LDDMMtransform',num2str(kernelsize),'_w',num2str(weight),'_trans.mat'])

end
