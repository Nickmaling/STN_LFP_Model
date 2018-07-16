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




function [ptcloud] = mask2ptsphere(density,radius)

    [X,Y,Z] = meshgrid(-radius:1/density:radius,-radius:1/density:radius,-radius:1/density:radius);
    sz = floor(density*radius*2+1)^3;
    grid = [reshape(X,1,sz);reshape(Y,1,sz);reshape(Z,1,sz)];
    ptcloud = grid(:,sqrt(sum((grid.^2)))<radius)';