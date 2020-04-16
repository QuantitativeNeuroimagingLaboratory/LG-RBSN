I=double(ones(100,100,100)+10);
[X Y Z]=ndgrid(20:60,20:60,20:60);
pts=[X(:) Y(:) Z(:)];
val=double(ones(size(X(:)))+10);
PNorm(pts,val+4,double(I)+4,[0 0 0],[1 1 1],val*0+1,1)
NMI(pts,val+4,double(I)+20,[0 0 0],[1 1 1],val)
% det=ones(size(pts,1),1);
% 
% 
% tic
% [res d(:,1) d(:,2) d(:,3)]=NMI3D_DET_PW(pts,val+2,I+2,[0 230 0 230],[240 240],[0 0 0],[1 1 1],det)