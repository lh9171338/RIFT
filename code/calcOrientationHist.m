function [orients,hist] = calcOrientationHist(orientMap,magMap,pt,param)
%CALCORIENTATIONHIST - Calculate orientatin histogram.
%
%   orient = calcOrientationHist(orientMap,magMap,pt,param)
%   [orients,hist] = calcOrientationHist(orientMap,magMap,pt,param)

%% Check argument
narginchk(4,4);
nargoutchk(0,2);

%% Parameter
radius = param.histRadius;
sigma = param.histSigma;
nBins = param.histBins;
peakRatio = param.histPeakRatio;
expScale = -1 / (2 * sigma * sigma);

%% Compute orientation histogram
temphist = zeros(nBins+4,1);
hist = zeros(nBins,1);
pt = round(pt);
x0 = pt(1);
y0 = pt(2);
[rows,cols] = size(orientMap);
for i=-radius:radius
    y = y0 + i;
    if y < 1 || y > rows
        continue;
    end
    for j=-radius:radius
        x = x0 + j;
        if x < 1 || x > cols
            continue;
        end
        W = exp((i^2 + j^2) * expScale);
        mag = magMap(y,x);
        ang = orientMap(y,x);
        bin = round(ang / 180 * nBins);
        bin = mod(bin,nBins) + 1;
        temphist(bin+2) = temphist(bin+2) + W * mag;
    end
end

%% Smooth orientation histogram
temphist(1) = temphist(nBins+1);
temphist(2) = temphist(nBins+2);
temphist(nBins+3) = temphist(3);
temphist(nBins+4) = temphist(4);
for i=3:nBins+2
    hist(i-2) = (temphist(i-2) + temphist(i+2)) * (1/16)+...
        (temphist(i-1) + temphist(i+1)) * (4/16)+...
        temphist(i) * (6/16);
end

%% Compute principal orientation
omax = max(hist);
threshold = omax * peakRatio;
orients = [];
for j=1:nBins
     left = mod(j-2,nBins) + 1;
     right = mod(j,nBins) + 1;
     if  hist(j) > hist(left)  &&  hist(j) > hist(right)  &&  hist(j) >= threshold
            bin = j - 0.5 * (hist(right) - hist(left)) / (hist(right) + hist(left) - 2 * hist(j));
            bin = mod(bin-1,nBins);
            orient = 180 / nBins * bin;
            orients = cat(1,orients,orient);
     end
end
