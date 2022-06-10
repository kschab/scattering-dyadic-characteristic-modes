function OUT = rowDot(x, y)
%% calculates x dot y rwo-by-row
% This function calculates x dot y rwo-by-row.
%
% INPUTS
%  x: set of 3D vectors (each row is a vector), double [N x 3]
%  y: set of 3D vectors (each row is a vector), double [N x 3]
% 
% OUTPUTS
%  OUT: set of numbers (each row is a number), double [N x 1]
% 
% SYNTAX
% 
% [OUT] = rowDot ...
%    (x, y)
% 
% Included in AToM, info@antennatoolbox.com
% (c) 2019, Lukas Jelinek, CTU in Prague, lukas.jelinek@fel.cvut.cz

OUT = x(:,1).*y(:,1) + x(:,2).*y(:,2) + x(:,3).*y(:,3);
end