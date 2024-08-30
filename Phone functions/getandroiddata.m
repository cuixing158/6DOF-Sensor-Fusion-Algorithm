function [t, acc, gyro, mag, gps, orientation,lin_acc,grav,press]=getandroiddata(phonelistener)
% Brief: 从UDP监听器获取传感器数据
% Details:
%    目前在安卓上无法返回得到 gps, orientation,lin_acc,grav,press这些参数?!
%
% Inputs:
%    phonelistener - [1,1] size,[UDPPort] type,see udpport build-in
%    function return object.
% 
% Outputs:
%    t - [1,1] size,[datetime] type,Description
%    acc - [1,3] size,[double] type,Description
%    om - [1,3] size,[double] type,Description
%    mag - [m,n] size,[double] type,Description
%    gps - [m,n] size,[double] type,Description
%    or - [m,n] size,[double] type,Description
%    lin_acc - [m,n] size,[double] type,Description
%    grav - [m,n] size,[double] type,Description
%    press - [m,n] size,[double] type,Description
% 
% Example: 
%    None
% 
% See also: None

% Author:                          cuixingxing
% Email:                           cuixingxing150@gmail.com
% Created:                         30-Aug-2024 14:58:13
% Version history revision notes:
%                                  None
% Implementation In Matlab R2024a
% Copyright © 2024 TheMatrix.All Rights Reserved.
%

try
    data=read(phonelistener,1,'string');
    try
        data=data.Data{:};
    catch
        data=[];
    end
catch 
    data = fscanf(phonelistener); % matlab release older than R2020b
end


%     acc=3;
%     gyro=4;
%     mag=5;
%     or=81;
%     linacc=82;
%     grav=83;
%     rotvect=84
%     temp=86;
%     press=85;

t       = nan;
acc     = nan(1,3);
gyro      = nan(1,3);
mag     = nan(1,3);
gps     = nan(1,3);
orientation      = nan(1,3);
lin_acc = nan(1,3);
grav    = nan(1,3);
press   = nan;

sepp    = [strfind(data,',') length(data)];
ind_acc = strfind(data,', 3,');
ind_om  = strfind(data,', 4,');
ind_mag = strfind(data,', 5,');
ind_gps = strfind(data,'onbekend');
ind_or  = strfind(data,', 81,');
ind_linacc  = strfind(data,', 82,');
ind_grav  = strfind(data,', 83,');
ind_press  = strfind(data,', 85,');


t       = str2double(data(1:sepp(1)));

if t<1000 || size(sepp,2)==1
    t=nan;
    return
end

if ~isempty(ind_acc) && length(find(sepp>ind_acc(1)))>=4
    ind_acc = find(sepp>ind_acc(1),1,'first');
    acc     = [str2double(data(sepp(ind_acc)+1:sepp(ind_acc+1)-1)) str2double(data(sepp(ind_acc+1)+1:sepp(ind_acc+2)-1)) str2double(data(sepp(ind_acc+2)+1:sepp(ind_acc+3)-1))   ]  ;
end

if ~isempty(ind_om) && length(find(sepp>ind_om(1)))>=4
    ind_om = find(sepp>ind_om,1,'first');
    gyro     = [str2double(data(sepp(ind_om)+1:sepp(ind_om+1)-1)) str2double(data(sepp(ind_om+1)+1:sepp(ind_om+2)-1)) str2double(data(sepp(ind_om+2)+1:sepp(ind_om+3)-1))   ]  ;
end
if ~isempty(ind_mag)&& length(find(sepp>ind_mag(1)))>=4
    ind_mag = find(sepp>ind_mag,1,'first');
    mag     = [str2double(data(sepp(ind_mag)+1:sepp(ind_mag+1)-1)) str2double(data(sepp(ind_mag+1)+1:sepp(ind_mag+2)-1)) str2double(data(sepp(ind_mag+2)+1:sepp(ind_mag+3)-1))   ]  ;
end

if ~isempty(ind_gps)&& length(find(sepp>ind_gps(1)))>=4
    ind_gps = find(sepp>ind_gps,1,'first');
    gps     = [str2double(data(sepp(ind_gps)+1:sepp(ind_gps+1)-1)) str2double(data(sepp(ind_gps+1)+1:sepp(ind_gps+2)-1)) str2double(data(sepp(ind_gps+2)+1:sepp(ind_gps+3)-1))   ]  ;
end

if ~isempty(ind_or)&& length(find(sepp>ind_or(1)))>=4
    ind_or = find(sepp>ind_or,1,'first');
    orientation     = [str2double(data(sepp(ind_or)+1:sepp(ind_or+1)-1)) str2double(data(sepp(ind_or+1)+1:sepp(ind_or+2)-1)) str2double(data(sepp(ind_or+2)+1:sepp(ind_or+3)-1))   ]  ;
end

if ~isempty(ind_linacc)&& length(find(sepp>ind_linacc))>=4
    ind_linacc = find(sepp>ind_linacc,1,'first');
    lin_acc     = [str2double(data(sepp(ind_linacc)+1:sepp(ind_linacc+1)-1)) str2double(data(sepp(ind_linacc+1)+1:sepp(ind_linacc+2)-1)) str2double(data(sepp(ind_linacc+2)+1:sepp(ind_linacc+3)-1))   ]  ;
end

if ~isempty(ind_grav)&& length(find(sepp>ind_grav))>=4
    ind_grav = find(sepp>ind_grav,1,'first');
    grav     = [str2double(data(sepp(ind_grav)+1:sepp(ind_grav+1)-1)) str2double(data(sepp(ind_grav+1)+1:sepp(ind_grav+2)-1)) str2double(data(sepp(ind_grav+2)+1:sepp(ind_grav+3)-1))   ]  ;
end

if ~isempty(ind_press)&& length(find(sepp>ind_press))>=1
    ind_press = find(sepp>ind_press,1,'first');
    press     = [str2double(data(sepp(ind_press)+1:sepp(ind_press+1)-1)) ]  ;
end