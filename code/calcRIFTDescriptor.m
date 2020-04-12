function descriptor = calcRIFTDescriptor(oritenMap,pt,angle,radius,descriptorSize)
%CALCDRIFTESCRIPTOR - Calculate RIFT descriptor.
%
%   descriptor = calcRIFTDescriptor(oritenMap,pt,angle,radius,descriptorSize)

%% Check argument
narginchk(5,5);
nargoutchk(1,1);

%% Parameters
d = descriptorSize(1);
n = descriptorSize(3);
[rows,cols] = size(oritenMap);
scale = 1.0 * d / (2 * radius);
cos_t = cos(-angle * pi / 180);
sin_t = sin(-angle * pi / 180);
hist = zeros(d,d,n);

%% Calculate RIFT descriptor
x0 = pt(1);
y0 = pt(2);
for i=-radius:radius-1
    for j=-radius:radius-1
        c_rot = round(j * cos_t - i * sin_t);
        r_rot = round(j * sin_t + i * cos_t);
        r = y0 + r_rot;
        c = x0 + c_rot;
        if r > 0 && r <= rows  && c > 0 && c <= cols
            rbin = (i + radius) * scale + 1;
            cbin = (j + radius) * scale + 1;
            orientation = oritenMap(r, c);
            obin = (orientation - angle) / 180 * n;
            obin = mod(obin,n) + 1;
            r0 = floor(rbin); 
            c0 = floor(cbin); 
            o0 = floor(obin);
            hist(r0,c0,o0) =  hist(r0,c0,o0) + 1;
        end
    end
end
descriptor = permute(hist,[3,2,1]);
descriptor = descriptor(:)';

%% Normalize
descriptor = descriptor / norm(descriptor);
