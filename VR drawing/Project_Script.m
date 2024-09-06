%% 这个利用手机传感器3轴加速度+3轴角速度，推算位移，已经跑通
% 待继续学习

%% Initial setup

addpath('quaternion_library');	 % include quatenrion library                     	 

if ~exist("m","var")
    m= mobiledev;
end

m.SampleRate=100;    
m.AccelerationSensorEnabled = 1; 
m.AngularVelocitySensorEnabled = 1;
m.Logging = 1; 
pause(10);
m.Logging=0; 

%% Data aquisition
samplePeriod = 1/256;
figure('Name', 'Raw Data');

[ac, ~] = accellog(m);
[g, ~] = angvellog(m);

% Raw Data Plot
subplot(1,2,1);
hold on;
plot(g(:,1), 'r');
plot(g(:,2), 'g');
plot(g(:,3), 'b');
xlabel('sample');
ylabel('rad/s');
title('Gyroscope');
legend('X', 'Y', 'Z');

subplot(1,2,2);
hold on;
plot(ac(:,1), 'r');
plot(ac(:,2), 'g');
plot(ac(:,3), 'b');
xlabel('sample');
ylabel('m/s�');
title('Accelerometer');
legend('X', 'Y', 'Z');

%% Acc and Gyro Synchronous

if (length(ac) < length(g))
    acc=ac;
    gyr=zeros(size(ac));
    for i = 1:length(ac)
         gyr(i,:)= g(i,:);
    end

elseif (length(ac) >= length(g))
    gyr=g;
    acc=zeros(size(g));
    for i = 1:length(g)
         acc(i,:)=ac(i,:);
    end

end
%% Detect stationary periods

% Compute accelerometer magnitude
acc_mag = sqrt(acc(:,1).*acc(:,1) + acc(:,2).*acc(:,2) + acc(:,3).*acc(:,3));

% HP filter accelerometer data
filtCutOff = 0.001;
[b, a] = butter(1, (2*filtCutOff)/(1/samplePeriod), 'high');
acc_magFilt = filtfilt(b, a, acc_mag);

% Compute absolute value
acc_magFilt = abs(acc_magFilt);

% LP filter accelerometer data
filtCutOff = 5;
[b, a] = butter(1, (2*filtCutOff)/(1/samplePeriod), 'low');
acc_magFilt = filtfilt(b, a, acc_magFilt);

% subtracting gravity
acc_magFilt_nog = zeros(size(acc_magFilt));

for i= 1:length(acc_magFilt)
    acc_magFilt_nog(i,:) = acc_magFilt(i,:) - mean(acc_magFilt,1);
end

% Threshold detection
stationary = acc_magFilt_nog < 0.1;


%% Process data through AHRS algorithm (calcualte orientation)
% See: http://www.x-io.co.uk/open-source-imu-and-ahrs-algorithms/

R = zeros(3,3,length(gyr));     % rotation matrix describing sensor relative to Earth

ahrs = MahonyAHRS('SamplePeriod', samplePeriod, 'Kp', 1);

for i = 1:length(gyr)
    ahrs.UpdateIMU(gyr(i,:) , acc(i,:));	% gyroscope units must be radians
    R(:,:,i) = quatern2rotMat(ahrs.Quaternion)';    % transpose because ahrs provides Earth relative to sensor
end

%% Calculate Tilt-Compensated acceleration

tcAcc = zeros(size(acc));  % accelerometer in Earth frame

for i = 1:length(acc)
    tcAcc(i,:) = R(:,:,i) * acc(i,:)';
end

% subtracting gravity
linAcc = zeros(size(tcAcc));

for i= 1:length(tcAcc)
    linAcc(i,:) = tcAcc(i,:) - mean(tcAcc,1);
end

% Plot
figure( 'Name', 'Tilt-Compensated Linear Acceleration');
hold on;
plot(linAcc(:,1), 'r');
plot(linAcc(:,2), 'g');
plot(linAcc(:,3), 'b');
xlabel('sample');
ylabel('m/s�');
title('Linear acceleration');
legend('X', 'Y', 'Z');

%% Calculate linear velocity (integrate acceleartion)
linVel = zeros(size(linAcc));

for i = 2:length(linAcc)
    linVel(i,:) = linVel(i-1,:) + linAcc(i,:) * samplePeriod;
    if(stationary(i) == 1)
        linVel(i,:) = [0 0 0];     % force zero velocity when stationary
    end
end
  
% Plot
figure('Name', 'linear velocity');
subplot(1,2,1);
hold on;
plot(linVel(:,1), 'r');
plot(linVel(:,2), 'g');
plot(linVel(:,3), 'b');
xlabel('sample');
ylabel('m/s');
title('Linear velocity');
legend('X', 'Y', 'Z');

%% Compute integral drift during non-stationary periods

velDrift = zeros(size(linVel));
stationaryStart = find([0; diff(stationary)] == 0);
stationaryEnd = find([0; diff(stationary)] == 1);
for i = 1:numel(stationaryEnd)
    driftRate = linVel(stationaryEnd(i)-1, :) / (stationaryEnd(i) - stationaryStart(i));
    enum = 1:(stationaryEnd(i) - stationaryStart(i));
    drift = [enum'*driftRate(1) enum'*driftRate(2) enum'*driftRate(3)];
    velDrift(stationaryStart(i):stationaryEnd(i)-1, :) = drift;
end

% Remove integral drift
linVel = linVel - velDrift;

%% High-pass filter linear velocity to remove drift

order = 1;
filtCutOff = 0.1;
[b, a] = butter(order, (2*filtCutOff)/(1/samplePeriod), 'high');
linVelHP = filtfilt(b, a, linVel);

% Plot
subplot(1,2,2);
hold on;
plot(linVelHP(:,1), 'r');
plot(linVelHP(:,2), 'g');
plot(linVelHP(:,3), 'b');
xlabel('sample');
ylabel('m/s');
title('High-pass filtered linear velocity');
legend('X', 'Y', 'Z');

%% Calculate linear position (integrate velocity)

linPos = zeros(size(linVelHP));

for i = 2:length(linVelHP)
    linPos(i,:) = linPos(i-1,:) + linVelHP(i,:) * samplePeriod;
end

% Plot
figure( 'Name', 'Linear Position');
subplot(1,2,1);
hold on;
plot(linPos(:,1), 'r');
plot(linPos(:,2), 'g');
plot(linPos(:,3), 'b');
xlabel('sample');
ylabel('m');
title('Linear position');
legend('X', 'Y', 'Z');

%% High-pass filter linear position to remove drift

order = 1;
filtCutOff = 0.1;
[b, a] = butter(order, (2*filtCutOff)/(1/samplePeriod), 'high');
linPosHP = filtfilt(b, a, linPos);

% Plot
subplot(1,2,2);
hold on;
plot(linPosHP(:,1), 'r');
plot(linPosHP(:,2), 'g');
plot(linPosHP(:,3), 'b');
xlabel('sample');
ylabel('m');
title('High-pass filtered linear position');
legend('X', 'Y', 'Z');

%% 3D Tracking
figure('Name', '3D Tracking')
plot3(linPosHP(:,1),linPosHP(:,2),linPosHP(:,3));
xlabel('X');
ylabel('Y');
zlabel('Z');  


%% Play animation
   
SamplePlotFreq = 1;

SixDOFanimation(linPosHP, R, ...
                'SamplePlotFreq', SamplePlotFreq, 'Trail', 'DotsOnly', ...
                'Position', [9 39 1280 720], ...
                'AxisLength', 0.1, 'ShowArrowHead', false, ...
                'Xlabel', 'X (m)', 'Ylabel', 'Y (m)', 'Zlabel', 'Z (m)', 'ShowLegend', false, 'Title', 'filtered');           
 
%% End of script
