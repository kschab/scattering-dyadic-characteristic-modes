% FEKO_CM.M: Generates characteristic currents and other quantities
% 
% This script calculates characteristic current of chosen mode at given
% frequency. Full version of FEKO is recommended (as the student edition
% has limitation to only 20 plane waves used to excitation).
% 
% The procedure is as follows: From the characteristic far field vector Fn,
% the excitation coefficients for the plane waves are taken and used to
% excite the obstacle. The PRE FEKO file is automatically generated and run
% with FEKO. After that, the POSTFEKO is opened and the user can inspect
% the results there. Adding more request, other characteristic quantities
% can be calculated as well.
% 
% The variables used below are fully described in README file.
% 
% (c) 2022-2024, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

clear;
clc;
close all;

% Put here the file containing CMA_SD structure with the data:
inputFileName = 'Ex2B_rim_PEC_losslessRogers3_SurfEquivMoM_1458tria_26leb_100freq_0p7_2p9_SurfMoM';
load(fullfile('data', [inputFileName '.mat']));

solver = feko.getSolverOption();

%% ------------------------------------------------------------------------
% Generate pre-FEKO file for generating a given characteristic mode
f = 1; % select the frequency point
m = 1; % select the characteristic mode

figure;
stem(log10(abs(CMA_IP.Fn(:, m, f))))

%% ------------------------------------------------------------------------
options.deleteAuxFiles    = true; % perform cleanup after file generation?
options.preFEKOfileName   = 'characteristicMode'; % name of temp files
options.minThresholdToUse = 0.001; % which Fn entries should be used
options.numberOfModelUsed = 1; % which model from the list is to be used

% Clean all files which might exist from before
feko.cleanupFEKOsolverFiles(options.preFEKOfileName);
feko.cleanupFEKOcurrents(options.preFEKOfileName);

% Prepare pre wrapper with plane waves to excite selected char. mode
feko.calculateCharacteristicMode(CMA_IP, f, m, solver, options);

% Run postFEKO where the modal currents are shown
system(['postfeko ' options.preFEKOfileName '.fek &']);

% Clean all the files except of '.fek' file.
% feko.cleanupFEKOsolverFiles(options.preFEKOfileName, '.fek');

%% ------------------------------------------------------------------------
% Or plot current in MATLAB if the 'OS' files were generated
t0 = tic;
[C, I] = feko.readFEKOcurrents(options.preFEKOfileName);
tt = toc(t0)

%% ------------------------------------------------------------------------
% BONUS:
% Plot the currents in MATLAB (utilize interpolation) - works for 2D shapes
% Xq = linspace(-1/4, 1/4, 101);
% Yq = linspace(-1/2, 1/2, 201);
% 
% [XQ, YQ] = meshgrid(Xq, Yq);
% 
% Fx = scatteredInterpolant(C(:,1), C(:,2), (I(:,1)), 'linear', 'nearest');
% Fy = scatteredInterpolant(C(:,1), C(:,2), (I(:,2)), 'linear', 'nearest');
% 
% Jx = Fx(XQ, YQ);
% Jy = Fy(XQ, YQ);
% 
% F = sqrt(abs(Jx).^2 + abs(Jy).^2);
% 
% figure;
% imagesc(Xq, Yq, F);
% colormap(results.colors.colorMap.mySeqCMap);
% view(90, 90);
% 
% fcn = @(x) real(x);
% 
% hold on;
% quiver3(C(:, 1), C(:, 2), C(:, 3)+0.001, ...
%     fcn(I(:,1)), fcn(I(:,2)), fcn(I(:,3)), 'k', 'LineWidth', 2);
% axis equal;