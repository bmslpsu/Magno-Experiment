daqreset;
imaqreset;
daq.getDevices
%%
root = 'C:\Matlabroot\Matlab Codes\MagnoScript\';
dirPos = [root 'pos\'];
dirVid = [root 'vid\'];
%%
session =daq.createSession('mcc');
AI0=addAnalogInputChannel(session, 'Board0','ai0','Voltage');
AI0.Range=[-10 10];
session.IsContinuous=true; %keeps the session going session longer
%%
fid1 = fopen('log.bin','w');
lh = addlistener(session,'DataAvailable',@(src,event)logData(src,event,fid1));
startBackground(session);
pause(2)
stop(session)
fclose(fid1);
fid2=fopen('log.bin','r');
[data, count]=fread(fid2,[2,Inf],'double');
time_stamp=data(1,:);
position_data=data(2,:);
save([dirPos 'fly_' num2str(1) '_trial_' num2str(1)],'position_data','time_stamp');