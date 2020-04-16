function dJ = jacobian_hd(sx,sy,sz)

h = zeros([3,size(sx)]);

h(1,:,:,:) = sx;
h(2,:,:,:) = sy;
h(3,:,:,:) = sz;

  d1 = imageGradient(squeeze(h(1,:,:,:)));
  d2 = imageGradient(squeeze(h(2,:,:,:)));
  d3 = imageGradient(squeeze(h(3,:,:,:)));
  dJ = zeros(size(h,2),size(h,3),size(h,4),class(h));

  d1(1,:,:,:) = d1(1,:,:,:) + 1;
  d2(2,:,:,:) = d2(2,:,:,:) + 1;
  d3(3,:,:,:) = d3(3,:,:,:) + 1;
  
  % write out the determinant of a 3x3 matrix
  dJ = squeeze(d1(1,:,:,:).*d2(2,:,:,:).*d3(3,:,:,:) + ...
    d1(3,:,:,:).*d2(1,:,:,:).*d3(2,:,:,:) + ...
    d1(2,:,:,:).*d2(3,:,:,:).*d3(1,:,:,:) - ...
    d1(3,:,:,:).*d2(2,:,:,:).*d3(1,:,:,:) - ...
    d1(1,:,:,:).*d2(3,:,:,:).*d3(2,:,:,:) - ...
    d1(2,:,:,:).*d2(1,:,:,:).*d3(3,:,:,:));

end