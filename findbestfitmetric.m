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


load('<file for the completed raw LFP>')

Fs = 422;
win = 200;
olap = 100;

[EPow1,~] = pwelch(RightProced(:,1),win,win*.5,Fs*2,Fs);
[EPow2,~] = pwelch(RightProced(:,2),win,win*.5,Fs*2,Fs);
[EPow3,~] = pwelch(RightProced(:,3),win,win*.5,Fs*2,Fs);

METpercentsE = [sum(EPow1(30:44))/sum(EPow1),sum(EPow2(30:44))/sum(EPow2),sum(EPow3(30:44))/sum(EPow3)];
[~, order] = sort([METpercentsE]);

directory = '<directory where you store all your parameterized results from the runs of your LFP model; the results from coupled7.m>';

for rad = 2:.4:3.2
    for del = 0:.1:1;
        name = ['rad',num2str(rad),'del',num2str(del),'.mat'];
        load([directory,'\',name])
        lfpref = [lfp(:,2)-lfp(:,1),lfp(:,3)-lfp(:,2),lfp(:,4)-lfp(:,3)];
        reref = resample(lfpref,422,1000);

        [MPow1(:,j),~] = pwelch(reref(:,1),win,win*.5,Fs*2,Fs);
        [MPow2(:,j),~] = pwelch(reref(:,2),win,win*.5,Fs*2,Fs);
        [MPow3(:,j),~] = pwelch(reref(:,3),win,win*.5,Fs*2,Fs);

        Fcor1 = corrcoef(log(MPow1),log(EPow1));
        Fcor2 = corrcoef(log(MPow2),log(EPow2));
        Fcor3 = corrcoef(log(MPow3),log(EPow3));

        METpercentsM = [sum(MPow1(30:44))/sum(MPow1),sum(MPow2(30:44))/sum(MPow2),sum(MPow3(30:44))/sum(MPow3)];



        % [Max/Min, Max/Mid, Mid/Min 
        ExpRatios = [METpercents(order(3))/METpercents(order(1)),METpercents(order(3))/METpercents(order(2)),METpercents(order(2))/METpercents(order(1))];
        ModRatios = [METpercents2(order(3))/METpercents2(order(1)),METpercents2(order(3))/METpercents2(order(2)),METpercents2(order(2))/METpercents2(order(1))];
        
        
        TestNums = 0.1:0.01:10;
        A = 1;
        test(round(Modnum*10),1) = 1.25*((exp(-((log(TestNums)-log(Modnum))/A).^2))*1/(A*sqrt(pi))-(1/sqrt(pi))+.4);


        maxcohs(j,i,1:3) = [Fcor1(2),Fcor2(2),Fcor3(2)];
    end
    repos(j,:,:) = reref;

end

test = squeeze(mean(squeeze(max(maxcohs,[],2)),2));
CohMet = (test-min(test))/(max(test)-min(test))/2;

METmeans = [mean(EPow1(30:44)),mean(EPow2(30:44)),mean(EPow3(30:44))];
METpercents = [sum(EPow1(30:44))/sum(EPow1),sum(EPow2(30:44))/sum(EPow2),sum(EPow3(30:44))/sum(EPow3)];
METmeans2 = [mean(MPow1(30:44)),mean(MPow2(30:44)),mean(MPow3(30:44))];
METpercents2 = [sum(MPow1(30:44))/sum(MPow1),sum(MPow2(30:44))/sum(MPow2),sum(MPow3(30:44))/sum(MPow3)];

[~, order] = sort([METpercents]);


% [Max/Min, Max/Mid, Mid/Min 
ExpRatios = [METpercents(order(3))/METpercents(order(1)),METpercents(order(3))/METpercents(order(2)),METpercents(order(2))/METpercents(order(1))];
ModRatios = [METpercents2(order(3))/METpercents2(order(1)),METpercents2(order(3))/METpercents2(order(2)),METpercents2(order(2))/METpercents2(order(1))];

figure;bar(METmeans)
figure;bar(METmeans2)
figure;bar(METpercents)
figure;bar(METpercents2)





test = mean(abs(maxcors),3);
[ab,ac] = find(test==max(max(test)));

xax = 1/422:1/422:1;
plot(xax,RightProced(ac:ac+421,:))
ymax = max(max(abs(RightProced(ac:ac+421,:))));
axis([0 1 -ymax ymax])
figure;plot(xax,squeeze(repos(ab,:,:)))
ymax = max(max(abs(repos(ab,:,:))));
axis([0 1 -ymax ymax])

smooov = 18;

tp = randi(1105-422,1);
[pksE,locsE] = findpeaks(RightProced(tp:tp+421,1),'MinPeakDistance',15);
[pksM,locsM] = findpeaks(reref(:,1),'MinPeakDistance',15);

figure;plot(RightProced(tp:tp+421,1));hold;
scatter(locsE,pksE)
figure;plot(reref(:,1));hold;
scatter(locsM,pksM)