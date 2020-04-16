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

function gradTransport = getPointGradTransportOrder0_hengda(lddmmoptions)

dim = lddmmoptions.dim;
cdim = lddmmoptions.cdim; % computations performed in cdim
L = lddmmoptions.L;
R = lddmmoptions.R;
CSP = lddmmoptions.CSP;
cCSP = lddmmoptions.cCSP;
scales = lddmmoptions.scales;
scaleweight = lddmmoptions.scaleweight;
energyweight = lddmmoptions.energyweight;
epsilon = lddmmoptions.epsilon;

    function v0 = lgradTransport(v1, x, rhot)

        function dy = Gc(tt,ytt) % wrapper for cpu version of G
            t = intTime(tt,true,lddmmoptions);
            rhott = deval(rhot,t);
            if dim ~= cdim
                yt = rho2dTo3dOrder0(ytt,lddmmoptions);
            end    

            dy = fastPointGradTransportOrder0(yt,rhott,L,R,cdim,scales.^2,scaleweight.^2,energyweight);
            if dim ~= cdim
                dy = rho3dTo2dOrder0(dy,lddmmoptions);
            end
            
            dy = -intResult(dy,true,lddmmoptions); % sign for backwards integration already accounted for

            % debug
            if getOption(lddmmoptions,'testC')
                dy2 = G(tt,ytt);  
                assert(norm(dy-dy2) < epsilon);
            end
        end       
        [Ks D1Ks D2Ks] = gaussianKernels();
        function vt = Egradth(ttt)    
            vt = zeros(CSP*L,1);
            
            rhott = deval(rhot,ttt);
            if dim ~= cdim
                rhott = rho3dTo2dOrder0(rhott,lddmmoptions);
            end
            rhott = reshape(rhott,CSP,L);
            
            for i = 1:L % particle
                xi = rhott(1:dim,i);

                for ll = 1:L % particle
                    xl = rhott(1:dim,ll);
                                         
                        al = rhott((1+dim:2*dim),ll); 
                        ai = rhott((1+dim:2*dim),i);                                                                                                               

                        ks = Ks(xi,xl,scales(1),scaleweight(1));
                        d1ks = D1Ks(xi,xl,scales(1),scaleweight(1));

                        vt(CSP*(i-1)+(1+dim:2*dim)) = vt(CSP*(i-1)+(1+dim:2*dim)) + 2*ks*al;
                        vt(CSP*(i-1)+(1:dim)) = vt(CSP*(i-1)+(1:dim)) + 4*d1ks*ai'*al*(xi-xl);

                end
            end
        end
        function dy = G(tt,ytt)
            ytt = reshape(ytt,1,CSP*L);
            t = intTime(tt,true,lddmmoptions);          

            dy = zeros(size(ytt));

            rhott = deval(rhot,t);
            if dim ~= cdim
                rhott = rho3dTo2dOrder0(rhott,lddmmoptions);
            end
            rhott = reshape(rhott,CSP,L);

            for i = 1:L % particle
                xi = rhott(1:dim,i);
                dxi = ytt(1,CSP*(i-1)+(1:dim))';

                for l = 1:L % particle
                    xl = rhott(1:dim,l);  % displacement 
                    dxl = ytt(1,CSP*(l-1)+(1:dim))';

                    ximxl = xi-xl;                    

                        alsl = rhott((1+dim:2*dim),l); %momentum
                        aisi = rhott((1+dim:2*dim),i); %momentum
                        ksl = Ks(xi,xl,scales(1),scaleweight(1));
                        d1ksl = D1Ks(xi,xl,scales(1),scaleweight(1));
                        d1kslXximxl = d1ksl*ximxl;
                        d2ksl = D2Ks(xi,xl,scales(1),scaleweight(1));                  

                        dalsl = ytt(1,CSP*(l-1)+(1+dim:2*dim))';

                        % dx
                            daisi = ytt(1,CSP*(i-1)+(1+dim:2*dim))';                           

                            % dx
                            dy(1,CSP*(i-1)+(1:dim)) = dy(1,CSP*(i-1)+(1:dim)) ...
                                + (-2*d1ksl*(aisi'*alsl*daisi-aisi'*alsl*dalsl) ...
                                - 4*d2ksl*ximxl'*(aisi'*alsl*daisi-aisi'*alsl*dalsl)*ximxl)' ...
                                + (2*d1kslXximxl*(aisi'*dxl+alsl'*dxi))';  

                            % da
                            dy(1,CSP*(i-1)+(1+dim:2*dim)) = dy(1,CSP*(i-1)+(1+dim:2*dim)) ...
                                + (ksl*dxl - 2*ximxl'*(d1ksl*daisi-d1ksl*dalsl)*alsl)';

                end
            end

            dy = dy + energyweight(1)*Egradth(t)';
            dy = -intResult(dy,true,lddmmoptions); % sign for backwards integration already accounted for            
            
            dy = reshape(dy,CSP*L,1);
        end

        % integrate
        options = odeset('RelTol',1e-6,'AbsTol',1e-6);
        vt = ode45(@Gc,[0 1],reshape(v1,CSP,L),options); % solve backwards, cpu
%         vt = ode45(@G,[0 1],v1,options); % solve backwards, slooow matlab
        assert(vt.x(end) == 1);
        v0 = reshape(deval(vt,1),CSP*L,1);
        
    end

gradTransport = @lgradTransport;

end