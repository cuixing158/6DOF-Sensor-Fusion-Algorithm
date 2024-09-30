function [accel, gyro, mag, eulAngs] = exampleHelperProcessPhoneData(matfile)
%EXAMPLEHELPERPROCESSPHONEDATA Read logged phone sensor data and convert
%   to the NED frame.

%   Copyright 2020 The MathWorks, Inc.

ld = load(matfile);
% Read Accelerometer data.
accel = [ld.Acceleration.X ld.Acceleration.Y ld.Acceleration.Z];
    
% Read Gyroscope data.
gyro = [ld.AngularVelocity.X ld.AngularVelocity.Y ld.AngularVelocity.Z];

% Read Magnetometer data.
mag =  [ld.MagneticField.X ld.MagneticField.Y ld.MagneticField.Z];

% Read orientation data.
eulAngs = [ld.Orientation.Z, ld.Orientation.Y, ld.Orientation.X];

% Make sure there are the same number of elements in each sensor array.
na = size(accel,1);
ng = size(gyro,1);
nm = size(mag,1);
no = size(eulAngs,1);
N = min([na,ng,nm,no]);
accel = accel(1:N,:);
gyro = gyro(1:N,:);
mag = mag(1:N,:);
eulAngs = eulAngs(1:N,:);
