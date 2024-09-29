function xyz_out = xyz_filter(x,y,z,reset_filter,Structure,SOSMatrix,ScaleValues,enable_filter) %#codegen
% Copyright 2012 - 2015 The MathWorks, Inc.

    persistent hFilter
    if enable_filter
        if isempty(hFilter) || reset_filter
            hFilter = dsp.BiquadFilter(...
                'Structure',Structure,...
                'SOSMatrix',SOSMatrix,...
                'ScaleValues',ScaleValues);
        end
        xyz_out = step(hFilter, [x y z]);
    else
        xyz_out = [x y z];
    end
end
