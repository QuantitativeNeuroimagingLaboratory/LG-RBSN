
function hengda_DSC

path = '/home/hh2699/data/new_region/space_transform/';

[in inheader] = rest_ReadNiftiImage([path,'aparc+aseg_1002.nii.gz']);

[ref refheader] = rest_ReadNiftiImage([path,'aparc+aseg_MNI_1002.nii.gz']);

[out outheader] = rest_ReadNiftiImage([path,'deformed_1002_TPS_inMNI.nii.gz']);
% 
% ref2RAS = imwarp(ref,inv(refheader.mat));
% 
% ref2inout = imwarp(ref2RAS,inheader.mat);

Dice_inref = getdsc(in,ref);
Dice_outref = getdsc(out,ref); 

for i=1:256
    a=out(i,:,:);
    b=ref(i,:,:);
    Dice_ab = getdsc(a,b);
fprintf(['DSC(input,ref,',num2str(i-1),') = ',num2str(Dice_ab),'\n'])
end

for i=1:256
a=sum(sum((ref(:,:,i))));
fprintf(['sum',num2str(i-1),') = ',num2str(a),'\n'])
end

% fprintf(['DSC(input,ref) = ',num2str(Dice_inref),'\n'])
% 
% fprintf(['DSC(output,ref) = ',num2str(Dice_outref),'\n'])

end


function Dice = getdsc(outSegment,refSegment) 

 outSegment = logical(outSegment);
 refSegment = logical(refSegment);
 common = (refSegment & outSegment);
 a = sum(common(:));
 b = sum(refSegment (:));
 c = sum(outSegment(:));
 Dice = 2*a/(b+c);
 
end