% Makefile to generate C code from MATLAB code for xyz_filter.
% Copyright 2012 - 2015 The MathWorks, Inc.

% Need to run create_xyz_filter_for_codegen.m before executing this script!

% Create a code generation configuration object
warning('off','CoderFoundation:builder:TMFIncompatibilityWarningMATLABCoder')
config_obj = coder.config('lib');
config_obj.GenCodeOnly = true;
config_obj.GenerateMakefile = false;
config_obj.GenerateReport = true;
config_obj.LaunchReport = true;
config_obj.SaturateOnIntegerOverflow = false;
config_obj.SupportNonFinite = false;
config_obj.EnableVariableSizing = false;
config_obj.FilePartitionMethod ='SingleFile';
config_obj.TargetLang = 'C';
config_obj.PassStructByReference = true;

% Generate embeddable C code
codegen -config config_obj  xyz_filter -args {x,y,z,reset_filter,Structure,SOSMatrix,ScaleValues,ENABLE_FILTER};