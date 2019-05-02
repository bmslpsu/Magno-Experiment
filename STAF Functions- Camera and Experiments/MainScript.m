%note: the only other code required to run this script is
%MangoFlyCamSettings.m
clc
clear all
close all
daqreset;
imaqreset;
%%

% change working directory
cd('C:\Matlabroot\Matlab Codes\WaelsCodes\MagnoScript');

fps = 750; % effective framerate


fly_num = 30;

Num_Trails = 5; % number of reps
n_resttime = 5;  % length of rest trial
n_exptime = 15.6; % length of experimental trial
nframes = n_exptime*fps; %vid length
pause_time=0.5;
% white noise trial number
num_trial=5;
root = 'C:\Matlabroot\Matlab Codes\WaelsCodes\MagnoScript\';
dirPos = [root 'pos\'];
dirVid = [root 'vid\'];

%% DAQ commands
devices=daq.getDevices; %check if device is connected
if isempty(devices)
    warning('No devices were detected')
else
    get(devices)
end
%Start Daq Session
session =daq.createSession('mcc');
AI0=addAnalogInputChannel(session, 'Board0','ai0','Voltage');
AI0.Range=[0 10];
AI0.TerminalConfig='SingleEnded';
session.IsContinuous=true; %keeps the session going 


% camera commands
vid=MagnoFlyCamSettings(1284);
set(vid, 'FramesPerTrigger', 750*25.5);
preview(vid)
pause(pause_time);

%% start open loop panel

fid1 = fopen('log.bin','w');
lh = addlistener(session,'DataAvailable',@(src,event)logData(src,event,fid1));
disp('Open loop trail starting')
direction = 1;
disp('spin_fly');
Panel_com('set_pattern_id',1);
pause(pause_time)
Panel_com('set_mode',[0,0]);        %0=open,1=closed,2=fgen,3=vmode,4=pmode
pause(pause_time)
Panel_com('set_position', [1,1]);   %set starting position (xpos,ypos)
pause(pause_time)
Panel_com('send_gain_bias',[direction*20,0,0,0]); %[xgain,xoffset,ygain,yoffset]
pause(pause_time)
Panel_com('set_posfunc_id',[0,0]);  %[position function for x, position ft number]
pause(pause_time/2);
Panel_com('set_funcX_freq', 50);
pause(pause_time)
tic %start measuring time
start(vid)
startBackground(session);
Panel_com('start');
%test stuff
wait(vid, 75)
stop(vid) %stop measuring time
stop(session) %stops daq session
[spin time_VOL] = getdata(vid, vid.FramesAcquired);
pause(pause_time)
Panel_com('stop');
pause(pause_time)

toc
disp(strcat('Finished Trial ',num2str(1)))
pause(pause_time)

%obtain data from daq
fclose(fid1);
fid2=fopen('log.bin','r');
[data, count]=fread(fid2,[2,Inf],'double'); %data has position of pattern and time
pause(pause_time)
disp('Finished Spin')

%% Save spin for centroid detection
disp('Saving open loop trial')
save([root 'Centroid\spin_fly_' num2str(fly_num)], 'spin','time_VOL','-v7.3');
clear spin
disp('Saved Trial')
%%
set(vid, 'FramesPerTrigger', nframes);
pause(n_resttime)
i=1;
while i<=num_trial
    
    disp(strcat('Trail Number',num2str(i)))
    
    %data aq part
    fid1 = fopen('log.bin','w');
    lh = addlistener(session,'DataAvailable',@(src,event)logData(src,event,fid1));
    
    
    pause(pause_time)
    
    %starts the pattern and starts moving it
    disp('rest and initialize panels');
    Panel_com('stop');
    pause(pause_time)
    Panel_com('set_pattern_id', 1);      % set output to p_rest_pat
    %pattern has 96 LEDs in x and no patterns in y so y=1
    pause(pause_time)
    Panel_com('set_position',[48, 1]);   % set starting position (xpos,ypos)
    pause(pause_time);
    Panel_com('set_mode',[4,0]);      	%mode 4 is used to run a function stored on SD
    Panel_com('set_posfunc_id',[1,1]);  %[position function for x, position ft number]
    pause(pause_time/2);
    Panel_com('set_funcX_freq', 50); %frequency
    pause(pause_time)
    tic
    start(vid)
    startBackground(session);
    Panel_com('start');
    
    wait(vid,75) %waits until vid is done or stops after 75 seconds
    toc
    stop(session) %stops daq session
    stop(vid)
    Panel_com('stop'); %stops panel

    
    
    disp(strcat('Finished Trial',num2str(i)))
    pause(pause_time)
    
    %obtain data from daq
    fclose(fid1);
    fid2=fopen('log.bin','r');
    [data, count]=fread(fid2,[2,Inf],'double');
    
    time_stamp=data(1,:);
    position_data=data(2,:);
    [vid_data time_VWN]=getdata(vid,vid.FramesAcquired);
    
    if size(data) == 0
        warning('no data collected from daq')
    end
    while true
        R = input('Save? [y/n]: ', 's');
        try  
            R = validatestring( R, { 'y', 'n' } );      
            switch R  
                case 'y'      
                    % Save data according to wavelength and direction
                    disp('Saving...') 
                    save([dirPos 'fly_' num2str(fly_num) '_trial_' num2str(i)],'position_data','time_stamp');
                    save([dirVid 'fly_' num2str(fly_num) '_trial_' num2str(i)],'vid_data','time_VWN');
                    pause(n_resttime)
                    i=i+1; 
                case 'n'    
            end
        catch
            warning('Did not understand input. Try again')
            continue
        end
        break
    end
end

