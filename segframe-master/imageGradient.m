function G = imageGradient(im)

   [GY,GX,GZ] = gradient(im);
   G(1,:,:,:) = GX;
   G(2,:,:,:) = GY;
   G(3,:,:,:) = GZ;

end
