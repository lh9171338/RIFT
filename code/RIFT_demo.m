% This is a samplest implementation of the proposed RIFT algorithm. In this implementation,...
% rotation invariance part and corner point detection are not included.

clc;clear;close all;
warning('off')

str1 = '../image/map-optical/pair1.jpg';   % image pair
str2 = '../image/map-optical/pair2.jpg';

im1 = im2uint8(imread(str1));
im2 = im2uint8(imread(str2));
if size(im1,2) > 800
    im1 = imresize(im1,800/size(im1,2));
end
if size(im2,2) > 800
    im2 = imresize(im2,800/size(im2,2));
end

if size(im1,3)==1
    temp=im1;
    im1(:,:,1)=temp;
    im1(:,:,2)=temp;
    im1(:,:,3)=temp;
end

if size(im2,3)==1
    temp=im2;
    im2(:,:,1)=temp;
    im2(:,:,2)=temp;
    im2(:,:,3)=temp;
end

disp('RIFT feature detection and description')
% RIFT feature detection and description
[des_m1,des_m2] = RIFT_no_rotation_invariance(im1,im2,4,6,96);

disp('nearest matching')
% nearest matching
[indexPairs,matchmetric] = matchFeatures(des_m1.des,des_m2.des,'MaxRatio',1,'MatchThreshold', 100);
matchedPoints1 = des_m1.kps(indexPairs(:, 1), :);
matchedPoints2 = des_m2.kps(indexPairs(:, 2), :);

disp('outlier removal')
%outlier removal
H=FSC(matchedPoints1,matchedPoints2,'affine',3);
Y_=H*[matchedPoints1';ones(1,size(matchedPoints1,1))];
Y_(1,:)=Y_(1,:)./Y_(3,:);
Y_(2,:)=Y_(2,:)./Y_(3,:);
E=sqrt(sum((Y_(1:2,:)-matchedPoints2').^2));
inliersIndex=E<3;
cleanedPoints1 = matchedPoints1(inliersIndex, :);
cleanedPoints2 = matchedPoints2(inliersIndex, :);

disp('Show matches')
% Show results
figure; showMatchedFeatures(im1, im2, cleanedPoints1, cleanedPoints2, 'montage');

disp('registration result')
% registration
image_fusion(im2,im1,double(H));
