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





%% Define some paths and initial variables, load in neuron locations and define the locations of sections within the neuron

addpath(genpath('<path where you keep your matlab toolboxes>'))
lfpdir = <directory containing NEURON sim results as .bin>

load(strcat(lfpdir,'sectionNames.mat'));
load(strcat(lfpdir,'nrnlocshet10.mat'));
%load(strcat(lfpdir,'nrnlocsSpT.mat'));
%load(strcat(lfpdir,'nrnlocsreducedmin.mat'));
%load(strcat(lfpdir,'nrnlocstestcase.mat'));

angles = [0];
rads = [4];%[0:0.2:1.2, 1.6:0.4:4, 4.5, 5:1:8];%[0:0.2:1.2, 1.6:0.4:2.8, 3, 3.2:0.4:4, 4.5, 5:1:8];
deltas = [0];%[0:.05:1];%[.1,.2,.3,.4,.6,.7,.8];


synchoffset = [0,0,0];

sig = 0;
mu = 0;
numsecs = length(sectionnames);

numneu = length(nrnlocs);
numruns = length(angles)*length(rads)*length(deltas);
runtimes = [];

formatSpec = [repmat('%f',1,numsecs'),'%[^\n\r]'];
corfname = strcat(lfpdir,'coords.txt');
fileID = fopen(corfname,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', '\t', 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', false);
fclose(fileID);
L = table(dataArray{1:end-1}, 'VariableNames', sectionnames);

locs = [L{1,:}-L{1,1};L{2,:}-L{2,1};L{3,:}-L{3,1}]*1e-3;
clearvars formatSpec corfname fileID dataArray L

%% Begin main loop in three (four) nested parts
% 1 - loop through angles. Angles refers to the rotation of the patient
% specific lead location into a new location to assess the effect of trying
% another hypothetical approach vector.
% This loop defines the nrnlocs, the synchcenters (if multiple), and runs 
% the comsol model
%
% 2 - loop through delta. Delta refers to the spatial shift of the
% synchcenter through the STN along the longvector. If only one delta is 
% defined, the synchcenter is defined as the middle of contact 1.
%
%
% 3 - loop through radius. Radius refers to the radius of the synchronous
% population. This loop contains the inntermost (fourth) loop, which loops
% through each neuron in the pointcloud, determines whether it is within
% the synchronous population, and then assigns it a scaler, loads in its
% potentials, and adds it to the lfp vector for each contact.

run bipolar3.m;
out = [model.result.table('tbl1').getReal,model.result.table('tbl2').getReal,model.result.table('tbl3').getReal,model.result.table('tbl4').getReal];
err = out*2*pi*0.635*1e-3;

for k = 1:length(angles);
    angle = angles(k);
    [leadvectorR1] = leadrotation(leadvector,angle);
    [nrnlocsR, leadvectorR, finalrotmat] = cloudrotation(leadvectorR1,nrnlocs,1);
    
    longvectorR = bsxfun(@minus,longvector,leadvectorR1(1,:))*finalrotmat;
    OleadvectorR = bsxfun(@minus,leadvector,leadvectorR1(1,:))*finalrotmat;
    
    synchcenters = zeros(length(deltas),3);
    for z = 1:length(deltas)
        synchcenters(z,1:3) = (longvectorR(1,:).*deltas(z))+(longvectorR(2,:).*(1-deltas(z)));
    end
    
    locrepo = zeros(2,numneu,numsecs);
    
    disp('Computing Locations')
    for nrn = 1:numneu
        rotmax = findRotMat(0,(randn(1,1)*sig+mu),0);
        rotlocs = (locs'*rotmax)';
        
        rotlocs = bsxfun(@plus,rotlocs,(nrnlocsR(nrn,1:3)'));
        locs2d = [sqrt((rotlocs(1,:).^2)+rotlocs(2,:).^2);rotlocs(3,:)];
        locrepo(1:2,nrn,:) = locs2d(:,:);
    end
    
    %% submit mphinterps in batches of 100 thousand to compute scalers from reciprocity model
    
    AllLocs = [reshape(locrepo(1,:,:),1,numneu*numsecs);reshape(locrepo(2,:,:),1,numneu*numsecs)];
    
    numlocs = size(AllLocs,2);
    
    Nsubmit = ceil(numlocs/1e5);    
	
    scalers = zeros(4,length(AllLocs));
    
    disp('Determining Scalers')
    for subBat = 1:Nsubmit
        if subBat == Nsubmit
            submission = AllLocs(:,1+(subBat-1)*1e5:mod(numlocs,1e5)+(Nsubmit-1)*1e5);
            scalers(1:4,1+(subBat-1)*1e5:mod(numlocs,1e5)+(Nsubmit-1)*1e5) = [mphinterp(model,'V','coord',submission,'dataset','dset1')/err(1); mphinterp(model,'V2','coord',submission,'dataset','dset2')/err(2); mphinterp(model,'V3','coord',submission,'dataset','dset3')/err(3); mphinterp(model,'V4','coord',submission,'dataset','dset4')/err(4)];
        else
            submission = AllLocs(:,1+(subBat-1)*1e5:subBat*1e5);
            scalers(1:4,1+(subBat-1)*1e5:subBat*1e5) = [mphinterp(model,'V','coord',submission,'dataset','dset1'); mphinterp(model,'V2','coord',submission,'dataset','dset2'); mphinterp(model,'V3','coord',submission,'dataset','dset3'); mphinterp(model,'V4','coord',submission,'dataset','dset4')];
        end
        clear submission
    end
    
    %% 'Remove' neurons that intersect the electrode by changing their scaler to 0
    ind = unique([find(AllLocs(1,:)<(0.735) & AllLocs(2,:)>(-0.865)),find(sqrt(AllLocs(1,:).^2 + (AllLocs(2,:)+0.865).^2)<.735)]);
    scalers(:,ind) = 0;
    scalers = reshape(scalers,4,numneu,numsecs);
    
    %% Load in the neuron solutions and make an LFP
    for j = 1:size(synchcenters,1);
        
        delta = deltas(j);
        if size(synchcenters,1) > 1
            synchcenter = synchcenters(j,:)+synchoffset;
        else
            % Center of contact 1
        	synchcenter = (((OleadvectorR(2,:).*2.2)+OleadvectorR(1,:))./3.2)+synchoffset;
        end
        
        for i = 1:length(rads);
            radius = rads(i);
            check = [0,0];
            synchpoolindex = 1;
            randpoolindex = 1;
            lfp = zeros(1000,4);
            tic
            runtime = 0;
            for nrn = 1:numneu                
                
                if mod(nrn,round(numneu/100)) == 0
                    disp(strcat([num2str(round(nrn/numneu*100)),'% done. ',num2str(nrn),'/',num2str(numneu),' took ',num2str(toc),'s']))
                    runtime = runtime+toc;
                    tic
                end
                
                if  sqrt(sum((nrnlocsR(nrn,1:3)-synchcenter).^2)) < radius
                    check(1) = check(1)+1;
                    nrnnum = synchpoolindex;
                    pool = '6';
                    if synchpoolindex > 10000
                        synchpoolindex = 1;
                        nrnnum = 1;
                    else
                        synchpoolindex = synchpoolindex+1;
                    end
                else
                    check(2) = check(2)+1;
                    nrnnum = randpoolindex;
                    pool = '15';
                    if randpoolindex > 3000
                        randpoolindex = 1;
                        nrnnum = 1;
                    else
                        randpoolindex = randpoolindex+1;
                    end
                end
                
                potfname = strcat(lfpdir,'pool\sig_',pool,'_N_',num2str(nrnnum),'.bin');
                fileIDp = fopen(potfname,'r');
                secpots = fread(fileIDp,[1000 numsecs],'double');
                fclose(fileIDp);
                
                scaledpots(:,:,1) = bsxfun(@times,secpots,squeeze(scalers(1,nrn,:))');
                scaledpots(:,:,2) = bsxfun(@times,secpots,squeeze(scalers(2,nrn,:))');
                scaledpots(:,:,3) = bsxfun(@times,secpots,squeeze(scalers(3,nrn,:))');
                scaledpots(:,:,4) = bsxfun(@times,secpots,squeeze(scalers(4,nrn,:))');
                
                
                lfp = lfp + squeeze(sum(scaledpots,2));
               
                
                clearvars potfname fileIDp
            end
            
            %% Finish everything up
            disp(['check = ',num2str(check)])
            runtimes = [runtimes, runtime];
            disp(['runtime = ', num2str(round(runtime)),'s - expected total runtime = ',num2str(round(mean(runtimes)*numruns))]);
            
            name = [];
            
            if prod([length(rads),length(angles),length(deltas)])>1
                if length(rads) > 1
                    name = [name,'rad',num2str(radius)];
                end

                if length(angles) > 1
                    name = [name,'ang',num2str(angle)];
                end

                if length(deltas) > 1
                    name = [name,'del',num2str(delta)];
                end
            else
                name=['tempresult'];
            end

            name = [name,'.mat'];
            
            if j==1&&i==1
                time = clock;
                save(['locrepo_ang=',num2str(angle),'_',num2str(time(2)),'-',num2str(time(3)),'_',num2str(time(4)),'_',num2str(time(5)),'.mat'],'locrepo');
            end
            save(name,'check','lfp','synchcenter','radius','angle','delta');
        end
    end
end