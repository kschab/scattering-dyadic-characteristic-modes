%% Example 5 - Substructure modes of patch antenna with dielectrics
%
% The model is evaluated with FEKO MoM.
% 
% (c) 2023-2024, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

clear;
clc;
close all;

% Solver settings in FEKO
solver = feko.getSolverOption(); % default settings

% Use  multiple right-hand sides at once? (direct $sparse solver)
MRHS  = false;

fList = 1e9 * linspace(0.1, 2.6, 16);
k0    = models.utilities.converter.f0tok0(fList);
a     = 0.0675;

Materials = {'Dielectric1', 2.33, 0}; % Material parameters of the diel.

nPW_est     = bin.minLebedevDegree(max(k0)*a);
nDegree_est = bin.getLebedevDegrees(nPW_est);

nDegree = 110; % degree of Lebedev quadrature

EXTR{1} = newline; % no extra code passed to PRE FEKO file

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d\n', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper for iterative eigenvalue solver (full structure)
% The name of the "cfm" FEKO file with the model, saved in [models] folder:
options.nModes        = 15;    % how many modes are evaluated with iter. s.
options.relativeError = 1e-4;  % relative tolerance for the nModes modes
options.adaIters      = 10;    % if >1 iterative spectral refinement used
options.adaMSmax      = 0.075; % how finely is the spectrum refined
options.eigSolver     = 'subs'; % SUBSTRUCTURE SOLVER

outputFileName = ['Ex5_SUBS_Ethier_Diel_PIFA_SMoM_' num2str(nDegree) ...
    'leb_' num2str(length(fList)) 'fr_epr2p33_ADA_' ...
    num2str(options.adaIters) 'ITS'];

% The name of the "cfm" FEKO file with the model, saved in [models] folder:
model = {'Ex5_PIFA_Ethier_Diel_MoM_2040tria'; ... % FULL STRUCTURE
         'Ex5_GND_Ethier_Diel_MoM_1718tria'}; % BACKGROUND PART ONLY

feko_icm(); % Use iterative solver...