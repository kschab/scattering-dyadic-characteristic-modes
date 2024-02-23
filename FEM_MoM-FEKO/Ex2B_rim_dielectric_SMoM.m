%% Example 2B - rim with GND (PEC + dielectrics, sweep)
% 
% Rectangular rim (forming a strip loop) above parasitic ground plane.
% Both the rim and the ground plane are made of PEC. There is a block of
% dielectrics (epr_r = 3) filling the space within the rim, above the
% ground plane entirely. Please, take a look at the model in FEKO for
% details.
% 
% The model is evaluated with FEKO surface equivalence MoM.
% 
% (c) 2022-2024, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

clear;
clc;
close all;

% The output file is saved in [data] folder:
outputFileName  = 'Ex2B_rim_PEC_losslessRogers3_SurfEquivMoM_1458tria_26leb_100freq_0p7_2p9_SurfMoM';

% The name of the "cfm" FEKO file with the model, saved in [models] folder:
model  = {'Ex2B_rim_PEC_losslessRogers3_SurfEquivMoM_1458tria'};

% Solver settings in FEKO
solver = feko.getSolverOption(); % default settings

% Use  multiple right-hand sides at once? (direct sparse solver)
MRHS  = false;

a     = norm([0.150/2, 0.150/4, 0.0055/2]);
k0lim = [0.7 2.9]/a;
k0    = linspace(k0lim(1), k0lim(end), 100);
% k0lim = 5.0/a;
% k0    = linspace(k0lim(1), k0lim(end), 1);
Materials = {'Dielectric1', 3, 0};

nPW_est     = bin.minLebedevDegree(max(k0)*a);
nDegree_est = bin.getLebedevDegrees(nPW_est);

nDegree = 38; % degree of Lebedev quadrature

EXTR{1} = newline; % no extra code passed to PRE FEKO file

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper and FEKO solver, data are to be saved as "outputFileName"
feko_sd();

%% Run wrapper for iterative eigenvalue solver
options.solver = 'std'; % std means no sub-structure
feko_icm();

%%
[CMA_SD.tn(1:10) CMA_IP.tn(1:10)]
[CMA_SD.tt, CMA_IP.tt]