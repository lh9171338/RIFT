function image = RIFTMatch(image1,image2)
%RIFTMATCH - Match images based on RIFT.
%
%   image = RIFTMatch(image1,image2)

%% Check argument
narginchk(2,2);
nargoutchk(1,1);

%% Detect keypoints and compute descriptors
param1 = getDefaultParam();
param2 = getDefaultParam();
param1.usePrincipalOrient = true;param1.useOrientExtend = true;
param2.usePrincipalOrient = true;param2.useOrientExtend = false;
[keypoints1,descriptors1] = detectAndCompute(image1,param1);
[keypoints2,descriptors2] = detectAndCompute(image2,param2);
        
%% Match
matches = match(descriptors1,descriptors2);
matchedPoints1 = vertcat(keypoints1.pt);
matchedPoints2 = vertcat(keypoints2.pt);
matchedPoints1 = matchedPoints1(matches(:,1),:);
matchedPoints2 = matchedPoints2(matches(:,2),:);
[tform,inlierPoints1,inlierPoints2,status] = estimateGeometricTransform(matchedPoints1,matchedPoints2,...
    'similarity','Confidence',99,'MaxDistance',3);
scale = norm(tform.T(1:2,1:2));
numInliers = size(inlierPoints1,1);
goodMatches = [1:numInliers;1:numInliers]';
disp(['numInliers = ',num2str(numInliers),' scale = ', num2str(scale)]);

%% Save result
image = drawMatches(image1,inlierPoints1,image2,inlierPoints2,goodMatches);
