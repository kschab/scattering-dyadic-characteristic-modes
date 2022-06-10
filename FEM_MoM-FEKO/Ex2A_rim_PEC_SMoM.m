%% Example 2A - rim with CND (PEC, sweep)
% 
% Rectangular rim (forming a strip loop) above parasitic ground plane.
% All is made of PEC. Dimensions: 150mm x 75mm, rim height is 3.5mm (2.5mm
% above GND).
% The model is evaluated with FEKO MoM.
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

clear;
clc;
close all;

outputFileName  = 'Ex2A_rim_PEC_SMoM_466tria_50leb_100freq_0p7_2p9';
model = 'Ex2A_rim_PEC_SMoM_466tria';
a     = norm([0.150/2, 0.150/4, 0.0055/2]);
k0lim = [0.7, 2.9]/a;
k0    = linspace(k0lim(1), k0lim(end), 100);
Materials = {}; % =PEC

nPW_est     = bin.minLebedevDegree(max(k0)*a);
nDegree_est = bin.getLebedevDegrees(nPW_est);

nDegree = 50;

EXTR{1} = newline; % no extra code passed to PRE FEKO file

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper and FEKO solver, data are to be saved as "outputFileName"
feko_sd();