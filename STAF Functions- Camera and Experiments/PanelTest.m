clc
clear all
tic
disp('rest');
Panel_com('stop');
Panel_com('set_pattern_id', 1);      % set output to p_rest_pat
Panel_com('set_position',[1, 1]);   % set starting position (xpos,ypos)
Panel_com('set_mode',[4,0]);      	%mode 4 is used to run a function stored on SD
Panel_com('set_posfunc_id',[1,1]);  %[position function for x, position ft number]
Panel_com('set_funcX_freq', 50);
Panel_com('start');
pause(15.6)
Panel_com('stop');
toc