function [vidobj] = MagnoFlyCamSettingsJM_NEW_scA640_120fm()

%nframes = 90; %length of trial in frames (30fps)

% Load the MAT-file containing UserData and CallBack property values.
try
    MATvar = load('C:\Matlabroot\Matlab Codes\MagnoScrip\Camera_Parameters.mat');
    MATLoaded = true;
catch
    warnMsg = (['MAT-file could not be loaded. Object Properties whose values',...
        'were saved in the MAT-file will instead be configured to their default value.']);
    warning(warnMsg, 'imaq:obj2mfile:MATload');
   MATLoaded = false;
end


% Device Properties.
adaptorName = 'gentl';
deviceID = 1;
vidFormat = 'Mono8';
%vidFormat = 'F7_Y8_659x494';
tag = '';

% Search for existing video input objects.
existingObjs1 = imaqfind('DeviceID', deviceID, 'VideoFormat', vidFormat, 'Tag', tag);

if isempty(existingObjs1)
    % If there are no existing video input objects, construct the object.
    vidobj = videoinput(adaptorName, deviceID, vidFormat);
else
    % There are existing video input objects in memory that have the same
    % DeviceID, VideoFormat, and Tag property values as the object we are
    % recreating. If any of those objects contains the same AdaptorName
    % value as the object being recreated, then we will reuse the object.
    % If more than one existing video input object contains that
    % AdaptorName value, then the first object found will be reused. If
    % there are no existing objects with the AdaptorName value, then the
    % video input object will be created.

    % Query through each existing object and check that their adaptor name
    % matches the adaptor name of the object being recreated.
    for i = 1:length(existingObjs1)
        % Get the object's device information.
        objhwinfo = imaqhwinfo(existingObjs1{i});
        % Compare the object's AdaptorName value with the AdaptorName value
        % being recreated.
        if strcmp(objhwinfo.AdaptorName, adaptorName)
            % The existing object has the same AdaptorName value as the
            % object being recreated. So reuse the object.
            vidobj = existingObjs1{i};
            % There is no need to check the rest of existing objects.
            % Break out of FOR loop.
            break;
        elseif(i == length(existingObjs1))
            % We have queried through all existing objects and no
            % AdaptorName values matches the AdaptorName value of the
            % object being recreated. So the object must be created.
            vidobj = videoinput(adaptorName, deviceID, vidFormat);
        end %if
    end %for
end %if

% Configure properties whose values are saved in C:\Users\Frye Lab\Documents\MATLAB\MagnoFlyCamSettings.mat.
if (MATLoaded)
    % MAT-file loaded successfully. Configure the properties whose values
    % are saved in the MAT-file.
    set(vidobj, 'ErrorFcn', MATvar.errorfcn1);
else
   % MAT-file could not be loaded. Configure properties whose values were
   % saved in the MAT-file to their default value.
    set(vidobj, 'ErrorFcn', @imaqcallback);
end

% Configure vidobj properties.
% set(vidobj, 'FramesPerTrigger', nframes); %nframes is length of trial set at top of experimental script (30fps)
set(vidobj, 'FramesPerTrigger', Inf);
set(vidobj, 'LoggingMode', 'memory');
% set(vidobj, 'ReturnedColorSpace', 'grayscale');
%set(vidobj,'FrameGrabInterval',1,'ROIPosition', [60,0,420,340]);% capture every Nth frame
%set(vidobj,'FrameGrabInterval',1,'ROIPosition', [100,70,420,340]);% capture every Nth frame
set(vidobj,'FrameGrabInterval',1,'ROIPosition', [160,100,350,350]);% capture every Nth frame
%set(vidobj,'FrameGrabInterval',1,'ROIPosition', [0,0,640,480]);% capture every Nth frame
triggerconfig(vidobj, 'immediate')

% Configure vidobj's video source properties.
srcObj1 = get(vidobj, 'Source');
set(srcObj1(1), 'ShutterMode', 'manual')
set(srcObj1(1), 'GainMode', 'manual')
% set(srcObj1(1), 'FrameRate', '60');
set(srcObj1(1), 'Brightness', 64);
set(srcObj1(1), 'Gain', 300);
%set(srcObj1(1), 'FrameRate', 120);
% These parameters (along with ROI) define the effective frame rate
%srcObj1.NormalizedBytesPerPacket = 2048; % 740 = OK; start missing frame >800
srcObj1.NormalizedBytesPerPacket = 1024; % 740 = OK; start missing frame >800
set(srcObj1(1), 'Shutter', 300); % 415 = 120fps; 277 = 180 fps

%preview(vidobj); 
%pause(2);

end