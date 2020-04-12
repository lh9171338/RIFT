% RIFT_demo.m
%%
clc,clear;
close all;

%% Parameters
folder = '../image/map-optical';
srcFilename1 = [folder,'/image1.jpg'];
srcFilename2 = [folder,'/image2.jpg'];
dstFilename = [folder,'/result.jpg'];
saveFlag = true;

%% Read images
image1 = imread(srcFilename1);
image2 = imread(srcFilename2);
if size(image1,2) > 800
    image1 = imresize(image1,800/size(image1,2));
end
if size(image2,2) > 800
    image2 = imresize(image2,800/size(image2,2));
end

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
    'similarity','Confidence',90,'MaxDistance',5);
scale = norm(tform.T(1:2,1:2));
numInliers = size(inlierPoints1,1);
goodMatches = [1:numInliers;1:numInliers]';
disp(['numInliers = ',num2str(numInliers),' scale = ', num2str(scale)]);

%% Save result
% drawKeypoints(image1,inlierPoints1);
% drawKeypoints(image2,inlierPoints2);
image = drawMatches(image1,inlierPoints1,image2,inlierPoints2,goodMatches,true);
if saveFlag
    imwrite(image,dstFilename);
end
