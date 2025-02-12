%% Example 0 - Test example
%
% The problem at hand is a rectangular PEC plate of aspect ratio 1:2,
% poorly meshed. The physics is not the main concern in this example.
% Rather, the validation of all MATLAB and FEKO functionality has to be
% done fast.
% 
% Estimated computational time: 1-2 minutes
% 
% If you meet any troubles, see README.txt.
% 
% (c) 2022-2025, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

clear;
clc;
close all;

% The output file is saved in [data] folder:
outputFileName  = 'Ex0_plate_PEC_SMoM_112tria';

% The name of the "cfm" FEKO file with the model, saved in [models] folder:
model = {'Ex0_plate_PEC_SMoM_112tria'};

% Solver settings in FEKO
solver = feko.getSolverOption(); % default settings

% Use  multiple right-hand sides at once? (direct sparse solver)
MRHS  = false;

% Electrical size studied (a is the radius of the circumscribing sphere):
ka    = linspace(0.5, 1.5, 6);
% ka    = pi/2;
a     = hypot(1/2, 1/4);
k0    = ka/a;
% Materials used (if empty, PEC is used everywhere):
Materials = {}; % =PEC

% For estimation of optimal degree of the quadrature:
nPW_est     = bin.minLebedevDegree(max(k0)*a);
nDegree_est = bin.getLebedevDegrees(nPW_est);

% User-defined degree of the quadrature (can be the recommended one or not)
nDegree = 14;

% No extra code passed to PRE FEKO file
EXTR{1} = newline;

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d\n', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper and FEKO solver, data are to be saved as "outputFileName"
feko_sd();

%% Run wrapper for iterative eigenvalue solver
options.nModes        = 10;
options.relativeError = 1e-4;
options.adaIters      = 1;
options.adaMSmax      = 0.2;
options.eigSolver     = 'std';
feko_icm(); % there are many options to be set, see feko_icm.m, lines 8-34

%% Plot eigenvalues
hndltn = bin.plotEigenvalues(CMA_SD.k0, CMA_SD.tn, 'tn');

%% Plot eigenvalues in terms of eigenangles
hndlAngles = bin.plotEigenvalues(CMA_SD.k0, CMA_SD.tn, 'angles');
xlabel('$k_0$ (1/m)', 'Interpreter', 'latex', 'FontSize', 14);