%     This file is part of STN_LFP_Model.
% 
%     STN_LFP_Model is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     any later version.
% 
%     STN_LFP_Model is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with STN_LFP_Model.  If not, see <https://www.gnu.org/licenses/>.
% 
% 
%     Copyright 2018 Nicholas Maling




function [newpts, newlead] = leadrotation(lead,ptcloud,relative)

% pole = N x 3 matrix describing the location of N contacts in a line.
% Origin of rotation is the point defined at lead(1,:) if relative == 1.
% This point should represent the bottom of contact 0 if using a medtronic naming convention
% electrode if relative ~= 1, ptslcoud is rotated about its native origin

origin = lead(1,:);
lead = bsxfun(@minus,lead,origin);

if relative == 1;
    newpts = bsxfun(@minus,ptcloud(:,1:3),origin);
else
    newpts = ptcloud(:,1:3);
end

ref = lead(size(lead,1),:);
locs2d = [sqrt(ref(1).^2+ref(2).^2),ref(3)];

yin  = atan2(ref(2),ref(1))*360/(2*pi);
yang = atan2(locs2d(1),ref(3))*360/(2*pi);

rotmat1 = findRotMat(0,0,yin);
rotmat2 = findRotMat(0,yang,0);
rotmat3 = findRotMat(0,0,-yin);

newpts = (((newpts*rotmat1)*rotmat2)*rotmat3);
newlead = (((lead*rotmat1)*rotmat2)*rotmat3);
end

function Rmat = findRotMat(xan,yan,zan)

    x=[1 0 0; 0 cos(xan*pi/180) -sin(xan*pi/180); 0 sin(xan*pi/180) cos(xan*pi/180)];
    y=[cos(yan*pi/180) 0 sin(yan*pi/180); 0 1 0; -sin(yan*pi/180) 0 cos(yan*pi/180)];	
    z=[cos(zan*pi/180) -sin(zan*pi/180) 0; sin(zan*pi/180) cos(zan*pi/180) 0; 0 0 1];

    Rmat = x*y*z;
end