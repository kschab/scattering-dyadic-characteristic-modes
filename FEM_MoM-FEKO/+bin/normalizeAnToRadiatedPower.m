function An = normalizeAnToRadiatedPower(An, W)
% NORMALIZEANTORADIATEDPOWER: normalize vectors to unitary radiated power
% The vectors can be either one vector only or entire matrix of column
% vectors
% 
% Inputs:
%   An ~ (eigen-)vector(s) 
%        e.g. characteristic excitation/far-field vector(s)
%   W  ~ Lebedev quadrature weights as a matrix for both polarizations
% 
% Outputs:
%   An ~ normalized (eigen-)vector(s) 
% 
% (c) 2025, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

% Upload physical constants
const = bin.constants();

% Radiated power
Prad = 1/(2*const.Z0) * diag(real(An' * W * An));

% Normalization to unitary radiated power (works for matrices An too)
An = An ./ sqrt(Prad.');