% main example file for using matlab to stream phone data. Note that this
% file only readse out accelerometer data. For full list of sensors that
% can be read out, see getandroiddata and getappledata
%% Copyright
%     COPYRIGHT (c) 2017 Sjoerd Bruijn, VU University Amsterdam
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%% version history; march 2017, Sjoerd Bruijn (SMB) updated from older versions by SMB, to make suitable
% for general use (i.e. proper commenting, cleanup of code, etc)

%% Resetting MATLAB environment
 clear ; close all; clc
addpath('Phone functions');

%% create phone listener object: Android
phonelistener   = makeandroidlistener();

%% create phone listener object: Apple
% IpAdress      = '192.168.1.67'; % in case of apple, this is the IP adress
% of the phone!!
% Port          = 57100;
% phonelistener = makeapplelistener(IpAdress,Port);
%% Initialise empty figure and empty variables
fig = figure(Name="mobile stream sensor data");
ax = axes(fig);
grid(ax,"on");
an1 = animatedline(ax,NaT,NaN,"Color","red","LineWidth",2,'MaximumNumPoints',1000);
an2 = animatedline(ax,NaT,NaN,"Color","blue","LineWidth",2,'MaximumNumPoints',1000);
an3 = animatedline(ax,NaT,NaN,"Color","green","LineWidth",2,'MaximumNumPoints',1000);
legend(ax,[an1,an2,an3],["x","y","z"])

fig2 = figure(Name="pose plot");
ax2 = axes(fig2);
patch = poseplot(ax2);
xlabel("North-x (m)")
ylabel("East-y (m)")
zlabel("Down-z (m)");

%% Loop to start data collection
while(isvalid(fig))
    
    %% Apple: sensorlog
    % [t,acc]    = getappledata(phonelistener);
    
    %% Android: IMU+GPS Stream
    [t, acc, gyro, mag, gps, orientation,lin_acc,grav,press]= getandroiddata(phonelistener);
   
    if ~any(isnan(orientation))
        % 使用 eul2quat 函数
        orientation = deg2rad(orientation);
        yaw = orientation(3);
        pitch = orientation(2);
        roll = orientation(1);
        q = eul2quat([yaw, pitch, roll] * (pi/180), 'ZYX'); % 将角度转换为弧度
        set(patch,Orientation=q);
    end
    
    %% plot here
    addpoints(an1,datetime("now"),acc(1));
    addpoints(an2,datetime("now"),acc(2));
    addpoints(an3,datetime("now"),acc(3));
    

    drawnow limitrate
end
%% Closing and deleting connections (keep these in your program!)
fclose(phonelistener);%Closing UDP communication
delete(phonelistener);%Deleting UDP communication

