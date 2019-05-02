%this was done to see why the camera is delaying in recording
clc
clear all
close all
imaqreset

%%
vid=MagnoFlyCamSettings(1284);


set(vid, 'FramesPerTrigger', 750*16);

triggerconfig(vid, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
triggerconfig(vid, 'immediate');
preview(vid)
flushdata(vid, 'all')


%%

start(vid)
%tic %start measuring time
wait(vid, 75)
%toc %this gives a larger time than the time given byu the camera
stop(vid)
[spin, time_VOL, meta] = getdata(vid);
pause(1)

%%
time_VOL(1)
time_VOL(end)
time_VOL(end)-time_VOL(1)
size(time_VOL)/(time_VOL(end)-time_VOL(1))
16*750/(length(time_VOL)/(time_VOL(end)-time_VOL(1)))

%% 
for i=1:length(time_VOL)-1
    time_delta(i)=time_VOL(i+1)-time_VOL(i);
end

%%
[a b]=max(time_delta)

%% 
j=0;


time_f=[];
time_f2=[];
std_dev=std(time_delta);
mean_time=mean(time_delta);

for i=1:length(time_delta)
    if time_delta(i)>mean_time+3*std_dev
        time_f=[time_delta(i) time_f];
        j=1+j;
    end
end
%%
h1=histfit(time_delta);
set(h1(1),'facecolor','g'); set(h1(2),'color','m')
xlim([0*10^-3, 6.5*10^-3])
%% 160 frames per second 
imaqreset
clear vid
vid2=MagnoFlyCamSettings(6000);
set(vid2, 'FramesPerTrigger', 750*16);
triggerconfig(vid2, 'immediate');
flushdata(vid2, 'all')

%%
start(vid2)
wait(vid2,75)
stop(vid2)
%%
[spin2, time_VOL2, meta2] = getdata(vid2);

for i=1:length(time_VOL2)-1
    time_delta2(i)=time_VOL2(i+1)-time_VOL2(i);
end
%%
clc
time_VOL2(1)
time_VOL2(end)
time_VOL2(end)-time_VOL2(1)
size(time_VOL2)/(time_VOL2(end)-time_VOL2(1))
16*165/(length(time_VOL2)/(time_VOL2(end)-time_VOL2(1)))
%%
[a2 b2]=max(time_delta2)
j2=0;
std_dev2=std(time_delta2);
mean_time2=mean(time_delta2);
for i=1:length(time_delta2)
    if time_delta2(i)>mean_time2+3*std_dev2
        time_f2=[time_delta2(i) time_f2];
        j2=1+j2;
    end
end
%%
figure
histfit(time_delta2)


%%
figure
h1=histfit(time_delta);
set(h1(1),'facecolor','g'); set(h1(2),'color','b')
hold on
histfit(time_delta2)
xlim([0*10^-3, 6.5*10^-3])
xlabel('Time between each frame')
