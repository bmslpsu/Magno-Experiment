daqreset;
imaqreset;
%%
imaqInfo=imaqhwinfo; %function uswed to find adaptor info ie camera
hwInfo = imaqhwinfo('gentl'); %check DeviceInfo for code filling
device1 =hwInfo.DeviceInfo(1);
device1.DeviceName;
device1.DefaultFormat;

vidobj=videoinput('gentl',1); %create video input
get(vidobj) %lists video input properties and values 
%%
% Access the currently selected video source object
%this is what i usually modify in the image aq toolbox
src = getselectedsource(vidobj);
% List the video source object's properties and their current values.
get(src)
%%
%get enumerated values
set(vidobj)

%%
% List the video source object's configurable properties.
set(src)

%%
vid = videoinput('gentl',1,'Mono8');
vid_src = getselectedsource(vid);
vid_src.Tag = 'Fly Detection';
figure; 
%%
start(vid)
pause(.5)
stop(vid)
vid_data=getdata(vid);
size(vid_data)
% data=getdata(vid,1);     
% imshow(data)
% stop(vid)
% 
% delete(vid)
% clear
% close(gcf)