%% Example 0 - Test example
%
% The problem at hand is a rectangular PEC plate of aspect ratio 1:2,
% poorly meshed. The physics is not the main concern in this example.
% Rather, the validation of all MATLAB and FEKO functionality has to be
% done fast.
% 
% Estimated computational time: 1-2 minutes
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

% The output file is saved in [data] folder:
outputFileName  = 'Ex0_plate_PEC_MoM_14leb_51freq_ka_0p5_2p5';
% The name of the "cfm" FEKO file with the model, saved in [models] folder:
model = 'Ex0_plate_PEC_SMoM_112tria';
% Electrical size studied (a is the radius of the circumscribing sphere):
ka    = linspace(0.5, 2.5, 51);
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

fprintf(1, 'Estimated nPW=%d, nDegree=%d, USED nPW=%d', ...
    nPW_est, nDegree_est, nDegree);

%% Run wrapper and FEKO solver, data are to be saved as "outputFileName"
feko_sd();