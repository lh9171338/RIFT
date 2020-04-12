function image = drawMatches(image1,keypoints1,image2,keypoints2,matches,drawFlag)
%DRAWMATCHES - Draw matches.
%
%   drawMatches(image1,keypoints1,image2,keypoints2,matches)
%   image = drawMatches(image1,keypoints1,image2,keypoints2,matches)
%   image = drawMatches(image1,keypoints1,image2,keypoints2,matches,drawFlag)

%% Check argument
narginchk(5,6);
nargoutchk(0,1);
if nargin < 6
    if nargout == 0
        drawFlag = true;
    else
        drawFlag = false;
    end
end

%% 
if size(image1,3) == 1
    image1 = repmat(image1,[1,1,3]);
end
if size(image2,3) == 1
    image2 = repmat(image2,[1,1,3]);
end
[rows1,cols1,~] = size(image1);
[rows2,cols2,~] = size(image2);
rows = max(rows1,rows2);
cols = cols1 + cols2;
image = uint8(zeros(rows,cols,3));
image(1:rows1,1:cols1,:) = image1;
image(1:rows2,cols1+1:end,:) = image2;

%% Draw matches
nMatches = size(matches,1);
if isstruct(keypoints1)
    keypoints1 = vertcat(keypoints1.pt);        
end  
if isstruct(keypoints2)
    keypoints2 = vertcat(keypoints2.pt);        
end  
keypoints1 = round(keypoints1(matches(:,1),:));
keypoints2 = round(keypoints2(matches(:,2),:));
keypoints2(:,1) = keypoints2(:,1) + cols1;
position1 = [keypoints1,ones(nMatches,1) * 2];
position2 = [keypoints2,ones(nMatches,1) * 2];
position = [keypoints1,keypoints2];
color = uint8(rand(nMatches,3) * 255);
image = insertShape(image,'Circle',position1,'Color',color,'LineWidth',2);
image = insertShape(image,'Circle',position2,'Color',color,'LineWidth',2);
image = insertShape(image,'Line',position,'Color',color,'LineWidth',1);

%%
if drawFlag
    figure;imshow(image);
end
