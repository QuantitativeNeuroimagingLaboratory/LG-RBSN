function [f dx dy dz]=PNorm(EvaluationPoints,MovingImageValues,Image,offset,AspectRatioImage,EvalWeights,PNorm)
%**************************************************************************
% The codde requires 64 bit and Intel threadding Building Blocks installed
%**************************************************************************
% Copyright (c) 2012, Sune Darkner, University of Copenhagen
% All rights reserved.
% Sofware was obtained from:
% http://research.ku.dk/search/publicationdetail/?id=1046691e-b44f-47fd-bbf4-b7a07eed86c5
% 
% Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
% 
%     Redistributions of source code must retain the above copyright 
%         notice, this list of conditions and the following disclaimer.
%     Redistributions in binary form must reproduce the above copyright 
%         notice, this list of conditions and the following disclaimer in 
%         the documentation and/or other materials provided with the distribution.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
% IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
% INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
% ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
% THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%**************************************************************************
%**************************************************************************
% function [f dx dy dz]=PNorm(EvaluationPoints,Image,MovingImageValues,HistogramRange,MaxValue,offset,AspectRatioImage,EvalWeights)
% f: The function value, Note that this is normalized
% dx,dy,dz are the derivatives of f in the x,y,and z direction i.e.
% EvaluationPoint(x,y,z)
% 
% EvaluationPoints: The point where the functional is evalueated in the
% Image a Nx3 matrix of doubles
%
% MovingImageValues: The values of the moving image at the correspondingEvaluationPoints Nx1 double array with positive values
% 
% Image: The image to which we which to register the moving image KxLxM
% double array with positive values
% 
% offset: coordinate offset of indexing into the Image 3x1 double (usually set to zero)
%
% AspectRatioImage: Aspect ration of the Image 3x1 double vector
%
% EvalWeights: a Weight for each evaluation point. (ususally set to 1, can
% be used as mask to mask out particular evaluation points) Nx1 doubles
%
% PNorm: The norm that is used. Must be >=0 and double value;
if(numel(EvaluationPoints)/3~=numel(MovingImageValues))
    error('Evaluaton ponts and Moving image values must have the same number of rows');
end
if(numel(EvalWeights)~=numel(MovingImageValues))
    error('EvaluatonPoints and EvalWeights must have the same number of rows');
end

HistogramRange=[floor(min(MovingImageValues))  ceil(max(MovingImageValues))+4 floor(min(Image(:)))  ceil(max(Image(:)))+4 ];
MaxValue=[ceil(max(MovingImageValues))+4  ceil(max(Image(:)))+4];
%[f dx dy dz]=PNorm3D(double(EvaluationPoints),double(MovingImageValues),double(Image),double(offset),double(AspectRatioImage),double(PNorm),double(EvalWeights)*0+1);
[f dx dy dz]=PNorm_PW(double(EvaluationPoints),double(MovingImageValues),double(Image),[0 2000 0 2000],[2000 2000],double(offset),double(AspectRatioImage),double(PNorm),double(EvalWeights));
