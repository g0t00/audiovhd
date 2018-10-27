function [  ] = printInnerGrid( n )
%PRINTINNERGRID Summary of this function goes here
%   Detailed explanation goes here
for y = 16:-1:1
    for x = 1:16
        a = n(x, y);
        fprintf('%s ', a.hex);
    end
    fprintf('\n');
end
end

