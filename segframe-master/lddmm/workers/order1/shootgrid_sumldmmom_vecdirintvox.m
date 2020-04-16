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

function [grid1] = shootgrid_sumldmmom_vecdirintvox(grid0,ldmdisp,lddmmoptions,varargin) % rhott displacement

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
%     gridsize = size(grid);
    dgrid = zeros(size(grid));
    
    grid = reshape(grid,3,Ngriddur);
%     dgrid = zeros(size(grid));

    disp(['Time point - ',num2str(t)])
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
    
%     [pointsuni idx]= unique(points,'rows');
%     clear pointsuni;
%     notin = setdiff(1:length(points),idx);
%     clear idx
%     points(notin,:) = [];
%     vec(notin,:) = []; 
    
   % each voxel one landmark
    pointsrd = round(points);
    [pointsrduni idxrd]= unique(pointsrd,'rows');
    notinrd = setdiff(1:length(points),idxrd);
    points(notinrd,:) = [];
    vec(notinrd,:) = []; 
    
    points = round(points);
    
    num = length(points);
    for i = 1:num
        dgrid(points(i,1),points(i,2),points(i,3)) = vec
    end
    
   
  
             dgrid(1,:) = tran_X;
            dgrid(2,:) = tran_Y;
            dgrid(3,:) = tran_Z;   
            clear tran_X; clear tran_Y; clear tran_Z;

%     dgrid = reshape(dgrid,3*Ngriddur,1);  
    
    dgrid = intResult(dgrid,backwards,lddmmoptions);
    
    dgrid = reshape(dgrid,3*Ngriddur,1);    
end


siz = size(grid0{1});
tspan = [0 1];
grid0x = reshape(grid0{1},1,Ngrid);
grid0y = reshape(grid0{2},1,Ngrid);
grid0z = reshape(grid0{3},1,Ngrid);

g1 = zeros([3,prod(siz)]);


%     idur = 1:50000:length(grid0x);
    idur = 1;
    for j = 1:length(idur)
        
       if j == length(idur)
           
           Ngriddur = length(grid0x) - idur(j) + 1;
           g0 = reshape([grid0x(idur(j):end); grid0y(idur(j):end); grid0z(idur(j):end)],3*Ngriddur,1);
           disp(['Solving ',num2str(idur(j)),'-',num2str(length(grid0x))])
           
       else
           Ngriddur = idur(j+1) - idur(j);
           g0 = reshape([grid0x(idur(j):(idur(j+1)-1)); grid0y(idur(j):(idur(j+1)-1)); grid0z(idur(j):(idur(j+1)-1))],3*Ngriddur,1);
           disp(['Solving ',num2str(idur(j)),'-',num2str(idur(j+1)-1)])
       end
       
%        Ngriddur = length(g0);
       
        gridt = ode45(@G_hd,tspan,g0);

              if j == length(idur)
             g1(1:3,idur(j):end) = reshape(deval(gridt,tend),3,Ngriddur);      
       else
             g1(1:3,idur(j):(idur(j+1)-1)) = reshape(deval(gridt,tend),3,Ngriddur);
              end
       
    end

    
grid1 = cell(1);
        
grid1{1} = reshape(g1(1,:),siz);
grid1{2} = reshape(g1(2,:),siz);
grid1{3} = reshape(g1(3,:),siz);



end