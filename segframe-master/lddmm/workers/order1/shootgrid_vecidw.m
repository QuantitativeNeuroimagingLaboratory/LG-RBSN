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

function [grid1] = shootgrid_vecidw(grid0,ldmdisp,lddmmoptions,varargin) % rhott displacement

dim = lddmmoptions.dim;
cdim = lddmmoptions.cdim;
L = lddmmoptions.L;
R = lddmmoptions.R;
CSP = lddmmoptions.CSP;
scales = lddmmoptions.scales;
scaleweight = lddmmoptions.scaleweight;

[Ks D1Ks D2Ks] = gaussianKernels();

Ngrid = numel(grid0{1});

backwards = false;
if size(varargin,2) > 0
    backwards = varargin{1};
end
tend = 1;
if size(varargin,2) > 1
    tend = varargin{2};
end

function dgrid = G_hd(tt,gridt) % slooow version % dgrid is interpolated velocity vector fields -> yes derivative of displacement
    t = intTime(tt,backwards,lddmmoptions);  
    disp(['time-',num2str(t)])
%     grid = reshape(grid,3,Ngriddur);
    dgrid = zeros(3,Ngrid);

    regN = length(ldmdisp);
    rhot = cell(regN,1);
    dhot = cell(regN,1);
    dgridi = cell(regN,1);
    for i = 1:length(ldmdisp)
        [rhot{i} dhot{i}] = deval(ldmdisp{i},t);
        dgridi{i} = fastPointTransportOrder0(t,gridt,rhot{i},length(rhot{i})/6,R,cdim,scales.^2,scaleweight.^2); 
        dgridi{i} = reshape(dgridi{i},3,Ngrid);
%         dgrididisp{i} = dgridi{i};
    end
    
    % working together, individual dist weigth mask
    gridt = reshape(gridt,3,Ngrid);
    displacementregionmaskdist = cell(length(regN),1);
    for i = 1:length(ldmdisp)
        rhot{i} = rhot{i}(1:(length(rhot{i})-48));
        dhot{i} = dhot{i}(1:(length(dhot{i})-48));
        points = [];
        for p = 1:6:length(rhot{i})
            points = [points;rhot{i}(p:(p+2))];
        end
        points = reshape(points,3,length(points)/3);
        regionx = points(1,:)';
        regiony = points(2,:)';
        regionz = points(3,:)';
        maskx = gridt(1,:)';
        masky = gridt(2,:)';
        maskz = gridt(3,:)';
        r = diff(fix(linspace(0,length(masky),partitionrate+1))); % qie cheng shi duan
        masky_cut = mat2cell(masky,r,1);
        maskx_cut = mat2cell(maskx,r,1);
        maskz_cut = mat2cell(maskz,r,1);
        displacementregionmaskdist{i} = [];
            
        for k = 1:length(masky_cut)
            distancematrix = pdist2([masky_cut{k},maskx_cut{k},maskz_cut{k}],[regiony,regionx,regionz]);
            distancematrixmin = min(distancematrix,[],2); % should have no zeros
            distancematrixmin = distancematrixmin';
            displacementregionmaskdist{i} = [displacementregionmaskdist{i} 1./distancematrixmin.^distpower];
        end    

    end  
    
    displacementregionmaskdistsum = zeros(1,length(displacementregionmaskdist{1}));
    for i = 1:length(ldmdisp)
        displacementregionmaskdistsum = displacementregionmaskdistsum + displacementregionmaskdist{i};
    end 
    
    for i = 1:length(ldmdisp)
        displacementregionmaskdist{i} = displacementregionmaskdist{i}./displacementregionmaskdistsum;
    end 
    
    for i = 1:length(ldmdisp)
        dgrid = dgrid + dgridi{i}.*repmat(displacementregionmaskdist{i},3,1);
    end 
    
    dgrid = reshape(dgrid,3*Ngrid,1);
    
%     pause
%     
    
    
%     points = [];
%     vec = [];
%     for i = 1:6:length(rhot)
%         points = [points;rhot(i:(i+2))];
%         vec = [vec;dhot(i:(i+2))];
%     end
%     clear dhot; clear rhot
%     num = length(points)/3;
%     points = reshape(points,3,num)';
%     vec = reshape(vec,3,num)';
  
%              dgrid(1,:) = tran_X;
%             dgrid(2,:) = tran_Y;
%             dgrid(3,:) = tran_Z;   
%             clear tran_X; clear tran_Y; clear tran_Z;
    
%     dgrid = intResult(dgrid,backwards,lddmmoptions);
    
%     dgrid = reshape(dgrid,3*Ngriddur,1);    
end


siz = size(grid0{1});
partitionrate = 80;
distpower = 4;
g0 = reshape([reshape(grid0{1},1,Ngrid); reshape(grid0{2},1,Ngrid); reshape(grid0{3},1,Ngrid)],3*Ngrid,1);
gridt = ode45(@G_hd,[0 tend],g0);
g1 = reshape(deval(gridt,tend),3,Ngrid);

    
grid1 = cell(1);
        
grid1{1} = reshape(g1(1,:),siz);
grid1{2} = reshape(g1(2,:),siz);
grid1{3} = reshape(g1(3,:),siz);



end