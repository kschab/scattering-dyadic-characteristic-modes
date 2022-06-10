% FEKO_SD.M: Constructs the scattering dyadics in their matrix forms
% 
% This script utilizes all input variables provided by the user in the
% staring script (see files ExXX_YYY.m) and calculates the scattering
% dyadics.
% 
% The procedure is as follows: The PRE FEKO file is constructed
% iteratively for given frequencies and incident directions (as dictated by
% chosen quadrature degree). Both theta and phi polarization are utilized.
% For each run, all observation directions and polarizations are solved at
% once, i.e., each run of FEKO gives one column of a scattering dyadic
% matrix. The procedure is parallelized, all CPU codes are utilized at
% once. To accelerate the evaluation, more frequencies can be calculated in
% one batch, see "batchLenght" variable below (be careful with memory!).
% For other variables, see the README file.
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

options.batchLength     = 10;   % =20 for student's edition of FEKO
options.deleteAuxFiles  = true; % perform cleanup
options.preFEKOfileName = 'characteristicModeEvaluation';
options.storeTempData   = true;

%% ------------------------------------------------------------------------
% Calculate scattering dyadic matrices
[S, quadrature, PW, FF, tt] = feko.calculateScatteringDyadic(...
    model, k0, Materials, nDegree, EXTR, options);

CMA_SD.S         = S;
CMA_SD.k0        = k0;
CMA_SD.PW        = PW;
CMA_SD.FF        = FF;
CMA_SD.P         = [quadrature.x, quadrature.y, quadrature.z];
CMA_SD.tt        = tt;
CMA_SD.model     = model;
CMA_SD.materials = Materials;
save(fullfile('data', [outputFileName '.mat']), 'CMA_SD'); 
fprintf(2, '*** SD Evaluation complete! (Total time: %1.0fs) *** \n', tt);

%% ------------------------------------------------------------------------
% Calculate char. mode decomposition (via scattering dyadic matrix)
[F_n, t_n, W] = bin.decomposeScatteringDyadic(...
    S, k0, quadrature.w);

CMA_SD.W  = W;
CMA_SD.Fn_orig = F_n;
CMA_SD.tn_orig = t_n;

% Far-field tracking
[F_n, t_n] = bin.farFieldTracking(CMA_SD);

CMA_SD.Fn = F_n;
CMA_SD.tn = t_n;

% Save the data
save(fullfile('data', [outputFileName '.mat']), 'CMA_SD'); 
fprintf(2, '*** CMA Evaluation complete! *** \n');

%% Control plot
% fcn = @(x) abs(x); % modal significance
fcn = @(x) (180/pi) * (pi - atan(real(1j*(1+x)./x))); % char. angle
figure('color', 'w', 'pos', [50 50 1200 600]);
subplot(1,2,1);
plot(CMA_SD.k0, fcn(CMA_SD.tn_orig), '-x');
xlim([CMA_SD.k0(1)-1e5*eps CMA_SD.k0(end)+1e5*eps]);
grid on;
xlabel('k_0 (1/m)');
ylabel('|t_n| (-)');
set(gca, 'FontSize', 13);
title('original data from eig (untracked)');

subplot(1,2,2);
plot(CMA_SD.k0, fcn(CMA_SD.tn), '-x');
xlim([CMA_SD.k0(1)-1e5*eps CMA_SD.k0(end)+1e5*eps]);
grid on; xlabel('k_0 (1/m)'); ylabel('|t_n| (-)');
set(gca, 'FontSize', 13);
title('tracked data (far fields used)');