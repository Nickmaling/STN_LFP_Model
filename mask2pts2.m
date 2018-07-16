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



function [ptcloud, longvector, vxdim, volume] = mask2pts2(stnmask,numdivs,density,vxdim)
    
    %	  Takes a mask of an STN in niftii form as an input
    %
    %   Output is a 3D grid of points corresponding to 
    %   neuron soma locations for the model
    %
    %   NUMBER OF DIVISONS
    %
    %   divisons
    %   Medial    / cEntEr  / Lateral
    %   M           E         L
    %   Posterior / mIddle  / Anterior
    %   P           I         A
    %   Ventral   / Central / Dorsal
    %   V           C         D
    %   numdivs = [MEL divisions,PIA divisions,VCD divisions];
    %
    %   numdivs = [1,1,2]
    %   STN will be composed of a 2 sections, divided in
    %   half by the Z (dorsal/ventral) axis
    %   density would be specified as [V D] as per priority convention
    %   
    %   numdivs = [3,3,1];
    %   STN will be composed of 9 secions, divided in 3 along the X 
    %   (medial/lateral)axis and divided in 3 along the Y 
    %   (antieror/posterior)axis
    %   density would be specified as [MP MI MA EP IE EA LP LI LA] as per
    %   the priority convention
    %
    %   numdivs = [1,3,3];
    %   STN will be composed of 9 secions, divided in 3 along the Y 
    %   (anterior/posterior)axis and divided in 3 along the Z 
    %   (dorsal/lateral)axis
    %   density would be specified as [PV PC PD IV IC ID AV AC AD] as per
    %   the priority convention
    
    %   SPECIFY DENSITY IN EACH DIVISION
    %
    %   Density of sectors
    %   Medial   / cEntrE / Lateral
    %   M          E        L
    %   Anterior / mIddle / Posterior
    %   A          I        P
    %   Dorsal   / Center / Ventral
    %   D          C        V
    %
    %   density specification prioritized in MEL axis, then AIP axis, then
    %   DCV axis    
    %   priority would result in this order for a 27 (3x3x3) division STN: 
    %
    %                  [MAD MAC MAV MID MIC MIV MPD MPC MPV...
    %                   EAD EAC EAV EID EIC EIV EPD EPC EPV...
    %                   LAD LAC LAV LID LIC LIV LPD LPC LPV]
    %
    %   for numdivs = [1,1,2] density would be specified
    %
    %                  [D V]
    %
    %   for numdivs = [2,2,2] density would be specified
    %           
    %                  [MAD MAV MPD MPV LAD LAV LPD LPV]
    %______________________________________________________________________
    
    nii = load_nii(stnmask);
    header = load_untouch_header_only(stnmask);
    
    if nargin <4
        vxdim = header.dime.pixdim(2:4);
    end
    
    if nargin <3
        density = [1];
    end
    
    if nargin <2
        numdivs = [1,1,1];
    end
    
%-------sample parameters here----------
% clear
% vxdim = [1,.92,.92];
% pts = [2,1,2,3,2,2,2,2,2,2,2,1,1,3,3;1,1,1,1,2,3,1,1,1,1,1,2,3,2,3;0,1,1,1,1,1,2,3,4,5,6,1,1,1,1]';
% pts = [1,1,1,1,2;1,1,2,3,2;1,6,2,2,2]';
% density = [200,220,240,260,280,300,320,340,360];
% numdivs = [1,3,3];
% 
% 
% density = [1872,1626,1269,1611,1472,1431,1196,1148,1207];
% numdivs = [1,3,3];
%-------sample parameters here----------

    
    
    %[pts(:,1),pts(:,2),pts(:,3)] = ind2sub(size(nii.img),find(nii.img>0.4));
    [pts(:,1),pts(:,2),pts(:,3)] = ind2sub(size(nii.img),find(nii.img==0));
    volume = length(pts)*prod(vxdim);
    
    offset = [header.hist.qoffset_x,header.hist.qoffset_y,header.hist.qoffset_z];
    
    % scaled points
    spts(:,1) = (pts(:,1)-1).*vxdim(1)+offset(1);
    spts(:,2) = (pts(:,2)-1).*vxdim(2)+offset(2);
    spts(:,3) = (pts(:,3)-1).*vxdim(3)+offset(3);

    %spts = bsxfun(@times,pts,vxdim);
    
    %temporary points to be manipulated (dont worry about offset)
    tpts = bsxfun(@times,pts,vxdim);
    
    com = mean(tpts);
    
    % defining the two points anch1 and anch2 that will be used to define
    % the long axis.
    
    diffs1 = bsxfun(@minus,tpts,com);
    dists1 = sqrt(diffs1(:,1).^2+diffs1(:,2).^2+diffs1(:,3).^2);
    anch1 = find(dists1==max(dists1),1);
    
    diffs2 = bsxfun(@minus,tpts,tpts(anch1,:));
    dists2 = sqrt(diffs2(:,1).^2+diffs2(:,2).^2+diffs2(:,3).^2);
    anch2 = find(dists2==max(dists2),1);
    
    longvector = [tpts(anch1,:);tpts(anch2,:)];
    % define the major axis as the cardinal axis nearest to the
    % long axis. The object will be 'snapped' to this axis

    scat3(tpts)
    line(longvector(:,1),longvector(:,2),longvector(:,3))
    longvector = [spts(anch1,:);spts(anch2,:)];
    
    x = 1:1:3;
    [~,majordimension] = min([sqrt(diffs2(anch2,2)^2+diffs2(anch2,3)^2),sqrt(diffs2(anch2,1)^2+diffs2(anch2,3)^2),sqrt(diffs2(anch2,1)^2+diffs2(anch2,2)^2)]);
    minordimension = x(x~=majordimension);
    
    if mod(majordimension,2) == 0
        if(diffs2(anch2,minordimension(1))>0)
            firsign = 1;
            secsign = 1;
        else
            firsign = -1;
            secsign = 1;
        end
    else
        if(diffs2(anch2,minordimension(1))>0)
            firsign = -1;
            secsign = -1;
        else
            firsign = 1;
            secsign = -1;
        end
    end
    
    tpts = diffs2;
    
    % First rotation: rotate the object along its major axis into the plane
    % minordimension(1) = 0
    vec1 = [tpts(anch2,minordimension(2)),tpts(anch2,minordimension(1)),0] - [tpts(anch1,minordimension(2)),tpts(anch1,minordimension(1)),0];
    vec2 = [1,0,0];
    
    majorang = firsign*atan2(norm(cross(vec1,vec2)),dot(vec1,vec2))*180/pi;
    rotang(majordimension) = majorang;
    rotang(minordimension) = 0;
    
    rotmat = findRotMat(rotang(1),rotang(2),rotang(3));
    frotpts = tpts*rotmat;
    
    scat3(frotpts,'first rotation');
    line([frotpts(anch1,1),frotpts(anch2,1)],[frotpts(anch1,2),frotpts(anch2,2)],[frotpts(anch1,3),frotpts(anch2,3)]);
    
    % Second rotation: rotate the object along its minor axis (1) into the
    % plane minordimension(2) = 0
    vec1 = [frotpts(anch2,majordimension),frotpts(anch2,minordimension(2)),0] - [frotpts(anch1,majordimension),frotpts(anch1,minordimension(2)),0];
    vec2 = [secsign*1,0,0];
    rotang(minordimension(1)) = -secsign*atan2(norm(cross(vec1,vec2)),dot(vec1,vec2))*180/pi;
    rotang(majordimension) = 0;
    rotang(minordimension(2)) = 0;
    
    rotmat = findRotMat(rotang(1),rotang(2),rotang(3));
    srotpts = frotpts*rotmat;
    
    scat3(srotpts,'second rotation');
    line([srotpts(anch1,1),srotpts(anch2,1)],[srotpts(anch1,2),srotpts(anch2,2)],[srotpts(anch1,3),srotpts(anch2,3)]);
    
    % Third rotation: rotate the object along its major axis to undo
    % unwanted rotation
    
    rotang(majordimension) = -majorang;
    rotang(minordimension) = 0;
    rotmat = findRotMat(rotang(1),rotang(2),rotang(3));
    rotpts = srotpts*rotmat;
    
    scat3(rotpts,'final');
    line([rotpts(anch1,1),rotpts(anch2,1)],[rotpts(anch1,2),rotpts(anch2,2)],[rotpts(anch1,3),rotpts(anch2,3)]);
    
    
    comR = mean(rotpts);
    rotmaxs = max(rotpts);
    rotmins = min(rotpts);
    
    xthresh = [rotmins(1):2/numdivs(1)*(comR(1)-rotmins(1)):rotmins(1)+(2*(numdivs(1)-1)/numdivs(1)*(comR(1)-rotmins(1))),rotmaxs(1)+1];
    ythresh = [rotmins(2):2/numdivs(2)*(comR(2)-rotmins(2)):rotmins(2)+(2*(numdivs(2)-1)/numdivs(2)*(comR(2)-rotmins(2))),rotmaxs(2)+1];
    zthresh = [rotmins(3):2/numdivs(3)*(comR(3)-rotmins(3)):rotmins(3)+(2*(numdivs(3)-1)/numdivs(3)*(comR(3)-rotmins(3))),rotmaxs(3)+1];
    
    ptmaxs = max(spts);
    ptmins = min(spts);
    
    for i = 1:length(density)
        linarrayx = ptmins(1)-(vxdim(1)/2):1/(density(i)^(1/3)):ptmaxs(1)+(vxdim(1)/2);
        linarrayy = ptmins(2)-(vxdim(2)/2):1/(density(i)^(1/3)):ptmaxs(2)+(vxdim(2)/2);
        linarrayz = ptmins(3)-(vxdim(3)/2):1/(density(i)^(1/3)):ptmaxs(3)+(vxdim(3)/2);
        
        [x,y,z] = meshgrid(linarrayx,linarrayy,linarrayz);
        
        hdGrid{i} = [reshape(x,numel(x),1),reshape(y,numel(y),1),reshape(z,numel(z),1)];
    end
        
    ptcloud = [];
    
    for j = 1:numdivs(1)
        for k = 1:numdivs(2)
            for l = 1:numdivs(3)
                div = rotpts(:,1)>=xthresh(j) & rotpts(:,1)<xthresh(j+1) & rotpts(:,2)>=ythresh(k) & rotpts(:,2)<ythresh(k+1) & rotpts(:,3)>=zthresh(l) & rotpts(:,3)<zthresh(l+1);
                divnum = (numdivs(2)*numdivs(3)*(j-1))+(numdivs(3)*(k-1))+(l);
                temp = [];
                secpts = spts(div,:);
                
                backGrid = squeeze(hdGrid{divnum});
                
                for V = 1:size(secpts,1)
                    pt = secpts(V,:);
                    lb = pt-(vxdim/2);
                    ub = pt+(vxdim/2);
                    
                    %backGrid = bsxfun(@plus,bsxfun(@minus,backGrid,mean(backGrid)),pt);
                    
                    thing = backGrid(backGrid(:,1)>=lb(1)&backGrid(:,1)<=ub(1)&backGrid(:,2)>=lb(2)&backGrid(:,2)<=ub(2)&backGrid(:,3)>=lb(3)&backGrid(:,3)<=ub(3),:);
                    temp(size(temp,1)+1:size(temp,1)+size(thing,1),1:3) = thing;
                    
                end
                if isempty(temp)==0;
                    temp(:,4) = divnum;
                end
                ptcloud = [ptcloud; temp];
            end
        end
    end
end


function Rmat = findRotMat(xan,yan,zan)

    x=[1 0 0; 0 cos(xan*pi/180) -sin(xan*pi/180); 0 sin(xan*pi/180) cos(xan*pi/180)];
    y=[cos(yan*pi/180) 0 sin(yan*pi/180); 0 1 0; -sin(yan*pi/180) 0 cos(yan*pi/180)];
    z=[cos(zan*pi/180) -sin(zan*pi/180) 0; sin(zan*pi/180) cos(zan*pi/180) 0; 0 0 1];

    Rmat = x*y*z;
end