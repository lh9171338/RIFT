function keypoints = calcOrientation(orientMap,magMap,points,param)
%CALCORIENTATION - Calculate principal orientation of keypoints.
%
%   keypoints = calcOrientation(orientMap,magMap,points,param)

%% Check argument
narginchk(4,4);
nargoutchk(1,1);

%% Parameters
usePrincipalOrient = param.usePrincipalOrient;       
useOrientExtend = param.useOrientExtend;   

%% Calculate principal orientation
nPoints = size(points,1);
keypoints = [];
for i=1:nPoints
    pt = round(points(i,:));
    if usePrincipalOrient
        orients = calcOrientationHist(orientMap,magMap,pt,param);
        n = length(orients);
        for j=1:n
            keypoints = cat(1,keypoints,struct('pt',pt,'angle',orients(j)));
            if useOrientExtend
                keypoints = cat(1,keypoints,struct('pt',pt,'angle',orients(j) + 180));
            end
        end
    else
        keypoints = cat(1,keypoints,struct('pt',pt,'angle',0));
    end
end
