function [Fn, handles, fn] = plotModalSubstructureFarField(...
    CMA, solver, EXTR, f, m)
% PLOTMODALSUBSTRUCTUREFARFIELD: reconstruct far fields for substructures
% 
% Inputs:
%   CMA    ~ Data structure produced by "SD" or "ICM" solvers
%   solver ~ EM solver to be used in FEKO (see feko.getSolverOption)
%   EXTR   ~ additional features (like infinite ground plane,
%   f      ~ frequency index
%   m      ~ modal index
% 
% Outputs:
%   Fn ~ normalized (eigen-)vector(s) 
% 
% (c) 2025, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

% Get information about quadrature used and reconstruct
quadrature = bin.getLebedevSphere(size(CMA.P, 1));
[~, ~, Lmax, Npw] = bin.getLebedevDegrees(quadrature.n);
P_xyz = [quadrature.x, quadrature.y, quadrature.z];

% Prepare indexation matrix to calculate all TM and TE spherical waves
ind = sphWaves.indexMatrix(Lmax);

% Carthesian to Spherical coordinates
[P_rthetaphi(:, 1), P_rthetaphi(:, 2), P_rthetaphi(:, 3)] = ...
    bin.cart2sph(P_xyz(:, 1), P_xyz(:, 2), P_xyz(:, 3));

% Convert plane wave spectrum to spherical waves
AFCN = sphWaves.evaluateAatPoints(P_xyz, ind, Lmax);
       
% Collect far-field from CMA structure by revoking full-wave solver
Fn = feko.reconstructSubstructureFarfield(CMA, solver, EXTR, f, m);

% Conver the resulting far field from spherical to Carthesian coordinates
[Fn_xyz(:, 1), Fn_xyz(:, 2), Fn_xyz(:, 3)] = ...
    sphWaves.vecSph2Cart(zeros(Npw/2, 1), Fn(1:Npw/2), ...
    Fn((Npw/2+1):end), P_rthetaphi(:, 2), P_rthetaphi(:, 3));

% Project substructure far field onto spherical far field basis
fn = sphWaves.projectFarFields(P_xyz, Fn_xyz, AFCN, ind, quadrature.w);

%% Plot far fields
const = bin.constants();
f0    = CMA.k0(f) / (2*pi) * const.c0;

% Theta and Phi grid
Th = linspace(0, pi, 61);
Ph = linspace(0, 2*pi, 121);

% Calculate far field grid from spherical representation
indexVec = true(size(fn, 1), 1);
FF = sphWaves.sphericalFarField(f0, fn, indexVec, Th, Ph);

% Plot far field
handles = results.plotFarField('theta', Th, 'phi', Ph, 'farField', FF.D);