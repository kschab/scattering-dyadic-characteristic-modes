function [Y1, Y2, Y3] = functionY(degreeL, orderM, theta, phi)
%% functionY vector spherical harmonics Y
%
%  INPUTS
%   degreeL: vector of degrees L, double [N x 1]
%   orderM:  vector of orderes M, double [N x 1]
%   theta:   vector of theta coordinates, double [M x 1]
%   phi:     vector of phi coordinates, double [M x 1]
%
%  OUTPUTS
%   Y1:   Y1 vector spherical hamonic, complex double [N x M x 3]
%   Y2:   Y2 vector spherical hamonic, complex double [N x M x 3]
%   Y3    Y3 vector spherical hamonic, complex double [N x M x 3]
%
%  SYNTAX
%   [Y1, Y2, Y3] = functionY(degreeL, orderM, theta, phi)
%
% Included in AToM, info@antennatoolbox.com
% (c) 2019, Vit Losenicky, CTU in Prague, vit.losenicky@antennatoolbox.com
% mcode docu

%% preparation
nCols = length(theta);
nRows = length(degreeL);

Y1 = zeros(nRows, nCols, 3);
Y2 = zeros(nRows, nCols, 3);
Y3 = zeros(nRows, nCols, 3);

constant1 =  (-1).^ orderM ./ (sqrt(2 * pi * degreeL .* (degreeL + 1 )));
constant1(orderM ~= 0) = sqrt(2) * constant1(orderM ~= 0);

constant2 = (-1) .^ orderM ./ sqrt(2 * pi);
constant2(orderM ~= 0) = sqrt(2) * constant2(orderM ~= 0);

expPart = exp(1i*orderM*phi.');

%%
cosTheta = cos(theta);
[normLegendreSing, normLegendreSingDer, normLegendre] = ...
    sphericalVectorWaves.legendreComponents( ...
    degreeL, orderM, cosTheta);

Y1(:, :, 2) = constant1 .* 1i .* normLegendreSing .* expPart;
Y1(:, :, 3) = - constant1 .* normLegendreSingDer .* expPart;

Y2(:, :, 2) = -Y1(:, :, 3);
Y2(:, :, 3) = Y1(:, :, 2);

Y3(:, :, 1) = constant2 .* normLegendre .* expPart;
end
