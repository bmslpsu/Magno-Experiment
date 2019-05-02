function vidobj=MagnoFlyCamSettings(FPS)
% the input to the function is frames per second
%1280 is around 750 frames. 5000 is around 210.


% Device Properties.
adaptorName = 'gentl';
deviceID = 1;
vidFormat = 'Mono8';
tag = '';
existingObjs1 = imaqfind('DeviceID', deviceID, 'VideoFormat', vidFormat, 'Tag', tag);
%%
if isempty(existingObjs1)
    % If there are no existing video input objects, construct the object.
    vidobj = videoinput(adaptorName, deviceID, vidFormat);
else
    for i = 1:length(existingObjs1)
        objhwinfo = imaqhwinfo(existingObjs1{i});
        if strcmp(objhwinfo.AdaptorName, adaptorName)
            vidobj = existingObjs1{i};
            break;
        elseif(i == length(existingObjs1))
            % We have queried through all existing objects and no
            % AdaptorName values matches the AdaptorName value of the
            % object being recreated. So the object must be created.
            vidobj = videoinput(adaptorName, deviceID, vidFormat);
        end %if
    end %for
end %if
%%
set(vidobj, 'ErrorFcn', @imaqcallback);
%%
% Configure vidobj properties.
set(vidobj, 'FramesPerTrigger', Inf);

set(vidobj, 'LoggingMode', 'memory');
set(vidobj,'FrameGrabInterval',1);% capture every Nth frame
triggerconfig(vidobj,'hardware','risingEdge', 'digitalTrigger') %this was modified for the basler camera

% Configure vidobj's video source properties.
srcObj1 = get(vidobj, 'Source');

set(srcObj1(1), 'Gain', 12);
set(srcObj1(1), 'Gamma', .7);
set(srcObj1(1),'ExposureTime',FPS) %1284 is almost 750 fps
set(srcObj1(1), 'BlackLevel',19.25)
set(srcObj1(1),'AcquisitionFrameRate', 750)
set(srcObj1(1),'DeviceLinkThroughputLimit', 419430400/1) %max is 419430400
%set( srcObj1(1),'TriggerMode', 'On');
vidobj.ROIPosition = [185 97 331 313];

 end