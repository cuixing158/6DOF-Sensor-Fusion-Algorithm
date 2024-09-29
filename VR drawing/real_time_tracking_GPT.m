%% Initial setup
addpath('quaternion_library');  % Include quaternion library
if ~exist("m", "var")
    m = mobiledev;  % Initialize mobile device
end

% Set device parameters
m.SampleRate = 1;
m.AccelerationSensorEnabled = 1;
m.AngularVelocitySensorEnabled = 1;
m.Logging = 1;
pause(10);

% Plotting parameters
SamplePlotFreq = 1;
AxisLength = 1;
LimitRatio = 1;

%% Figure initialization
fig = figure('Name', '6DOF Animation',Position=[1,1,800,800]);
ax = axes(fig);
hold on; grid on; axis equal; view(3);
xlabel('X'); ylabel('Y'); zlabel('Z');

% Initialize data storage
initSamples = 1;
data = struct('x', zeros(initSamples, 1), 'y', zeros(initSamples, 1), ...
               'z', zeros(initSamples, 1), 'ox', zeros(initSamples, 1), ...
               'oy', zeros(initSamples, 1), 'oz', zeros(initSamples, 1), ...
               'ux', zeros(initSamples, 1), 'vx', zeros(initSamples, 1), ...
               'wx', zeros(initSamples, 1), 'uy', zeros(initSamples, 1), ...
               'vy', zeros(initSamples, 1), 'wy', zeros(initSamples, 1), ...
               'uz', zeros(initSamples, 1), 'vz', zeros(initSamples, 1), ...
               'wz', zeros(initSamples, 1));

% Create graphics handles
orgHandle = plot3(data.x, data.y, data.z, 'k.');
quivXhandle = quiver3(data.ox, data.oy, data.oz, data.ux, data.vx, data.wx, 'r');
quivYhandle = quiver3(data.ox, data.oy, data.oz, data.uy, data.vy, data.wy, 'g');
quivZhandle = quiver3(data.ox, data.oy, data.oz, data.uz, data.vz, data.wz, 'b');

% Set initial limits
set(gca, 'XLim', [-AxisLength, AxisLength] * LimitRatio, ...
          'YLim', [-AxisLength, AxisLength] * LimitRatio, ...
          'ZLim', [-AxisLength, AxisLength] * LimitRatio);

%% Data acquisition
samplePeriod = 1/256;

while m.Logging == 1
    [ac, ~] = accellog(m);
    [g, ~] = angvellog(m);
    if isempty(ac) || isempty(g), continue; end

    numAc = size(ac,1);
    numG = size(g,1);

    %% Synchronize accelerometer and gyroscope data
    if numAc < numG
        acc = ac(1:numAc,:);
        gyr = g(1:numAc, :);
    else
        acc = ac(1:numG, :);
        gyr = g(1:numG,:);
    end
    numsSample = min(numAc,numG);

    %% Process accelerometer data
    acc_mag = sqrt(sum(acc.^2, 2));  % Magnitude
    acc_magFilt = filtfilt(butter(1, (2 * 0.001) / (1/samplePeriod), 'high'), 1, acc_mag);
    acc_magFilt = abs(acc_magFilt);
    acc_magFilt = filtfilt(butter(1, (2 * 5) / (1/samplePeriod), 'low'), 1, acc_magFilt);
    acc_magFilt = acc_magFilt - mean(acc_magFilt);  % Remove mean

    %% Detect stationary periods
    stationary = abs(acc_magFilt) < 0.1;

    %% Calculate orientation using AHRS
    R = zeros(3, 3, numsSample);
    ahrs = MahonyAHRS('SamplePeriod', samplePeriod, 'Kp', 1);
    for i = 1:numsSample
        ahrs.UpdateIMU(gyr(i,:), acc(i,:));
        R(:,:,i) = quatern2rotMat(ahrs.Quaternion)';
    end

    %% Calculate tilt-compensated acceleration
    
    tcAcc = zeros(size(acc));  % accelerometer in Earth frame

    for i = 1:length(acc)
        tcAcc(i,:) = R(:,:,i) * acc(i,:)';
    end
    % subtracting gravity
    linAcc = zeros(size(tcAcc));

    for i= 1:length(tcAcc)
        linAcc(i,:) = tcAcc(i,:) - mean(tcAcc,1);
    end


    %% Linear velocity and position integration
    linVel = zeros(size(linAcc));
    for i = 2:length(linAcc)
        linVel(i,:) = linVel(i-1,:) + linAcc(i,:) * samplePeriod;
        if stationary(i), linVel(i,:) = [0 0 0]; end  % Zero velocity if stationary
    end

    % High-pass filter to remove drift
    linVelHP = filtfilt(butter(1, (2 * 0.1) / (1/samplePeriod), 'high'), 1, linVel);

    %% Calculate linear position
    linPos = zeros(size(linVelHP));
    for i = 2:length(linVelHP)
        linPos(i,:) = linPos(i-1,:) + linVelHP(i,:) * samplePeriod;
    end

    % High-pass filter for position drift
    linPosHP = filtfilt(butter(1, (2 * 0.1) / (1/samplePeriod), 'high'), 1, linPos);

    %% Animation
    p = linPosHP(1:SamplePlotFreq:end, :);
    R = R(:,:,1:SamplePlotFreq:end) * AxisLength;

    % Update plot data
    data.x(1:size(p,1)) = p(:,1);
    data.y(1:size(p,1)) = p(:,2);
    data.z(1:size(p,1)) = p(:,3);
    
    set(orgHandle, 'XData', data.x, 'YData', data.y, 'ZData', data.z);
    set(quivXhandle, 'XData', data.ox, 'YData', data.oy, 'ZData', data.oz, ...
                     'UData', data.ux, 'VData', data.vx, 'WData', data.wx);
    set(quivYhandle, 'XData', data.ox, 'YData', data.oy, 'ZData', data.oz, ...
                     'UData', data.uy, 'VData', data.vy, 'WData', data.wy);
    set(quivZhandle, 'XData', data.ox, 'YData', data.oy, 'ZData', data.oz, ...
                     'UData', data.uz, 'VData', data.vz, 'WData', data.wz);
    drawnow;

    %% Update axis limits
    xlim = get(gca, 'XLim');
    ylim = get(gca, 'YLim');
    zlim = get(gca, 'ZLim');
    xlim = updateLimits(data.x, AxisLength, xlim);
    ylim = updateLimits(data.y, AxisLength, ylim);
    zlim = updateLimits(data.z, AxisLength, zlim);
    set(gca, 'XLim', xlim, 'YLim', ylim, 'ZLim', zlim);
end

m.Logging = 0;

%% Helper function to update axis limits
function lim = updateLimits(data, AxisLength, lim)
    lim(1) = min(lim(1), min(data) - AxisLength);
    lim(2) = max(lim(2), max(data) + AxisLength);
end
