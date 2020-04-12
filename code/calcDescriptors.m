function descriptors = calcDescriptors(orientMap,keypoints,param)
%CALCDESCRIPTORS - Calculate descriptors.
%
%   descriptors = calcDescriptors(orientMap,keypoints,param)

%% check argument
narginchk(3,3);
nargoutchk(1,1);

%% parameter
radius = param.radius;
descriptorSize = param.descriptorSize;
dim = prod(descriptorSize);

%% Calculate descriptors
nPoints = numel(keypoints);
descriptors = zeros(nPoints,dim);
for i=1:nPoints
    kpt = keypoints(i);
    pt = round(kpt.pt);
    angle = kpt.angle;
    descriptors(i,:) = calcRIFTDescriptor(orientMap,pt,angle,radius,descriptorSize);
end
