%% Initial setup

addpath('quaternion_library');	 % include quatenrion library
if ~exist("m","var")
    m = mobiledev;
end

%%

m.SampleRate=1;
m.AccelerationSensorEnabled = 1;
m.AngularVelocitySensorEnabled = 1;
m.Logging = 1;
pause(10);% 晃动手机，记录数据

SamplePlotFreq=1;
w=0;
AxisLength = 1;
LimitRatio = 1;
%% fig init
fig = figure( 'Name', '6DOF Animation');
ax = axes(fig);
% set(ax, 'DrawMode', 'fast');
lighting phong;
set(fig, 'Renderer', 'zbuffer');
hold on;
axis equal;
grid on;
view(3);
title(i);
xlabel('X');
ylabel('Y');
zlabel('Z');
initSamples=1;

x = zeros(initSamples, 1);
y = zeros(initSamples, 1);
z = zeros(initSamples, 1);
ox = zeros(initSamples, 1);
oy = zeros(initSamples, 1);
oz = zeros(initSamples, 1);
ux = zeros(initSamples, 1);
vx = zeros(initSamples, 1);
wx = zeros(initSamples, 1);
uy = zeros(initSamples, 1);
vy = zeros(initSamples, 1);
wy = zeros(initSamples, 1);
uz = zeros(initSamples, 1);
vz = zeros(initSamples, 1);
wz = zeros(initSamples, 1);



% Create graphics handles
orgHandle = plot3(x, y, z, 'k.');

quivXhandle = quiver3(ox, oy, oz, ux, vx, wx,  'r');
quivYhandle = quiver3(ox, oy, oz, uy, vy, wy,  'g');
quivZhandle = quiver3(ox, ox, oz, uz, vz, wz,  'b');

% Set initial limits
Xlim = [x(1)-AxisLength x(1)+AxisLength] * LimitRatio;
Ylim = [y(1)-AxisLength y(1)+AxisLength] * LimitRatio;
Zlim = [z(1)-AxisLength z(1)+AxisLength] * LimitRatio;
set(gca, 'Xlim', Xlim, 'Ylim', Ylim, 'Zlim', Zlim);




%% Data aquisition
samplePeriod = 1/256;

while(m.Logging == 1)

    [ac, timestamp1] = accellog(m);
    [g, timestamp2] = angvellog(m);

    if isempty(ac)||isempty(g)
        continue;
    end

    %% Acc and Gyro Synchronous

    if (length(ac) < length(g))
        acc=ac;
        gyr=zeros(size(ac));
        for i = 1:size(ac,1)
            gyr(i,:)= g(i,:);
        end

    elseif (length(ac) >= length(g))
        gyr=g;
        acc=zeros(size(g));
        for i = 1:size(g,1)
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

    %% Calculate linear velocity (integrate acceleartion)
    linVel = zeros(size(linAcc));

    for i = 2:length(linAcc)
        linVel(i,:) = linVel(i-1,:) + linAcc(i,:) * samplePeriod;
        if(stationary(i) == 1)
            linVel(i,:) = [0 0 0];     % force zero velocity when stationary
        end
    end

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

    %% Calculate linear position (integrate velocity)

    linPos = zeros(size(linVelHP));

    for i = 2:length(linVelHP)
        linPos(i,:) = linPos(i-1,:) + linVelHP(i,:) * samplePeriod;
    end

    %% High-pass filter linear position to remove drift

    order = 1;
    filtCutOff = 0.1;
    [b, a] = butter(order, (2*filtCutOff)/(1/samplePeriod), 'high');
    linPosHP = filtfilt(b, a, linPos);

    %% Play animation
    %% Reduce data to samples to plot only
    p=linPosHP;
    [numSamples, ~] = size(p);
    p = p(1:SamplePlotFreq:numSamples, :);
    R = R(:, :, 1:SamplePlotFreq:numSamples) * AxisLength;
    if (w==0)

        x(1) = p(1,1);
        y(1) = p(1,2);
        z(1) = p(1,3);
        ox(1) = x(1);
        oy(1) = y(1);
        oz(1) = z(1);
        ux(1) = R(1,1,1:1);
        vx(1) = R(2,1,1:1);
        wx(1) = R(3,1,1:1);
        uy(1) = R(1,2,1:1);
        vy(1) = R(2,2,1:1);
        wy(1) = R(3,2,1:1);
        uz(1) = R(1,3,1:1);
        vz(1) = R(2,3,1:1);
        wz(1) = R(3,3,1:1);
        [numSamples , ~] = size(p);
        p = p(1:SamplePlotFreq:numSamples, :);
        R = R(:, :, 1:SamplePlotFreq:numSamples);
        j=0;
        [numPlotSamples, dummy] = size(p);
    end
    hold off;
    %
    k=length(p);
    for i=j:length(p)
        %
        %
        %
        %         % Plot body x y z axes
        %
        x(1:i) = p(1:i,1);
        y(1:i) = p(1:i,2);
        z(1:i) = p(1:i,3);
        %
        %
        ox(1:i) = p(1:i,1);
        oy(1:i) = p(1:i,2);
        oz(1:i) = p(1:i,3);
        ux(1:i) = R(1,1,1:i);
        vx(1:i) = R(2,1,1:i);
        wx(1:i) = R(3,1,1:i);
        uy(1:i) = R(1,2,1:i);
        vy(1:i) = R(2,2,1:i);
        wy(1:i) = R(3,2,1:i);
        uz(1:i) = R(1,3,1:i);
        vz(1:i) = R(2,3,1:i);
        wz(1:i) = R(3,3,1:i);

        set(orgHandle, 'xdata', x, 'ydata', y, 'zdata', z);
        set(quivXhandle, 'xdata', ox, 'ydata', oy, 'zdata', oz,'udata', ux, 'vdata', vx, 'wdata', wx);
        set(quivYhandle, 'xdata', ox, 'ydata', oy, 'zdata', oz,'udata', uy, 'vdata', vy, 'wdata', wy);
        set(quivZhandle, 'xdata', ox, 'ydata', oy, 'zdata', oz,'udata', uz, 'vdata', vz, 'wdata', wz);
        drawnow;
        % Adjust axes for snug fit and draw
        axisLimChanged = false;
        if((p(i,1) - AxisLength) < Xlim(1)), Xlim(1) = p(i,1) - LimitRatio*AxisLength; axisLimChanged = true; end
        if((p(i,2) - AxisLength) < Ylim(1)), Ylim(1) = p(i,2) - LimitRatio*AxisLength; axisLimChanged = true; end
        if((p(i,3) - AxisLength) < Zlim(1)), Zlim(1) = p(i,3) - LimitRatio*AxisLength; axisLimChanged = true; end
        if((p(i,1) + AxisLength) > Xlim(2)), Xlim(2) = p(i,1) + LimitRatio*AxisLength; axisLimChanged = true; end
        if((p(i,2) + AxisLength) > Ylim(2)), Ylim(2) = p(i,2) + LimitRatio*AxisLength; axisLimChanged = true; end
        if((p(i,3) + AxisLength) > Zlim(2)), Zlim(2) = p(i,3) + LimitRatio*AxisLength; axisLimChanged = true; end
        if(axisLimChanged), set(gca, 'Xlim', Xlim, 'Ylim', Ylim, 'Zlim', Zlim); end

        w=w+1;


        %% End of script
    end
    j=k;
end

m.Logging = 0;
