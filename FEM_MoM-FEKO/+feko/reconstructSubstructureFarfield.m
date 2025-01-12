function Fn = reconstructSubstructureFarfield(CMA, solver, EXTR, f, m)
% RECONSTRUCTSUBSTRUCTUREFIELD: reconstruct far fields for substructures
% 
% Inputs:
%   CMA    ~ Data structure produced by "SD" or "ICM" solvers
%   solver ~ EM solver to be used in FEKO (see feko.getSolverOption)
%   EXTR   ~ additional features (like infinite ground plane,
%   f      ~ frequency index
%   m      ~ modal index
% 
% Outputs:
%   Fn ~ substructure modal far field in plane wave basis
% 
% [1] Gustafsson, M. et al.; Theory and Computation of Substructure
%                            Characteristic Modes
% 
% (c) 2025, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

isItDirectSolver = isfield(CMA, 'S');

if isItDirectSolver % CMA_SD
    % Convert background scattering dyadics into scattering matrix
    K   = -1j*CMA.k0(f) / (4*pi);
    SMb = K * (CMA.S(:, :, f, 2) * CMA.W);    
    E   = eye(2*size(CMA.P, 1));
    Sb  = (2*SMb + E); % Background scattering matrix
    
    % Use fn = Sb*an from substructure paper, below eq. (4) in [1]
    Fn = Sb * CMA.Fn(:, m, f);
else % CMA_IP
    An = CMA.Fn(:, m, f);
    k0 = CMA.k0(f);
    
    % Far field of the entire structure
    Fn1  = feko.calculateCharacteristicFarField(...
        CMA, solver, EXTR, 1, An, k0);

    % Far field of the background structure
    Fn2  = feko.calculateCharacteristicFarField(...
        CMA, solver, EXTR, 2, An, k0);    

    % Their subtraction as proposed in the paper, eq. (15) in [1]
    Fn = Fn1 - Fn2;
end