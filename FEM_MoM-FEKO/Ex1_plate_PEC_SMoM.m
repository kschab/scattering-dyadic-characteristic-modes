%% Example 1 - PEC plate (PEC, sweep)
% 
% Rectangular PEC plate 1:2 of electrial size ka = [0.9, 2.9].
% The model is evaluated with FEKO MoM.
% 
% Should you realize any problem with running this script, please check the
% following:
% 1/ You have MATLAB 2021b and newer.
% 2/ You have FEKO 2021.1 and newer.
% 3/ All files from this package are visible for MATLAB (MATLAB path).
% 4/ Your MATLAB session has rights to create new files on the hard drive.
% 5/ Your FEKO installation is added into "path" of the operational system.
% 6/ You run this script from the folder "FEM_MoM-FEKO".
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