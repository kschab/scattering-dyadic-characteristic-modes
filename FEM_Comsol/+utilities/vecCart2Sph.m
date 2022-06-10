function sphVector = vecCart2Sph(cartVector, theta, phi)
%% VECCART2SPH Transforms vector in Cartesian coordinates to vector in 
% spherical coordinates
%
%  INPUTS
%   cartVector: vector in Cartesian coordinates, double [N x 3]
%   theta: theta angle position of this vector, double [N x 1]
%   phi: phi position of this vector, double [N x 1]
%
%  OUTPUTS
%   sphVector: vector in spherical coordinates, double [N x 3]
%
%  SYNTAX
%   sphVector = vecCart2Sph(cartVector, theta, phi)
%
% Included in AToM, info@antennatoolbox.com
% (c) 2017, Vit Losenicky, CTU in Prague, vit.losenicky@antennatoolbox.com
% mcode

sphVector =   ( zeros(size(cartVector, 1),3) );

sphVector(:, 1) =   ( sin(theta) .* cos(phi) .* cartVector(:,1) + ...
   sin(theta) .* sin(phi) .* cartVector(:,2) + ...
   cos(theta) .* cartVector(:,3) );

sphVector(:, 2) =   ( cos(theta) .* cos(phi) .* cartVector(:,1) + ...
   cos(theta) .* sin(phi) .* cartVector(:,2) - ...
   sin(theta).* cartVector(:,3));

sphVector(:, 3) =  ( -sin(phi) .* cartVector(:,1) + ...
   cos(phi) .* cartVector(:,2));
end