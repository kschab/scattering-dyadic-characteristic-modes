%% Example 4B - Substructure modes of patch antenna (same arrangement as 4A)
%
% The model is evaluated with FEKO MoM.
% 
% (c) 2023-2024, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

clear;
clc;
close all;

% Solver settings in FEKO
solver = feko.getSolverOption(); % default settings

% Use  multiple right-hand sides at once? (direct sparse solver)
MRHS  = false;

fList = 1e9 * linspace(0.1, 2.6, 16);
k0    = models.utilities.converter.f0tok0(fList);
a     = 0.0675;

Materials = {}; % =PEC

nPW_est     = bin.minLebedevDegree(max(k0)*a);
nDegree_est = bin.getLebedevDegrees(nPW_est);

nDegree = 110; % degree of Lebedev quadrature

EXTR{1} = newline; % no extra code passed to PRE FEKO file

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d\n', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper for iterative eigenvalue solver (substructure)
% The output file is saved in [data] folder:
options.nModes        = 15;    % how many modes are evaluated with iter. s.
options.relativeError = 1e-4;  % relative tolerance for the nModes modes
options.adaIters      = 10;    % if >1 iterative spectral refinement used
options.adaMSmax      = 0.075; % how finely is the spectrum refined
options.eigSolver     = 'subs'; % SUBSTRUCTURE SOLVER

outputFileName = ['Ex4_SUBS_Ethier_PIFA_SMoM_' num2str(nDegree) ...
    'leb_' num2str(length(fList)) 'fr_PEC_ADA_' ...
    num2str(options.adaIters) 'ITS'];

% The name of the "cfm" FEKO file with the model, saved in [models] folder:
model  = {'Ex4_PIFA_Ethier_PEC_MoM_1368tria'; ... % FULL STRUCTURE
          'Ex4_GND_Ethier_PEC_MoM_654tria'}; % BACKGROUND PART ONLY

feko_icm(); % Use iterative solver...