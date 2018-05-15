function distanceScore = descriptorDistance(des1, des2)
%myFun - Description
%
% Syntax: distanceScore = descriptorDistance(des1, des2)
%
% Long description
    distanceScore = sqrt((des1 - des2) .^ 2);
end