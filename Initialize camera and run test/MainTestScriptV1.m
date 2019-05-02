%note: the only other code required to run this script is
%MangoFlyCamSettings.m
clc
clear all
close all
imaqreset;
%%
% change working directory
cd('C:\Matlabroot\Matlab Codes\Saccad Filter\Patterntest');
fps = 160; % effective framerate
fly_num = 4;
n_resttime = 5;  % length of rest trial
n_exptime = 25; % length of experimental trial
nframes = n_exptime*fps; %vid length
pause_time=0.5;
% white noise trial number
num_trial=3;
root = 'C:\Matlabroot\Matlab Codes\Saccad Filter\Patterntest\';
dirVid_Uniform = [root 'vid_Uniform\'];
dirVid_75 = [root 'vid_75\'];

%% DAQ commands
% camera commands
vid=MagnoFlyCamSettings(6220);
set(vid, 'FramesPerTrigger', 160*n_exptime);
preview(vid)
pause(pause_time);

%% start open loop panel for uniform pattern
for j=1:2
    direction = 1;
    Panel_com('set_pattern_id',1);
    pause(pause_time)
    Panel_com('set_mode',[0,0]);        %0=open,1=closed,2=fgen,3=vmode,4=pmode
    pause(pause_time)
    Panel_com('set_position', [3-j,1]);   %set starting position (xpos,ypos)
    pause(pause_time)
    
    %% video recording for uniform pattern
    i=1;
    while i<= num_trial
        %%
        disp(['Start Trial ' num2str(i)])
        tic %start measuring time
        start(vid)
        %test stuff
        wait(vid, 75)
        stop(vid) %stop measuring time
        [spin, time_VOL] = getdata(vid, vid.FramesAcquired);
        toc
        disp(strcat('Finished Trial ',num2str(i)))
        pause(pause_time)
        
        %% ------------------- save file
        while true
            R = input('Save? [y/n]: ', 's');
            try
                R = validatestring( R, { 'y', 'n' } );
                switch R
                    case 'y'
                        % Save data according to displayed pattern
                        disp('Saving...')
                        if j==1
                            save([dirVid_Uniform 'fly_' num2str(fly_num) '_trial_' num2str(i)],'spin','time_VOL');
                        end
                        if j==2
                            save([dirVid_75 'fly_' num2str(fly_num) '_trial_' num2str(i)],'spin','time_VOL');
                            disp('Saved')
                        end
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
end