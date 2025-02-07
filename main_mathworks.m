%% 使用MATLAB官方APP实时流传感器传输数据
% 不要传入手机实时图像，太卡
%
SampleRate = 100;
matfile = 'data/sensorlog_20241008_093637.mat';
[Accelerometer, Gyroscope, Magnetometer, EulerAngles] ...
    = exampleHelperProcessPhoneData(matfile);

isUseMobile = 0;
if isUseMobile
    % addpath("VR drawing/");
    if ~exist("m","var")
        m= mobiledev;
    end

    %%
    m.Logging=1;
    m.SampleRate = SampleRate;
    m.AccelerationSensorEnabled = 1;
    m.AngularVelocitySensorEnabled = 1;
    m.OrientationSensorEnabled = 1;
end


%% Initialise empty figure and empty variables
fig = figure(Name="mobile stream sensor data",Position=[12,65,864,450]);
tiledlayout(2,2)

ax1 = nexttile(1,[2,1]);
grid(ax1,"on");
an1 = animatedline(ax1,NaT,NaN,"Color","red","LineWidth",2,'MaximumNumPoints',1000);
an2 = animatedline(ax1,NaT,NaN,"Color","blue","LineWidth",2,'MaximumNumPoints',1000);
an3 = animatedline(ax1,NaT,NaN,"Color","green","LineWidth",2,'MaximumNumPoints',1000);
legend(ax1,[an1,an2,an3],["x","y","z"])

ax2 = nexttile;
patchBuildin = poseplot(ax2,"ENU");
xlabel("North-x (m)")
ylabel("East-y (m)")
zlabel("Down-z (m)");

ax3 = nexttile;
patchButterworth = poseplot(ax3,"NED");
xlabel("North-x (m)")
ylabel("East-y (m)")
zlabel("Down-z (m)");

% imufilter
FUSE = imufilter('ReferenceFrame','NED',SampleRate=SampleRate);

% AHRS
% ahrs = MahonyAHRS('SamplePeriod', 1/m.SampleRate, 'Kp', 1);

% % Define filter parameters
% cutoff_freq = 3;  % Adjust cutoff frequency for desired smoothness
% filter_order = 2;   % Butterworth filter order
% [b, a] = butter(filter_order, (2 * cutoff_freq) / m.SampleRate, 'low');

% % Filter coefficients
% Fs = 100;  % Sampling Frequency (Hz)
% Fc = 2.5;    % Cutoff frequency (Hz);
% % Fc = 0.1;    % Cutoff frequency (Hz); This will make the movement in GLGravity very slow
% FilterOrder = 2;
% h = fdesign.lowpass('n,f3db', FilterOrder, Fc, Fs);
% DesignMethod = 'butter';
% Hd = design(h, DesignMethod);
% 
% % 以下cuixingxing add
% reset_filter = false;
% Structure = 'Direct form II transposed';
% sosMatrix = Hd.sosMatrix;
% scaleValues = Hd.ScaleValues;
% SOSMatrix = sosMatrix;
% ScaleValues = scaleValues;
% enable_filter = true;

%% Loop to start data collection
num = 1;
while(isvalid(fig))

    if isUseMobile
        % [acc,t] =accellog(m);
        acc = m.Acceleration;
        gyr = m.AngularVelocity;
        orientation = m.Orientation;

        % [gyros, t1] = angvellog(m);
        % [accel,t2] = accellog(m);
        % numsG = size(gyros,1);
        % numsA = size(accel,1);
        % numsam = min(numsG,numsA);
        % if numsam<7 % 巴特沃斯滤波器滤波参数决定至少的样本个数
        %     continue;
        % end
        % gyros = gyros(1:numsam,:);
        % accel = accel(1:numsam,:);
    else
        acc = Accelerometer(num,:);
        gyr =Gyroscope(num,:);
        orientation = EulerAngles(num,:);
    end

    if ~isempty(orientation)
        % 使用 eul2quat 函数
        yaw = orientation(1);
        pitch = orientation(2);
        roll = orientation(3);
        rotm = eul2rotm([yaw, roll,pitch] * (pi/180), 'ZYX'); % 将角度转换为弧度
        % rotm = roty(-180)*rotz(-90)*rotm; % 2024.9.2由rotx(-180)改为了roty(-180),待传感器弄好后验证正确性！？
        % q = eul2quat([yaw, pitch, roll] * (pi/180), 'ZXY'); % 将角度转换为弧度

        set(patchBuildin,Orientation=rotm);
    end

    if ~isempty(acc)&&~isempty(gyr)
        % Apply Butterworth filter to angular velocity (gyro data)
        % gyr_filtered = filtfilt(b, a, gyros);
        % acc_filtered = filtfilt(b,a,accel);
        % x = acc(1);
        % y = acc(2);
        % z = acc(3);
        % xyz_out = xyz_filter(x,y,z,reset_filter,Structure,SOSMatrix,ScaleValues,enable_filter);


        % Use filtered data in the AHRS algorithm
        % ahrs.UpdateIMU(gyr, acc);
        % quat = ahrs.Quaternion;

        % 直接使用imufilter结果
        currAcc = -[acc(:,2),acc(:,1),-acc(:,3)];
        currGyro = [gyr(:,2),gyr(:,1),-gyr(:,3)];
        quat = FUSE(currAcc,currGyro);
        set(patchButterworth, Orientation=quat);
    end


    if ~isempty(acc)
        % plot here
        addpoints(an1,datetime("now"),acc(1));
        addpoints(an2,datetime("now"),acc(2));
        addpoints(an3,datetime("now"),acc(3));
    end

    drawnow 
    num = num+1;
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
