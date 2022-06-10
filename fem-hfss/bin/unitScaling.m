function [k] = unitScaling(str)
%{
unitscaling.m

a utility function for parsing units from data exported by HFSS

Kurt Schab
Santa Clara University
kschab@scu.edu
2022

%}
str;
switch str
    case 'V'
        k = 1;
    case 'mV'
        k = 1/1e3;
    case 'uv'
        k = 1/1e6;
    case 'nV'
        k = 1/1e9;
    case 'pV'
        k = 1/1e12;
    otherwise
        error('units not recognized: ',str)
end
end
