% Prototype inputs for double-precision floating-point implementation
% Copyright 2012 - 2015 The MathWorks, Inc.

x = 0; y = 0; z = 0;

% Filter coefficients
Fs = 100;  % Sampling Frequency (Hz)
% Fc = 2.5;    % Cutoff frequency (Hz);
Fc = 0.1;    % Cutoff frequency (Hz); This will make the movement in GLGravity very slow
FilterOrder = 2;
h = fdesign.lowpass('n,f3db', FilterOrder, Fc, Fs);
DesignMethod = 'butter';
Hd = design(h, DesignMethod);

% Parameters for code generation
reset_filter = coder.Constant(false);
Structure = coder.Constant('Direct form II transposed');
sosMatrix = Hd.sosMatrix;
scaleValues = Hd.ScaleValues;
SOSMatrix = coder.Constant(sosMatrix);
ScaleValues = coder.Constant(scaleValues);
ENABLE_FILTER = coder.Constant(true);

% Parameters for simulation
% reset_filter = false;
% Structure = 'Direct form II transposed';
% sosMatrix = Hd.sosMatrix;
% scaleValues = Hd.ScaleValues;
% SOSMatrix = sosMatrix;
% ScaleValues = scaleValues;
% ENABLE_FILTER = true;
