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


lfpref = lfp(:,3)-lfp(:,2);
[b,a] = butter(1,20/500,'low');
%[b,a] = cheby1(1,.5,4/500,'low');
ModelF = filtfilt(b,a,lfpref);

[b,a] = butter(1,3/500,'high');
ModelF2 = filtfilt(b,a,ModelF);

Fs = 422;

dsmodel = resample(ModelF2,Fs,1000);
    
[p,f] = pwelch(dsmodel,round(Fs/1),round((Fs/1)*.8),Fs,Fs);
figure;plot(f(1:100),log(p(1:100)),'Color','k','LineWidth',4);


spect = abs(fft(dsmodel,Fs));
spect = spect(1:Fs/2);
figure;plot(spect)

[p,f] = pwelch(lfpref,1000,500,2000,1000);
figure;plot(f,log(p.*(f.^1)))

%axis([0 100 -16 -8])
%pwelch(lfp(6770:6770+422,1),Fs,Fs/2,Fs,Fs);

Fs = 422;
Time = 6770;
Win = Fs;
olap = .5;

[P1,f] = pwelch(RightProced(Time:Time+Fs,1),Win,olap,Fs,Fs);
Time = 6570;
[P2,f] = pwelch(RightProced(Time:Time+Fs,2),Win,olap,Fs,Fs);
[P3,f] = pwelch(RightProced(Time:Time+Fs,3),Win,olap,Fs,Fs);

figure;plot(f,log(P1),'Color','k','LineWidth',6);axis([1,100,-24,-11]);
figure;plot(f,log(P2),'Color','k','LineWidth',6);axis([1,100,-24,-11]);
figure;plot(f,log(P3),'Color','k','LineWidth',6);axis([1,100,-24,-11]);

