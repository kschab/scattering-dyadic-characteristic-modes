function [R1, R2, R3, zD] = functionR(degreeL, kR, p)
%% functionR radial part of spherical waves
%
%  INPUTS
%   degreeL: vector of degrees L, double [N x 1]
%   kR:      vector of radial coordinates, double [M x 1]
%   p:       type of waves, double [1 x 1]
%              1 - regular waves, z = spherical Bessel function
%              2 - irregular waves, z = spherical Neumann function
%              3 - ingoing waves, z = spherical Hankel function 1
%              4 - outgoing waves, z = spherical Hankel function 2
%
%  OUTPUTS
%   R1:   R1 radial function, complex double [N x M]
%   R2:   R2 radial function, complex double [N x M]
%   R3:   R3 radial function, complex double [N x M]
%   zD:   derivatve of propper spherical bessel function,
%         complex double [N x M]
%
%  SYNTAX
%   [R1, R2, R3, zD] = functionR(degreeL, kR, p)
%
% Included in AToM, info@antennatoolbox.com
% (c) 2019, Vit Losenicky, CTU in Prague, vit.losenicky@antennatoolbox.com
% mcode docu

constant = sqrt(pi./(2.*kR));

maxDegreeL = max(degreeL);

z = nan(length(degreeL), length(kR));
zD = z;

for thisDegreeL = 1:maxDegreeL
    %     temp = besselj(thisDegreeL+0.5,kR);
    [bessel1, bessel2] = besselWavesType(thisDegreeL, kR, p);
    index = degreeL == thisDegreeL;
    z(index, :) = repmat((constant .* bessel1).', sum(index), 1);
    zD(index, :) = ...
        repmat((constant .* (bessel2 -...
        (thisDegreeL + 1) .* (1./kR) .* bessel1)).', sum(index), 1);
end

R1 = z;
R2 = (1./kR).' .* (z + kR.' .* zD);
R3 = (sqrt(degreeL .* (degreeL + 1)) .* z) ./ kR.';
end

function [bessel1, bessel2] = besselWavesType(degreeL, kR, p)
switch p
    case 1
        bessel1 = besselj(degreeL + 0.5, kR);
        bessel2 = besselj(degreeL - 0.5, kR);
    case 2
        bessel1 = bessely(degreeL + 0.5, kR);
        bessel2 = bessely(degreeL - 0.5, kR);
    case 3
        bessel1 = besselj(degreeL + 0.5, kR) + ...
            1i * bessely(degreeL + 0.5, kR);
        bessel2 = besselj(degreeL - 0.5, kR) + ...
            1i * bessely(degreeL - 0.5, kR);
    case 4
        bessel1 = besselj(degreeL + 0.5, kR) - ...
            1i * bessely(degreeL + 0.5, kR);
        bessel2 = besselj(degreeL - 0.5, kR) - ...
            1i * bessely(degreeL - 0.5, kR);
end
end
