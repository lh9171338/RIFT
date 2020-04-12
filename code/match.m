function matches = match(descriptors1,descriptors2)
%MATCH - Match descriptors.
%
%   matches = match(descriptors1,descriptors2)

%% Check argument
narginchk(2,2);
nargoutchk(1,1);

%% Match descriptors
nDescriptors1 = size(descriptors1,1);
nDescriptors2 = size(descriptors2,1);
distances12 = descriptors1 * descriptors2';
distances21 = descriptors2 * descriptors1';
[~,indexes1] = max(distances21,[],2);
[~,indexes2] = max(distances12,[],2);
matches12 = [(1:nDescriptors1)',indexes2];
matches21 = [indexes1,(1:nDescriptors2)'];
matches = intersect(matches12,matches21,'rows');
