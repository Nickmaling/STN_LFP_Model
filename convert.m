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


sigma = 12;

formatSpec = [repmat('%f',1,366'),'%[^\n\r]'];


lfpdir = ('<directory where your neuron output is saved as .txts>');
load(strcat(lfpdir,'sectionNames.mat'));

for j = 1001:3000        
    oldname = ['currents_N_',num2str(j),'.txt'];        
    fileID = fopen(oldname,'r');
    dataArrayp = textscan(fileID, formatSpec, 'Delimiter', '\t', 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', false);
    fclose(fileID);
    P = table(dataArrayp{1:end-1}, 'VariableNames', ['times', sectionnames]);
    pots = P{:,2:end};

    newname = ['sig_',num2str(sigma),'_N_',num2str(j),'.bin'];
    fileID2 = fopen(newname,'w');
    fwrite(fileID2,pots,'double');
    fclose(fileID2);
end
