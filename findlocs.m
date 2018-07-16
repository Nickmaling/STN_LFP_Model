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


addpath(genpath('<path where you keep your matlab scripts>'))
lfpdir = ('<path where you keep your NEURON results as .bin files>');

load(strcat(lfpdir,'sectionNames.mat'));
load(strcat(lfpdir,'nrnlocshet10.mat'));

angles = [-10:2:20];
deltas = 0;%[0:.2:1];

numsecs = length(sectionnames);
numneu = length(nrnlocs);

formatSpec = [repmat('%f',1,numsecs'),'%[^\n\r]'];
corfname = strcat(lfpdir,'coords.txt');
fileID = fopen(corfname,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', '\t', 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', false);
fclose(fileID);
L = table(dataArray{1:end-1}, 'VariableNames', sectionnames);

locs = [L{1,:}-L{1,1};L{2,:}-L{2,1};L{3,:}-L{3,1}]*1e-3;
clearvars formatSpec corfname fileID dataArray L

radius = 3;
for k = 1:length(angles);
    angle = angles(k);
    [leadvectorR1] = leadrotation(leadvector,angle);
    [nrnlocsR(k,:,:), leadvectorR, finalrotmat] = cloudrotation(leadvectorR1,nrnlocs,1);
    synchcenter(k,:) = ((leadvectorR(2,:).*2.2)+leadvectorR(1,:))./3.2;
    nrnlocsT = bsxfun(@minus,squeeze(nrnlocsR(k,:,:)),squeeze(synchcenter(k,:)));
    nrnlocsT(sqrt(sum(nrnlocsT.^2,2))<radius,4) = 1;
    inds = randperm(numneu,round(numneu/20));
    %scat3(nrnlocsT(inds,:));view(0,0)
end