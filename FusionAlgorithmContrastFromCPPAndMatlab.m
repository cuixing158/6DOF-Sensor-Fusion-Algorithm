%% 姿态解算算法性能对比
% 使用C++版本的Fusion数据在matlab中测试看看解算6DOF,9DOF的姿态对比，C++原始仓库地址：https://github.com/xioTechnologies/Fusion

sensorDataFile = "https://raw.githubusercontent.com/xioTechnologies/Fusion/refs/heads/main/Python/sensor_data.csv";

opts = detectImportOptions(sensorDataFile);
imuData = readtable(sensorDataFile,opts);

% 转换为标准国际单位制
timestamp = imuData{:,1};% unit:second
gyro = deg2rad(imuData{:,2:4}); % unit:rad/s
acc = 9.80665*imuData{:,5:7}; % unit:m/s^2
mag = imuData{:,8:10};% unit:uT

% fuse
sampleRate = size(timestamp,1)/timestamp(end);
FUSE = imufilter(SampleRate=sampleRate,ReferenceFrame="NED");
quat = FUSE(acc,gyro);
eulerAnglesDegrees = eulerd(quat,"ZYX","frame");

% plot
figure;
tiledlayout(3,1);

nexttile;
plot(timestamp,gyro,LineWidth=2);
legend(["X","Y","Z"])
ylabel("rad/s");

nexttile;
plot(timestamp,acc,LineWidth=2);
legend(["X","Y","Z"])
ylabel("m/s^2");

nexttile;
plot(timestamp,eulerAnglesDegrees,LineWidth=2,DisplayName="cui");
% legend;
ylabel("degree");
