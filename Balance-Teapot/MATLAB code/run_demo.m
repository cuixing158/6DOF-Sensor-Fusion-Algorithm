%% This is the main script to run this demo
% Copyright 2012 - 2015 The MathWorks, Inc.

%% Given some input data from the iPhone accelerameter, try a few filters (Butterworth, different cutoff frequencies & orders combinations) to see which is the best fit for the input data

design_xyz_filter;

disp('Given the plots, we see that 2nd order filter with cutoff frequency of 2.5Hz work the best (based on delay and rejection of appropriate movements)');

%% For this example, we'll go with a 2nd order Butterworth filter with cutoff frequency of 2.5 Hz

disp('Here is the MATLAB code for the filter we''ll generate code for');
edit xyz_filter.m;

create_xyz_filter_for_codegen;
disp('We''ll create a 2nd order Butterworth filter with cutoff frequency of 2.5Hz');

%% Open MATLAB Coder project and generate code

coder xyz_filter;

% In the MATLAB Coder project, generate code and see the results in the
% Code Generation Report

%% Alternatively, you can generate code from the command line using this script

%% make_xyz_filter;