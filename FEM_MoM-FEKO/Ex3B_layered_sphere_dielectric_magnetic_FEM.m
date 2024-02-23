%% Example 3B - Layered sphere (dielectric & magnetic, sweep)
%
% Sphere made of four layers of different permittivities and
% permeabilities.
% 
% The model is evaluated with FEKO FEM.
% 
% (c) 2022-2024, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz


clear;
clc;
close all;

% The output file is saved in [data] folder:
outputFileName  = 'Ex3B_sphere_4dielMagLayers_FEM_81916tetra_3_5_8_2_FEM_38leb_1freq_4p0';

% The name of the "cfm" FEKO file with the model, saved in [models] folder:
model  = {'Ex3B_sphere_4dielMagLayers_FEM_35688tetra'};

% Solver settings in FEKO
solver = feko.getSolverOption();

% Use  multiple right-hand sides at once? (direct sparse solver)
MRHS  = false;

k0 = linspace(0.5, 4, 31);
a  = 1;

Materials = {'Dielectric_L4', 1, 0, 3, 0; ...
             'Dielectric_L3', 5, 0, [], []; ...
             'Dielectric_L2', 1, 0, 8, 0; ...
             'Dielectric_L1', 2, 0, [], []};

nPW_est     = bin.minLebedevDegree(max(k0)*a);
nDegree_est = bin.getLebedevDegrees(nPW_est);

nDegree = nDegree_est; % 38

EXTR{1} = newline; % no extra code passed to PRE FEKO file

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper and FEKO solver, data are to be saved as "outputFileName"
feko_sd();

%% Run wrapper for iterative eigenvalue solver
feko_icm();

%% Comparison
clc
[CMA_SD.tn(1:options.nModes, 3), CMA_IP.tn(1:options.nModes, :)]
[CMA_SD.tt, CMA_IP.tt]
[2*nDegree, Info.iter]