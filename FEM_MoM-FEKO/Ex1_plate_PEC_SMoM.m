%% Example 1 - PEC plate (PEC, sweep)
% 
% Rectangular PEC plate 1:2 of electrial size ka = [0.9, 2.9].
% The model is evaluated with FEKO MoM.
% 
% (c) 2022-2024, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

clear;
clc;
close all;

outputFileName  = 'Ex1_plate_PEC_MoM_14leb_40freq_0p9_2p9';
model = {'Ex1_plate_PEC_SMoM_286tria'};

% Solver settings in FEKO
solver = feko.getSolverOption(); % default settings

% Use  multiple right-hand sides at once? (direct sparse solver)
MRHS  = false;

ka    = 2;
a     = hypot(1/2, 1/4);
k0lim = [0.9, 2.9]/a;
k0    = linspace(k0lim(1), k0lim(end), 20);
% k0    = k0lim(end);

Materials = {}; % =PEC

nPW_est     = bin.minLebedevDegree(max(k0)*a);
nDegree_est = bin.getLebedevDegrees(nPW_est);

nDegree = 14;

EXTR{1} = newline; % no extra code passed to PRE FEKO file

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d\n\n', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper and FEKO solver, data are to be saved as "outputFileName"
feko_sd();

%% Plot eigenvalues in terms of eigenangles
M = 10;
hndlAngles = bin.plotEigenvalues(CMA_SD.k0, CMA_SD.tn(1:M, :), 'angles');
xlabel('$k_0$ (1/m)', 'Interpreter', 'latex', 'FontSize', 14);

%% Run wrapper for iterative eigenvalue solver
% options.solver = 'eigs';
% feko_icm();
% CMA_IP_eigs = CMA_IP;
% itEigs = Info.iter;

%% Run wrapper for iterative eigenvalue solver
% options.solver = 'eit';
% feko_icm();
% CMA_IP_eit = CMA_IP;
% itEit = Info.iter;

%% Run wrapper for iterative eigenvalue solver
% options.solver = 'eits';
% feko_icm();
% CMA_IP_eits = CMA_IP;
% itEits = Info.iter;

%%
% [CMA_SD.tn(1:10) CMA_IP_eigs.tn(1:10) CMA_IP_eit.tn(1:10) CMA_IP_eits.tn(1:10)]
% [CMA_SD.tt, CMA_IP_eigs.tt CMA_IP_eit.tt CMA_IP_eits.tt]
% [2*nDegree, itEigs, itEit, itEits]

%%
% [CMA_SD.tn(1:10) CMA_IP_eigs.tn(1:10) CMA_IP_eits.tn(1:10)]
% [CMA_SD.tt, CMA_IP_eigs.tt CMA_IP_eits.tt]
% [2*nDegree, itEigs,  itEits]