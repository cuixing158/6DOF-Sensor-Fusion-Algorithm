function [sosMatrix, scaleValues, Fs, Fc, FilterOrder, DesignMethod, time] = Filter_design_parameters_25_Nov_2013_11_59_17() %#codegen
% Copyright 2012 - 2015 The MathWorks, Inc.

    sosMatrix = ([
        1
        2
        1
        1
        -1.7786317778245848
        0.80080264666570755
    ]);
    sosMatrix = reshape(sosMatrix,[1,6]);
    scaleValues = ([
        0.0055427172102806817
        1
    ]);
    scaleValues = reshape(scaleValues,[2,1]);
    Fs =         100;
    Fc =         2.5;
    FilterOrder =         2;
    DesignMethod = 'butter';
    time = '25-Nov-2013 11:59:17';
end
