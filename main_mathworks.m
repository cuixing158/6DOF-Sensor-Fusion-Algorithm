%% 使用MATLAB官方APP实时流传感器传输数据
% 不要传入手机实时图像，太卡
%
if ~exist("m","var")
    m= mobiledev;
end

%%
m.Logging=1;
m.SampleRate = 50;
m.AccelerationSensorEnabled = 1;
m.AngularVelocitySensorEnabled = 1;
m.OrientationSensorEnabled = 1;


%% Initialise empty figure and empty variables
fig = figure(Name="mobile stream sensor data");
ax = axes(fig);
grid(ax,"on");
an1 = animatedline(ax,NaT,NaN,"Color","red","LineWidth",2,'MaximumNumPoints',1000);
an2 = animatedline(ax,NaT,NaN,"Color","blue","LineWidth",2,'MaximumNumPoints',1000);
an3 = animatedline(ax,NaT,NaN,"Color","green","LineWidth",2,'MaximumNumPoints',1000);
legend(ax,[an1,an2,an3],["x","y","z"])

fig2 = figure(Name="pose plot");
nexttile;
ax2 = gca;
patch = poseplot(ax2);
xlabel("North-x (m)")
ylabel("East-y (m)")
zlabel("Down-z (m)");


%% Loop to start data collection
while(isvalid(fig)&&isvalid(fig2))

    % [acc,t] =accellog(m);
    acc = m.Acceleration;
    orientation = m.Orientation;

    if ~isempty(orientation)
        % 使用 eul2quat 函数
        yaw = orientation(1);
        pitch = orientation(2);
        roll = orientation(3);
        rotm = eul2rotm([yaw, pitch, roll] * (pi/180), 'ZYX'); % 将角度转换为弧度
        rotm = roty(-180)*rotz(-90)*rotm; % 2024.9.2由rotx(-180)改为了roty(-180),待传感器弄好后验证正确性！？
        % q = eul2quat([yaw, pitch, roll] * (pi/180), 'ZXY'); % 将角度转换为弧度
        set(patch,Orientation=rotm);
    end

    if ~isempty(acc)
        % plot here
        addpoints(an1,datetime("now"),acc(1));
        addpoints(an2,datetime("now"),acc(2));
        addpoints(an3,datetime("now"),acc(3));
    end

    drawnow limitrate
end

%%
function R = rotx(deg)
% 绕X轴的旋转矩阵
R = [1,0,0;
    0,cosd(deg),-sind(deg);
    0,sind(deg),cosd(deg)];
end

function R = roty(angleY)
% 绕Y轴的旋转矩阵
R = [cosd(angleY), 0, sind(angleY);
    0, 1, 0;
    -sind(angleY), 0, cosd(angleY)];
end
function R = rotz(angleZ)
% 绕Z轴的旋转矩阵
R = [cosd(angleZ),-sind(angleZ),0;
    sind(angleZ),cosd(angleZ),0;
    0,0,1];
end
