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
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

clear;
clc;
close all;

outputFileName  = 'Ex2B_rim_PEC_losslessRogers3_SurfEquivMoM_1458tria_26leb_100freq_0p7_2p9_SurfMoM';
model = 'Ex2B_rim_PEC_losslessRogers3_SurfEquivMoM_1458tria';
a     = norm([0.150/2, 0.150/4, 0.0055/2]);
k0lim = [0.7 2.9]/a;
k0    = linspace(k0lim(1), k0lim(end), 100);
Materials = {'Dielectric1', 3, 0};

nPW_est     = bin.minLebedevDegree(max(k0)*a);
nDegree_est = bin.getLebedevDegrees(nPW_est);

nDegree = 26;

EXTR{1} = newline; % no extra code passed to PRE FEKO file

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper and FEKO solver, data are to be saved as "outputFileName"
feko_sd();