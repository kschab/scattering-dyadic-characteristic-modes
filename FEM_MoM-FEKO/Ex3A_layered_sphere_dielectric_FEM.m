%% Example 3A - Layered sphere (dielectric, sweep)
%
% Sphere made of four layers of different permittivities.
% 
% The model is evaluated with FEKO FEM.
% 
% (c) 2022-2024, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

clear;
clc;
close all;

% The output file is saved in [data] folder:
outputFileName  = 'sphere_4Layers_3_5_8_2_FEM_38leb_40freq_0p5_3p0';

% The name of the "cfm" FEKO file with the model, saved in [models] folder:
model  = {'Ex3A_sphere_4dielLayers_FEM_35688tetra'};

% Solver settings in FEKO
solver = feko.getSolverOption(); % default settings

% Use  multiple right-hand sides at once? (direct sparse solver)
MRHS  = false;

k0    = linspace(0.5, 3, 40);
a     = 1;
Materials = {'Dielectric_L4', 3, 0, [], []; ...
             'Dielectric_L3', 5, 0, [], []; ...
             'Dielectric_L2', 8, 0, [], []; ...
             'Dielectric_L1', 2, 0, [], []};

nPW_est     = bin.minLebedevDegree(max(k0)*a);
nDegree_est = bin.getLebedevDegrees(nPW_est);

nDegree = 14;

EXTR{1} = newline; % no extra code passed to PRE FEKO file

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper and FEKO solver, data are to be saved as "outputFileName"
feko_sd();