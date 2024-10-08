%% 使用自己手机6dof数据做仿真，姿态角解算，姿态模拟，看是否达到预期
% 结论：可以达到预期
matfile = 'sensorlog_20241008_093637.mat';
SampleRate = 100; % This must match the data rate of the phone.


[Accelerometer, Gyroscope, Magnetometer, EulerAngles] ...
    = exampleHelperProcessPhoneData(matfile);

Accelerometer = -[Accelerometer(:,2), Accelerometer(:,1), -Accelerometer(:,3)];
Gyroscope = [Gyroscope(:,2), Gyroscope(:,1), -Gyroscope(:,3)];
% Accelerometer = [Accelerometer(:,1), Accelerometer(:,2), Accelerometer(:,3)];
% Gyroscope = [Gyroscope(:,1), Gyroscope(:,2), -Gyroscope(:,3)];

%%
FUSE = imufilter('ReferenceFrame','NED',SampleRate=SampleRate);
numSamples = size(Accelerometer,1);
% qEstIMU = FUSE(Accelerometer,Gyroscope);

reset(FUSE);
qEs = zeros(numSamples,1,"quaternion");
figure
initOrien = quaternion(rotm2quat(rotz(0)));
pp = poseplot(initOrien,"NED","MeshFileName", "phoneMesh.stl");
xlabel("North-x (m)")
ylabel("East-y (m)")
zlabel("Down-z (m)");

for i = 1:numSamples
    qEs(i) = FUSE(Accelerometer(i,:),Gyroscope(i,:));
    set(pp, "Orientation", qEs(i)*initOrien);
    drawnow
end


