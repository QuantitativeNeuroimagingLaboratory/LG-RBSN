%  Demons with consistent regularization

function Demons_regularization(SUB,projectdir)

simiweight = 1;
sigma = 0.6;
iterations = 500;
weight2 = 3;
simiweight_sub = 1;
sigma_sub = 0.6;
simstep_sub = 0.1;

disp(['simiweight= ',num2str(simiweight),', sigma= ',num2str(sigma),', iterations= ',num2str(iterations),', weight2= ',num2str(weight2)])
disp(['simstep_sub= ',num2str(simstep_sub)])
% SUB = 'P00005982';

% load deformation fileds and images
load([projectdir,'/Subject/',SUB,'/Vq.mat']);
load([projectdir,'/Subject/',SUB,'/Vq_back.mat']);

% add path
addpath([projectdir,'/segframe-master/thirdparty/nifti'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions_affine'])
addpath([projectdir,'/segframe-master/thirdparty/fieldoperation/functions_nonrigid'])
addpath(genpath([projectdir,'/segframe-master/thirdparty/fieldoperation/image-registration-master']))

uip = Vq_back;
upi = Vq; 
clear Vq;
clear Vq_back;

suball_bin = load_untouch_nii([projectdir,'/subjects_FS/FreeSurfer_',SUB,'/mri/aparc+aseg.nii.gz']);
suball_bin = double(suball_bin.img);
suball_bin_sub = suball_bin;
suball_bin(suball_bin>2035) = 0;
suball_bin(suball_bin<1001) = 0;
suball_bin((suball_bin>1035)&(suball_bin<2001)) = 0;
suball_bin((suball_bin==1004)|(suball_bin==2004)) = 0;
suball = suball_bin;
suball_bin(suball_bin~=0) = 1;
suball_bin_sub(suball_bin==1) = 0;

MNIall_bin = load_untouch_nii([projectdir,'/subjects_FS/FreeSurferMNI152/mri/aparc+aseg.nii.gz']);
MNIall_bin = double(MNIall_bin.img);
MNIall_bin_sub = MNIall_bin;
MNIall_bin(MNIall_bin>2035) = 0;
MNIall_bin(MNIall_bin<1001) = 0;
MNIall_bin((MNIall_bin>1035)&(MNIall_bin<2001)) = 0;
MNIall_bin((MNIall_bin==1004)|(MNIall_bin==2004)) = 0;
MNIall = MNIall_bin;
MNIall_bin(MNIall_bin~=0) = 1;
MNIall_bin_sub(MNIall_bin==1) = 0;

MNIall_struct = load_untouch_nii([projectdir,'/subjects_FS/FreeSurferMNI152/mri/nu.nii.gz']);
MNIall_struct = double(MNIall_struct.img);


% Set static and moving image
S=MNIall_bin; M=suball_bin;
S_back=suball_bin; M_back=MNIall_bin;
I2 = S;
I1 = M;

% Set static and moving image for subcortical regions
MNI_sub = MNIall_bin_sub;
sub_sub = suball_bin_sub;
S_sub=MNI_sub; M_sub=sub_sub;
S_sub_back=sub_sub; M_sub_back=MNI_sub;
I2_sub = S_sub;
I1_sub = M_sub;

% Alpha (noise) constant
alpha=1;

% Velocity field smoothing kernel
% The transformation and reverse fields
Tx=uip{1}; Ty=uip{2};Tz=uip{3};
Tinvx=upi{1}; Tinvy=upi{2};Tinvz=upi{3};

[Sy,Sx,Sz] = gradient(S);
[Sy_back,Sx_back,Sz_back] = gradient(S_back);

subcorlist = [4,7,8,10,11,12,13,14,16,17,18,28,43,46,47,49,50,51,52,53,54,60,251,252,253,254,255];
subcornum = length(subcorlist);
Sy_sub = cell(subcornum,1);
Sx_sub = cell(subcornum,1);
Sz_sub  = cell(subcornum,1);
Sy_sub_back = cell(subcornum,1);
Sx_sub_back = cell(subcornum,1);
Sz_sub_back = cell(subcornum,1);
for i = 1:subcornum
    S_sub_reg = S_sub;
    S_sub_back_reg = S_sub_back;
    S_sub_reg(S_sub_reg~=subcorlist(i)) = 0;
    S_sub_reg(S_sub_reg~=0) = 1;
    S_sub_back_reg(S_sub_back_reg~=subcorlist(i)) = 0;
    S_sub_back_reg(S_sub_back_reg~=0) = 1;
    [Sy_sub{i},Sx_sub{i},Sz_sub{i}] = gradient(S_sub_reg);
    [Sy_sub_back{i},Sx_sub_back{i},Sz_sub_back{i}] = gradient(S_sub_back_reg);
end

%iterations = 500;
SSD = zeros(iterations,1);
similarity_M = zeros(iterations,1);
similarity_Mback = zeros(iterations,1);
similarity_sub_M = zeros(iterations,1);
similarity_sub_Mback = zeros(iterations,1);
% initial set up moving image
def{1} = Ty;
def{2} = Tx;
def{3} = Tz;
M = deformation(I1,def,'nearest');
M_sub = deformation(I1_sub,def,'nearest');
% backward initial set up moving image
def{1} = Tinvy;
def{2} = Tinvx;
def{3} = Tinvz;
M_back = deformation(I2,def,'nearest');
M_sub_back = deformation(I2_sub,def,'nearest');
stepsize = ones(iterations,1).*0.1;
simstep = 1; % NEED to keep 1
weight = [1 weight2];
weight = weight./sum(weight);

for itt=1:iterations
  
    %% similarity
	    
    % one way
        % Difference image between moving and static image
        Idiff=M-S;

        % Default demon force, (Thirion 1998)
        Ux = -(Idiff.*Sx)./((Sx.^2+Sy.^2+Sz.^2)+Idiff.^2);
        Uy = -(Idiff.*Sy)./((Sx.^2+Sy.^2+Sz.^2)+Idiff.^2);
        Uz = -(Idiff.*Sz)./((Sx.^2+Sy.^2+Sz.^2)+Idiff.^2);
        % Extended demon force. With forces from the gradients from both

        % When divided by zero
        Ux(isnan(Ux))=0; Uy(isnan(Uy))=0;Uz(isnan(Uz))=0;

        % Smooth the transformation field
        Uxs=simiweight*imgaussfilt3(Ux,sigma);
        Uys=simiweight*imgaussfilt3(Uy,sigma);
        Uzs=simiweight*imgaussfilt3(Uz,sigma);

        Uxs_sub = zeros(256,256,256);
        Uys_sub = zeros(256,256,256);
        Uzs_sub = zeros(256,256,256);
        for i = 1:subcornum
            S_sub_reg = S_sub;
            M_sub_reg = M_sub;
            S_sub_reg(S_sub_reg~=subcorlist(i)) = 0;
            S_sub_reg(S_sub_reg~=0) = 1;
            M_sub_reg(M_sub_reg~=subcorlist(i)) = 0;
            M_sub_reg(M_sub_reg~=0) = 1;
            Idiff_sub=M_sub_reg-S_sub_reg;
            % Default demon force, (Thirion 1998)
            Ux_sub = -(Idiff_sub.*Sx_sub{i})./((Sx_sub{i}.^2+Sy_sub{i}.^2+Sz_sub{i}.^2)+Idiff_sub.^2);
            Uy_sub = -(Idiff_sub.*Sy_sub{i})./((Sx_sub{i}.^2+Sy_sub{i}.^2+Sz_sub{i}.^2)+Idiff_sub.^2);
            Uz_sub = -(Idiff_sub.*Sz_sub{i})./((Sx_sub{i}.^2+Sy_sub{i}.^2+Sz_sub{i}.^2)+Idiff_sub.^2);
            % Extended demon force. With forces from the gradients from both

            % When divided by zero
            Ux_sub(isnan(Ux_sub))=0; Uy_sub(isnan(Uy_sub))=0;Uz_sub(isnan(Uz_sub))=0;

            % Smooth the transformation field
            Uxs_sub=Uxs_sub + simiweight_sub*imgaussfilt3(Ux_sub,sigma_sub);
            Uys_sub=Uys_sub + simiweight_sub*imgaussfilt3(Uy_sub,sigma_sub);
            Uzs_sub=Uzs_sub + simiweight_sub*imgaussfilt3(Uz_sub,sigma_sub);
        end

     % other way
        % Difference image between moving and static image
        Idiff_back=M_back-S_back;
      
        % Default demon force, (Thirion 1998)
        Ux = -(Idiff_back.*Sx_back)./((Sx_back.^2+Sy_back.^2+Sz_back.^2)+Idiff_back.^2);
        Uy = -(Idiff_back.*Sy_back)./((Sx_back.^2+Sy_back.^2+Sz_back.^2)+Idiff_back.^2);
        Uz = -(Idiff_back.*Sz_back)./((Sx_back.^2+Sy_back.^2+Sz_back.^2)+Idiff_back.^2);
        % Extended demon force. With forces from the gradients from both
        % When divided by zero
        Ux(isnan(Ux))=0; Uy(isnan(Uy))=0;Uz(isnan(Uz))=0;

        % Smooth the transformation field
        Uxs_back=simiweight*imgaussfilt3(Ux,sigma);
        Uys_back=simiweight*imgaussfilt3(Uy,sigma);
        Uzs_back=simiweight*imgaussfilt3(Uz,sigma);
       

        % Subcortical regions
        Uxs_sub_back = zeros(256,256,256);
        Uys_sub_back = zeros(256,256,256);
        Uzs_sub_back = zeros(256,256,256);
        for i = 1:subcornum
            S_sub_back_reg = S_sub_back;
            M_sub_back_reg = M_sub_back;
            S_sub_back_reg(S_sub_back_reg~=subcorlist(i)) = 0;
            S_sub_back_reg(S_sub_back_reg~=0) = 1;
            M_sub_back_reg(M_sub_back_reg~=subcorlist(i)) = 0;
            M_sub_back_reg(M_sub_back_reg~=0) = 1;
            Idiff_sub_back=M_sub_back_reg-S_sub_back_reg;
            % Default demon force, (Thirion 1998)
            Ux_sub = -(Idiff_sub_back.*Sx_sub_back{i})./((Sx_sub_back{i}.^2+Sy_sub_back{i}.^2+Sz_sub_back{i}.^2)+Idiff_sub_back.^2);
            Uy_sub = -(Idiff_sub_back.*Sy_sub_back{i})./((Sx_sub_back{i}.^2+Sy_sub_back{i}.^2+Sz_sub_back{i}.^2)+Idiff_sub_back.^2);
            Uz_sub = -(Idiff_sub_back.*Sz_sub_back{i})./((Sx_sub_back{i}.^2+Sy_sub_back{i}.^2+Sz_sub_back{i}.^2)+Idiff_sub_back.^2);
            % Extended demon force. With forces from the gradients from both

            % When divided by zero
            Ux_sub(isnan(Ux_sub))=0; Uy_sub(isnan(Uy_sub))=0;Uz_sub(isnan(Uz_sub))=0;

            % Smooth the transformation field
            Uxs_sub_back=Uxs_sub_back + simiweight_sub*imgaussfilt3(Ux_sub,sigma_sub);
            Uys_sub_back=Uys_sub_back + simiweight_sub*imgaussfilt3(Uy_sub,sigma_sub);
            Uzs_sub_back=Uzs_sub_back + simiweight_sub*imgaussfilt3(Uz_sub,sigma_sub);
        end

            ripx = movepixels(Tinvx,Tx,Ty,Tz);
            ripx = ripx+Tx;
            ripy = movepixels(Tinvy,Tx,Ty,Tz);
            ripy = ripy+Ty;
            ripz = movepixels(Tinvz,Tx,Ty,Tz);
            ripz = ripz+Tz;

% use forward backward residual
            rpix = movepixels(Tx,Tinvx,Tinvy,Tinvz);
            rpix = rpix+Tinvx;
            rpiy = movepixels(Ty,Tinvx,Tinvy,Tinvz);
            rpiy = rpiy+Tinvy;
            rpiz = movepixels(Tz,Tinvx,Tinvy,Tinvz);
            rpiz = rpiz+Tinvz;
            

      
      %% update
        
      % Add the new transformation field to the total transformation field.
        Tx=Tx+simstep*Uxs*weight(1) +simstep_sub*Uxs_sub*weight(1) - stepsize(itt).*ripx*weight(2);
        Ty=Ty+simstep*Uys*weight(1) +simstep_sub*Uys_sub*weight(1) - stepsize(itt).*ripy*weight(2);
        Tz=Tz+simstep*Uzs*weight(1) +simstep_sub*Uzs_sub*weight(1) - stepsize(itt).*ripz*weight(2);

            Tinvx =Tinvx+simstep*Uxs_back*weight(1) +simstep_sub*Uxs_sub_back*weight(1) - stepsize(itt).*rpix*weight(2);
            Tinvy =Tinvy+simstep*Uys_back*weight(1) +simstep_sub*Uys_sub_back*weight(1) - stepsize(itt).*rpiy*weight(2);
            Tinvz =Tinvz+simstep*Uzs_back*weight(1) +simstep_sub*Uzs_sub_back*weight(1) - stepsize(itt).*rpiz*weight(2);
        
        %% evaluation
        
        SSD(itt) = sum(sum(sum(Idiff.*Idiff)))+sum(sum(sum(Idiff_back.*Idiff_back)));
        disp([num2str(itt/2),'% - E=',num2str(SSD(itt))])
          
            jet = jacobian(Tx,Ty,Tz);
            jet_back(itt) = length(find(jet<0));
            disp(['it-',num2str(itt),' backward_bi # of non-positive Jac = ',num2str(jet_back(itt))])

            jet = jacobian(Tinvx,Tinvy,Tinvz);
            jet_for(itt) = length(find(jet<0));
            disp(['it-',num2str(itt),' foreward_bi # of non-positive Jac = ',num2str(jet_for(itt))])

            
            def{1} = Ty;
            def{2} = Tx;
            def{3} = Tz;
            submask_def = deformation(suball_bin,def,'nearest');
            M = submask_def;
            M_sub = deformation(sub_sub,def,'linear');
            similarity_M(itt) = 2*nnz(submask_def&MNIall_bin)/(nnz(submask_def) + nnz(MNIall_bin));
            disp(['it-',num2str(itt),' MNI&Deformed sub, DICE=',num2str(similarity_M(itt))])
            
            %
            def{1} = Tinvy;
            def{2} = Tinvx;
            def{3} = Tinvz;
            M_back = deformation(MNIall_bin,def,'nearest');
            M_sub_back = deformation(MNI_sub,def,'linear');
            similarity_Mback(itt) = 2*nnz(M_back&suball_bin)/(nnz(M_back) + nnz(suball_bin));
            disp(['it-',num2str(itt),' sub&Deformed MNI, DICE=',num2str(similarity_Mback(itt))])

            % subcortical
            def{1} = Ty;
            def{2} = Tx;
            def{3} = Tz;
            M_sub = deformation(sub_sub,def,'nearest');
            similarity_sub_M(itt) = 0;
            for i = 1:subcornum
                MNI_sub_reg = MNI_sub;
                M_sub_reg = M_sub;
                MNI_sub_reg(MNI_sub_reg~=subcorlist(i)) = 0;
                MNI_sub_reg(MNI_sub_reg~=0) = 1;
                M_sub_reg(M_sub_reg~=subcorlist(i)) = 0;
                M_sub_reg(M_sub_reg~=0) = 1;
                similarity_sub_M(itt) = similarity_sub_M(itt) + 2*nnz(M_sub_reg&MNI_sub_reg)/(nnz(M_sub_reg) + nnz(MNI_sub_reg));
            end
            similarity_sub_M(itt) = similarity_sub_M(itt)/subcornum;
            disp(['it-',num2str(itt),'Subcortical MNI&Deformed sub, DICE=',num2str(similarity_sub_M(itt))])
            
            %
            def{1} = Tinvy;
            def{2} = Tinvx;
            def{3} = Tinvz;
            M_sub_back = deformation(MNI_sub,def,'nearest');
            similarity_sub_M_back(itt) = 0;
            for i = 1:subcornum
                sub_sub_reg = sub_sub;
                M_sub_back_reg = M_sub_back;
                sub_sub_reg(sub_sub_reg~=subcorlist(i)) = 0;
                sub_sub_reg(sub_sub_reg~=0) = 1;
                M_sub_back_reg(M_sub_back_reg~=subcorlist(i)) = 0;
                M_sub_back_reg(M_sub_back_reg~=0) = 1;
                similarity_sub_M_back(itt) = similarity_sub_M_back(itt) + 2*nnz(M_sub_back_reg&sub_sub_reg)/(nnz(M_sub_back_reg) + nnz(sub_sub_reg));
            end
            similarity_sub_M_back(itt) = similarity_sub_M_back(itt)/subcornum;
            disp(['it-',num2str(itt),'Subcortical sub&Deformed MNI, DICE=',num2str(similarity_sub_M_back(itt))])

end

	% output
save([projectdir,'/Subject/',SUB,'/Deformations_withsubreg.mat'],'Tx','Ty','Tz','Tinvx','Tinvy','Tinvz')

    
add = 0;
	for region = [1001:1003,1005:1035,2001:2003,2005:2035]

		MNIallregion = MNIall;
		MNIallregion(MNIallregion~=region) = 0;
		MNIallregion(MNIallregion==region) = 1;
		MNIallregion_def = deformation(MNIallregion,def,'nearest');

		suballregion = suball;
		suballregion(suballregion~=region) = 0;
		suballregion(suballregion==region) = 1;

		similarity = 2*nnz(suballregion&MNIallregion_def)/(nnz(suballregion) + nnz(MNIallregion_def));
        add = add + similarity;
        
		disp(['Reg-',num2str(region),' Sub&MNI_def, DICE=',num2str(similarity)])

    end
disp(['FS Seg, Average = ',num2str(mean(add/68))])
    

end

