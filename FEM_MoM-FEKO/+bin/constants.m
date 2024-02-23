function const = constants()
% CONST: provides physical constants used within the package
% 
% Outputs:
%    const ~ structure containing:
%            c0 (speed of light)
%            mu0 (permeability of vacuum)
%            Z0  (impedance of vacuum)
%            ep0 (permittivity of vacuum)
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

const.c0  = 299792458;
const.mu0 = 4*pi*1.00000000082e-7;
const.Z0  = const.c0 * const.mu0;
const.ep0 = 1/(const.mu0 * const.c0^2);