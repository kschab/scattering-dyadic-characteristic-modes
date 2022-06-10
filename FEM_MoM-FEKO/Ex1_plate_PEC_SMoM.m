%% Example 1 - PEC plate (PEC, sweep)
% 
% Rectangular PEC plate 1:2 of electrial size ka = [0.9, 2.9].
% The model is evaluated with FEKO MoM.
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

clear;
clc;
close all;

outputFileName  = 'Ex1_plate_PEC_MoM_14leb_40freq_0p9_2p9';
model = 'Ex1_plate_PEC_SMoM_286tria';
ka    = 2;
a     = hypot(1/2, 1/4);
k0lim = [0.9, 2.9]/a;
k0    = linspace(k0lim(1), k0lim(end), 40);
Materials = {}; % =PEC

nPW_est     = bin.minLebedevDegree(max(k0)*a);
nDegree_est = bin.getLebedevDegrees(nPW_est);

nDegree = 14;

EXTR{1} = newline; % no extra code passed to PRE FEKO file

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper and FEKO solver, data are to be saved as "outputFileName"
feko_sd();