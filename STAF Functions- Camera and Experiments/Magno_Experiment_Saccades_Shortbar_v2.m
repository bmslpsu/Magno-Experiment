% Magno experiment script
% This experiment repeats experiment from Theobald et al. 2008
% J-M Mongeau
daqreset;
imaqreset;

%PControl;
% change working directory
cd('C:\Matlabroot\Matlab Codes\MagnoScript');

fps = 100; % effective framerate
%can go up to 1000

% FLY NUMBER
fly_num = 7;

nreps = 5; % number of reps
% ntrial = 6*6;     % total number of trials
n_resttime = 5;  % length of rest trial
n_exptime = 25; % length of experimental trial

root = 'C:\Matlabroot\Matlab Codes\MagnoScript\';
dirPos = [root 'pos\'];
dirVid = [root 'vid\'];

nframes = 25*fps;  % length of spin trial in frames = 25s

%Set up data acquisition on MC DAQ:
AI = analoginput('nidaq','Dev2');
addchannel(AI,[0 1]);
set(AI,'SampleRate',1000);
AI.SamplesPerTrigger = inf;
AI.TriggerRepeat = inf;
AI.TriggerType = 'Manual';
AI.InputType = 'Differential';
%set(AI,'TransferMode','SingleDMA')

set(AI,'LoggingMode','Memory')

[vid] = MagnoFlyCamSettingsJM_NEW_scA640_120fm();
%vid.FramesPerTrigger = nframes;
set(vid, 'FramesPerTrigger', nframes);

%Start objects
preview(vid)
pause(0.5);

%%

%%% Spin using expansion/contraction stimulus
tic
direction = 1;
disp('spin_fly');
Panel_com('set_pattern_id',1);
pause(0.1)
Panel_com('set_mode',[0,0]);        %0=open,1=closed,2=fgen,3=vmode,4=pmode
pause(0.1)
Panel_com('set_position', [48,1]);   %set starting position (xpos,ypos)
pause(0.1)
Panel_com('send_gain_bias',[direction*20,0,0,0]); %[xgain,xoffset,ygain,yoffset]
pause(0.1)
Panel_com('start');
start(vid)
wait(vid, 75)
spin = getdata(vid);
Panel_com('stop');
stop(vid)
disp('Finished Spin')
toc

%% Save spin for centroid detection
save([root 'Centroid\spin_fly_' num2str(fly_num)], 'spin');
clear spin
disp('Saved Spin')

%% Main Loop
% Reset trigger setting for camera
triggerconfig(vid, 'manual')
vid.FramesPerTrigger = Inf;

% trial index
mm = 1;

%trial = [randperm(4) randperm(4) randperm(4) randperm(4) randperm(4) randperm(4)];


kk = 1;

%%
for jj = 1:nreps
    
    trial = [1 20; 1 -20; 8 20; 8 -20]; % cycle through [pattern_ID bar_height direction]
    trial_ALL = repmat(trial, 1, 1);
    trial_bank = trial_ALL(randperm(size(trial_ALL,1)), :); % reshuffle randomly
    kk = 1;
    
    while kk <= size(trial_bank,1)
        
        % Generate random number for ypos to change spatial frequency
        % Rsize = floor(1 + (6-1+1).* rand(1));
        % Generate random number for position of tracking bar
        Rpos = floor(1 + (96-1+1).* rand(1));
        % Generate random number for direction of motion of tracking bar
        barH = trial_bank(kk, 1); % bar height
        vel = trial_bank(kk, 2); % bar velocity
        
        %Start objects
        start(AI)       %start DAQ
        start(vid)
        pause(0.2)
        
        switch trial_bank(kk,1)
            
            % FOURIER BAR OVER RANDOM GROUND
            case 8
                Rsize = 8;
                disp('Tall bar');
                disp(mm);
                pause(0.1)
                Panel_com('set_pattern_id',1);        %set output to p_rest_pat
                pause(0.1)
                Panel_com('set_position',[Rpos,barH]); %set pattern wavelength (xpos,ypos)
                pause(0.1)
                Panel_com('set_mode',[0,0]);                   %0=open,1=closed,2=fgen,3=vmode,4=pmode
                pause(0.1)
                Panel_com('send_gain_bias',[vel,0,0,0]);       %[xgain,xoffset,ygain,yoffset]
                pause(0.1)
                
                % DARK BAR OVER UNIFORM GROUND
            case 1
                Rsize = 1;
                disp('Short bar');
                disp(mm);
                pause(0.2)
                pause(0.1)
                Panel_com('set_pattern_id',1);        %set output to p_rest_pat
                pause(0.1)
                Panel_com('set_position',[Rpos,barH]); %set pattern wavelength (xpos,ypos)
                pause(0.1)
                Panel_com('set_mode',[0,0]);                   %0=open,1=closed,2=fgen,3=vmode,4=pmode
                pause(0.1)
                Panel_com('send_gain_bias',[vel,0,0,0]);       %[xgain,xoffset,ygain,yoffset]
                pause(0.1)
                
        end
        
        trigger(vid)
        trigger(AI)
        pause(0.2)
        
        Panel_com('start');
        pause(n_exptime);
        
        stop(vid);
        stop(AI);
        
        pause(0.2)
        Panel_com('stop');
        pause(0.2)
        
        beep;
        
        while true
            
            R = input('Save? [y/n]: ', 's');
            
            try
                
                R = validatestring( R, { 'y', 'n' } );
                
                switch R
                    
                    case 'y'
                        
                        % Get data
                        [posData t_p] = getdata(AI, AI.SamplesAcquired);
                        [vidData t_v] = getdata(vid, vid.FramesAcquired);
                        
                        % Save data according to wavelength and direction
                        disp('Saving...')                        
                        
                        save([dirPos 'fly_' num2str(fly_num) '_trial_' num2str(mm)...
                            '_bar_' num2str(Rsize) '_vel_' num2str(vel)],'-v7.3','posData','t_p');
                        save([dirVid 'fly_' num2str(fly_num) '_trial_' num2str(mm)...
                            '_bar_' num2str(Rsize) '_vel_' num2str(vel)],'-v7.3','vidData','t_v');                        
                        
                        kk = kk + 1;
                        mm = mm + 1;      
                end 
            catch 
                warning('Did not understand input. Try again')
                continue   
            end
            break  
        end
        clear posData t_p vidData t_v  
    end
end