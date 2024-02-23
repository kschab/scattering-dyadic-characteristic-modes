function [S, quadrature, PW, FF, tt] = calculatePeriodicScatteringDyadic(...
    models, k0, Materials, angles, solver, EXTR, options)
% 
% 
% 
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

batchLength     = options.batchLength;
deleteAuxFiles  = options.deleteAuxFiles;
preFEKOfileName = options.preFEKOfileName;
storeTempData   = options.storeTempData;

tempFileName = 'TEMP_calculateScatteringDyadics';

%% Directions used
th = angles(:, 1);
ph = angles(:, 2);

% Wavenumber
const = bin.constants();
f0    = const.c0*k0/(2*pi);
r2d   = @(x) 180*x/pi; % radians to degrees

% Excitation via plane waves
thPW = r2d(pi - [th; th]); % rotate angles to agree with our definition of
phPW = r2d(pi + [ph; ph]); % scattering dyadics
pol  = r2d([pi*ones(nDegree,1); -pi/2*ones(nDegree,1)]); % [th ph]
PW   = [thPW, phPW, pol];

% Far field measurements
FF   = r2d([th ph]);

%% Sweep preparation
% Change (u,v) vectors (?)

% ** Periodic Boundary Condition
% DP: PBC_S1 :  :  :  :  : -1.5 : -1.5 : 0   ** PBC start point
% DP: PBC_S2 :  :  :  :  : 1.5 : -1.5 : 0   ** PBC first vector end point
% DP: PBC_S3 :  :  :  :  : -1.5 : 1.5 : 0   ** PBC second vector end point
% PE: 2 :  :  :  :  : PBC_S1 : PBC_S2 : PBC_S3
% 
% ** Feko solution parameters
% FP: 0 : 0




feko.preFEKO_1PW_nFF_Sdyadic(preFEKOfileName, models{thisModel}, ...
    Materials, batchFreq, PW(thisWave, :), FF, solver, EXTR);

%% Run PRE-feko file
clc;
dos(['runfeko ' preFEKOfileName '.pre --execute-prefeko -np all']);