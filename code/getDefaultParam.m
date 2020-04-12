function param = getDefaultParam()
%%GETDEFAULTPARAM - Get default parameters of RIFT.
%
%   param = getDefaultParam(image)

%% Check argument
narginchk(0,0);
nargoutchk(1,1);

%% RITF parameters
param.usePrincipalOrient = false;       
param.useOrientExtend = false;     
param.nFeatures = 2500;
param.nScale = 4;
param.nOrient = 6;
param.histSigma = 3.6;
param.histRadius = 12;
param.histBins = 18;
param.histPeakRatio = 1;
param.radius = 48;
param.descriptorSize = [6,6,6];
