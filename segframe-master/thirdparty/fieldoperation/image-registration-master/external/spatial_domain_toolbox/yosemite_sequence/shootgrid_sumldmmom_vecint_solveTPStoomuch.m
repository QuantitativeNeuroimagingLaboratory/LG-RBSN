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

function [grid1 gridt] = shootgrid_sumldmmom_vecintxxxx(grid0,ldmdisp,lddmmoptions,varargin) % rhott displacement

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
% % for movies
% selectscale = -1;
% if size(varargin,2) > 1
%     selectscale = varargin{2};
% end
function dgrid = G_hd(tt,grid) % slooow version % dgrid is interpolated velocity vector fields -> yes derivative of displacement
    t = intTime(tt,backwards,lddmmoptions);  
    grid = reshape(grid,3,Ngriddur);
    dgrid = zeros(size(grid));

    rhot = [];
    dhot = [];
    for i = 1:length(ldmdisp)
        [rhott dhott] = deval(ldmdisp{i},t);
        rhott = rhott(1:length(rhott)-48);
        dhott = dhott(1:length(dhott)-48);
        rhot = [rhot;rhott];
        dhot = [dhot;dhott];
    end
    clear dhott; clear rhott
    rhot = [rhot;[16,16,240,0,0,0,16,16,16,0,0,0,16,240,16,0,0,0,16,240,240,0,0,0,240,16,240,0,0,0,240,16,16,0,0,0,240,240,16,0,0,0,240,240,240,0,0,0]'];
    dhot = [dhot;zeros(48,1)];
        
    points = [];
    vec = [];
    for i = 1:6:length(rhot)
        points = [points;rhot(i:(i+2))];
        vec = [vec;dhot(i:(i+2))];
    end
    clear dhot; clear rhot
    num = length(points)/3;
    points = reshape(points,3,num)';
    vec = reshape(vec,3,num)';
    
    [pointsuni idx]= unique(points,'rows');
    clear pointsuni;
    notin = setdiff(1:length(points),idx);
    clear idx
    points(notin,:) = [];
    vec(notin,:) = []; 
    num = length(points);
   
    px = repmat(points(:,1),1,num);
    py = repmat(points(:,2),1,num);
    pz = repmat(points(:,3),1,num);

    distance = sqrt((px-px').^2 + (py-py').^2 + (pz-pz').^2);
    clear px; clear py; clear pz;
    [Kor]=radialBasis(distance);
    clear distance
    lambda = 0;
    K = Kor + lambda*eye(num);
    clear Kor
    P = [ones(num,1) points(:,1) points(:,2) points(:,3)];
    Lmat = [K P; P' zeros(4,4)];
    clear K
    Y = [vec(:,1) vec(:,2) vec(:,3); zeros(4,3)];

    w1 = Y(:,1)'/Lmat;
    w2 = Y(:,2)'/Lmat;
    w3 = Y(:,3)'/Lmat;
    clear Lmat; clear P; clear vec; clear Y
    W = [w1;w2;w3]';
    clear w1; clear w2; clear w3
       
%        Ngriddur = length(grid);
       tran_K = (repmat(points(:,1),1,Ngriddur)-repmat(grid(1,:),num,1)).^2;
       tran_K = tran_K + (repmat(points(:,2),1,Ngriddur)-repmat(grid(2,:),num,1)).^2;
       tran_K = tran_K + (repmat(points(:,3),1,Ngriddur)-repmat(grid(3,:),num,1)).^2;
       tran_K = sqrt(tran_K);
       tran_P = [ones(Ngriddur,1) grid(1,:)' grid(2,:)' grid(3,:)']';

        tran_L = [tran_K;tran_P]';
        tran_X  = tran_L*W(:,1);
        tran_Y  = tran_L*W(:,2);
        tran_Z  = tran_L*W(:,3);
        
             dgrid(1,:) = tran_X;
            dgrid(2,:) = tran_Y;
            dgrid(3,:) = tran_Z;        

    dgrid = reshape(dgrid,3*Ngriddur,1);  
    
    dgrid = intResult(dgrid,backwards,lddmmoptions);
    
    dgrid = reshape(dgrid,3*Ngriddur,1);    
end


siz = size(grid0{1});
tspan = [0 1];
grid0x = reshape(grid0{1},1,Ngrid);
grid0y = reshape(grid0{2},1,Ngrid);
grid0z = reshape(grid0{3},1,Ngrid);

g1 = zeros([1,siz]);


    idur = 1:200000:length(grid0x);
    for i = 1:length(idur)
        
       if i == length(idur)
           
           Ngriddur = length(grid0x) - idur(i) + 1;
           g0 = reshape([grid0x(idur(i):end); grid0y(idur(i):end); grid0z(idur(i):end)],3*Ngriddur,1);
           disp(['Solving ',num2str(idur(i)),'-',num2str(length(grid0x))])
           
       else
           Ngriddur = idur(i+1) - idur(i);
           g0 = reshape([grid0x(idur(i):(idur(i+1)-1)); grid0y(idur(i):(idur(i+1)-1)); grid0z(idur(i):(idur(i+1)-1))],3*Ngriddur,1);
           disp(['Solving ',num2str(idur(i)),'-',num2str(idur(i+1)-1)])
       end
       
%        Ngriddur = length(g0);
       
        gridt = ode45(@G_hd,tspan,g0);

              if i == length(idur)
             g1(1:3,idur(i):end) = reshape(deval(gridt,tend),3,Ngriddur);      
       else
             g1(1:3,idur(i):(idur(i+1)-1)) = reshape(deval(gridt,tend),3,Ngriddur);
              end
       
    end

    
grid1 = cell(1);
        
grid1{1} = reshape(g1(1,:),siz);
grid1{2} = reshape(g1(2,:),siz);
grid1{3} = reshape(g1(3,:),siz);



end