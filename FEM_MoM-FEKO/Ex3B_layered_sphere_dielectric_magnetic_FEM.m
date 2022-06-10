%% Example 3B - Layered sphere (dielectric & magnetic, sweep)
%
% Sphere made of four layers of different permittivities and
% permeabilities.
% 
% The model is evaluated with FEKO FEM.
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz


clear;
clc;
close all;

outputFileName  = 'Ex3B_sphere_4dielMagLayers_FEM_81916tetra_3_5_8_2_FEM_38leb_7freq_3p4_4p0';

model = 'Ex3B_sphere_4dielMagLayers_FEM_81916tetra';
k0    = linspace(0.5, 4, 56);

A  = [0.5, 0.54237288135593];
d  = diff(A);
ka = 0.5:d:4;
% k0 = ka(40:end);
% k0 = ka([40 62 end]);
k0 = ka(41:2:end);
k0 = k0(16:end);

a = 1;
Materials = {'Dielectric_L4', 1, 0, 3, 0; ...
             'Dielectric_L3', 5, 0, [], []; ...
             'Dielectric_L2', 1, 0, 8, 0; ...
             'Dielectric_L1', 2, 0, [], []};

nPW_est     = bin.minLebedevDegree(max(k0)*a);
nDegree_est = bin.getLebedevDegrees(nPW_est);

nDegree = 38;

EXTR{1} = newline; % no extra code passed to PRE FEKO file

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper and FEKO solver, data are to be saved as "outputFileName"
feko_sd();