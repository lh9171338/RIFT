function [keypoints,descriptors] = detectAndCompute(image,param)
%DETECTANDCOMPUTE - Detect keypoints and compute descriptors.
%
%   [keypoints,descriptors] = detectAndCompute(image,param)


%% Check argument
narginchk(1,2);
nargoutchk(2,2);

%% RIFT parameters
if nargin < 2
    param = getDefaultParam();
end
nScale = param.nScale;
nOrient = param.nOrient;
nFeatures = param.nFeatures;

%% Compute phase consistency
if size(image,3) == 3
    image = rgb2gray(image);
end
[maxMoment,~,orientMap,~,~,EO,~,magMap] = phasecong3(image,...
    nScale,nOrient,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1);

%% Detect FAST keypoints
a = max(maxMoment(:)); 
b = min(maxMoment(:)); 
maxMoment = (maxMoment - b) / (a - b);
points = detectFASTFeatures(maxMoment,'MinContrast',0.05);
points = points.selectStrongest(nFeatures).Location;

%% Compute principal orientation
keypoints = calcOrientation(orientMap,magMap,points,param);

%% Compute descriptors
[rows,cols,~] = size(image);
An = zeros(rows,cols,nOrient); 
for j=1:nOrient
    for i=1:nScale
        An(:,:,j) = An(:,:,j) + abs(EO{i,j});
    end
end
[~, mim] = max(An,[],3);
orientMap = mim * 180 / nOrient;
descriptors = calcDescriptors(orientMap,keypoints,param);
