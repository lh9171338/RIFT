function image = drawKeypoints(image,keypoints,drawFlag)
%DRAWKEYPOINTS - Draw keypoints.
%
%   drawKeypoints(image,keypoints)
%   image = drawKeypoints(image,keypoints)
%   image = drawKeypoints(image,keypoints,drawFlag)

%% Check argument
narginchk(2,3);
nargoutchk(0,1);
if nargin < 3
    if nargout == 0
        drawFlag = true;
    else
        drawFlag = false;
    end
end

%% Draw keypoints
if isstruct(keypoints)
    keypoints = vertcat(keypoints.pt);        
end  
nPoints = size(keypoints,1);
position = round([keypoints,ones(nPoints,1) * 2]);
color = uint8(rand(nPoints,3) * 255);
image = insertShape(image,'Circle',position,'Color',color,'LineWidth',2);

%% 
if drawFlag
    figure;imshow(image);
end
