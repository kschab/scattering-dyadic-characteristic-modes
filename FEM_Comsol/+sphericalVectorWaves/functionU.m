function [u12, u11, u22, u21, u32, u31] = ...
    functionU(degreeL, orderM, theta, phi, kR, p)
%% functionU spherical vector waves u
%
%  INPUTS
%   degreeL: vector of degrees L, double [N x 1]
%   orderM:  vector of orderes M, double [N x 1]
%   theta:   vector of theta coordinates, double [M x 1]
%   phi:     vector of phi coordinates, double [M x 1]
%   kR:      vector of radial coordinates, double [M x 1]
%   p:       type of waves, double [1 x 1]
%              1 - regular waves, z = spherical Bessel function
%              2 - irregular waves, z = spherical Neumann function
%              3 - ingoing waves, z = spherical Hankel function 1
%              4 - outgoing waves, z = spherical Hankel function 2
%
%  OUTPUTS
%   u12:  spherical vector wave u1 with sigma = 2, 
%         complex double [N x M x 3]
%   u11:  spherical vector wave u1 with sigma = 1, 
%         complex double [N x M x 3]
%   u22:  spherical vector wave u2 with sigma = 2, 
%         complex double [N x M x 3]
%   u21:  spherical vector wave u2 with sigma = 1, 
%         complex double [N x M x 3]
%   u32:  spherical vector wave u3 with sigma = 2, 
%         complex double [N x M x 3]
%   u31:  spherical vector wave u3 with sigma = 1, 
%         complex double [N x M x 3]
%
%  SYNTAX
%   [u12, u11, u22, u21, u32, u31] = ...
%      functionU(degreeL, orderM, theta, phi, kR, p)
%
% Included in AToM, info@antennatoolbox.com
% (c) 2019, Vit Losenicky, CTU in Prague, vit.losenicky@antennatoolbox.com
% mcode docu

[R1, R2, R3, zD] = sphericalVectorWaves.functionR( ...
    degreeL, kR, p);

[Y1, Y2, Y3] = sphericalVectorWaves.functionY( ...
    degreeL, orderM, theta, phi);

u12 = R1 .* real(Y1);
u11 = R1 .* imag(Y1);
u22 = (R2 .* real(Y2) + R3 .* real(Y3));
u21 = (R2 .* imag(Y2) + R3 .* imag(Y3)); 
u32 = (zD .* real(Y3)  + R3 .* real(Y2));
u31 = (zD .* imag(Y3)  + R3 .* imag(Y2));

end
