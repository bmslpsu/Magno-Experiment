clc
clear all
close all
daqreset;
imaqreset;
%% sets up the daq session. Here i am using a single output to trigger the camera
devices=daq.getDevices; %check if device is connected
if isempty(devices)
    warning('No devices were detected')
else
    get(devices)
end
%Start Daq Session
session =daq.createSession('mcc');
A_Out1=addAnalogOutputChannel(session,'Board0','ao1','Voltage');
session.IsContinuous=false; %keeps the session going 

%% turn on the camera 
vid=MagnoFlyCamSettings(8000);
set(vid, 'FramesPerTrigger', 100*5);
preview(vid)

%%
outputData1=[zeros(1000,1)' 5*ones(3000,1)' zeros(1000,1)']' ;
%%
queueOutputData(session,outputData1);
   %%
tic
[data, time ]=session.startForeground;
toc
stop(vid)
[spin time_VOL] = getdata(vid, vid.FramesAcquired);