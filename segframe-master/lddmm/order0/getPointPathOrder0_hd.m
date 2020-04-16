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

function pointPath_hd = getPointPathOrder0_hd(moving,lddmmoptions)

dim = lddmmoptions.dim;
cdim = lddmmoptions.cdim; % computations performed in cdim
L = lddmmoptions.L;
R = lddmmoptions.R;
cCSP = lddmmoptions.cCSP;
scales = lddmmoptions.scales;
scaleweight = lddmmoptions.scaleweight;

[Ks D1Ks D2Ks] = gaussianKernels();

    function drho = Gc(tt,rhot) % wrapper for C version
        t = intTime(tt,false,lddmmoptions);
        
        drho = fastPointPathOrder0(t,rhot,L,R,cdim,scales.^2,scaleweight.^2);
        
        drho = intResult(drho,false,lddmmoptions);

        % debug
        if getOption(lddmmoptions,'testC')
            drho2 = G(tt,rhot);
            if norm(drho-drho2) > 10e-12
                1;
            end
            assert(norm(drho-drho2) < 10e-12);
        end
    end

    function drho = G(tt,rhot)  % slooow version
        rhot = reshape(rhot,cCSP,L);
        t = intTime(tt,false,lddmmoptions);

        drho = zeros(size(rhot));

        for i = 1:L % particle
            xi = rhot(1:cdim,i);

            for l = 1:L % particle
                xl = rhot(1:cdim,l);

                ximxl = xi-xl;

                for sl = 1:R % scale
                    d1ksl = D1Ks(xi,xl,scales(sl),scaleweight(sl));
                    TWOd1kslximxl = 2*d1ksl*ximxl;

                    % position
                    drho(1:cdim,i) = drho(1:cdim,i)+Ks(xi,xl,scales(sl),scaleweight(sl))*rhot(cdim*(sl-1)+(1+cdim:2*cdim),l);

                    for si = 1:R % scale
                        % momentum
                        drho(cdim*(si-1)+(1+cdim:2*cdim),i) = drho(cdim*(si-1)+(1+cdim:2*cdim),i) ...
                            - TWOd1kslximxl*rhot(cdim*(sl-1)+(1+cdim:2*cdim),l)'*rhot(cdim*(si-1)+(1+cdim:2*cdim),i);
                    end                
                end
            end
        end

        drho = intResult(drho,false,lddmmoptions);
        drho = reshape(drho,L*cCSP,1);
    end

    function [rhot] = pointPathOrder0_hd(x,varargin)
        tend = 1;
        if size(varargin,2) > 0
            tend = varargin{1};
        end
        if dim == cdim
            rho0 = [moving; reshape(x,dim*R,L)];
        else
            assert(dim == 2 && cdim == 3); % shift from 2d to 3d
            rho0 = zeros(cdim+R*cdim,L);
            rho0(1:dim,:) = moving;
            xx = reshape(x,dim*R,L);
            rho0(cdim+(1:cdim:cdim*R),:) = xx(1:dim:dim*R,:);
            rho0(cdim+(2:cdim:cdim*R),:) = xx(2:dim:dim*R,:);
        end
        options = odeset('RelTol',1e-6,'AbsTol',1e-6);
        tspan = [0 tend];
%         tspan = linspace(0,tend,200);
%         [t, rhot] = ode45(@Gc,tspan,reshape(rho0,L*cCSP,1),options); % C version
        rhot = ode45(@Gc,tspan,reshape(rho0,L*cCSP,1),options); % C version
        %         rhot = ode45(@G,[0 1],reshape(rho0,L*cCSP,1),options); % matlab version
        %% figure
        
%         figure,
%         for ll = 1:6:(size(rhot,2)/6)
%             scatter3(rhot(:,6*(ll-1)+1),rhot(:,6*(ll-1)+2),rhot(:,6*(ll-1)+3),'.')
%             hold on
%         end
        
        %% calculate the derivative of rhot -> later use deval to get derivative
        
%         drho = zeros(size(rhot));
%         for tt = 1:length(t)
%           drho(tt,:) = Gc(t(tt),rhot(tt,:)');
%         end
%         
%         
%         assert(rhot.x(end) == tend); % if not, integration failed     

    end

pointPath_hd = @pointPathOrder0_hd;

end
