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

options.batchLength     = 1;   % =since each frequency is different
options.deleteAuxFiles  = true; % perform cleanup
options.preFEKOfileName = 'characteristicModeEvaluation';
options.storeTempData   = true;

%% ------------------------------------------------------------------------
% Calculate scattering dyadic matrices
N = length(k0);
S = nan(2*nDegree, 2*nDegree, N);
t0 = tic;
wtb = waitbar(0, 'Evaluating (potentially) dispersive scenario...', ...
    'Name', 'Evaluating scat. dyad. mat. (FEKO)');

if ~MRHS % Sequential PW excitation (arbitrary solver, etc.)
    for n = 1:N
        [S(:,:,n), quadrature, PW, FF] = feko.calculateScatteringDyadic(...
            model, k0(n), Materials{n}, nDegree, solver, EXTR, options);
        tt = toc(t0);
        waitbar(n/N, wtb, ...
                    sprintf('%d/%d done\n Elapsed: %5.1fs | Remaining: %5.1fs', ...
                    n, N, tt, tt*(1/n*N- 1)));
    end
else
    solver = feko.getSolverOption('directSparse');

    EXTR{end+1} = sprintf('\n** Feko solution parameters\n');
    EXTR{end+1} = sprintf('FP: 0 : 0\n');

    for n = 1:N
        [S(:,:,n), quadrature, PW, FF] = feko.calculateScatteringDyadic_MRHS(...
            model, k0(n), Materials{n}, nDegree, solver, EXTR, options);
        tt = toc(t0);
        waitbar(n/N, wtb, ...
                    sprintf('%d/%d done\n Elapsed: %5.1fs | Remaining: %5.1fs', ...
                    n, N, tt, tt*(1/n*N- 1)));
    end
end

for n = 1:N
    [S(:,:,n), quadrature, PW, FF] = feko.calculateScatteringDyadic(...
        model, k0(n), Materials{n}, nDegree, solver, EXTR, options);
    tt = toc(t0);
    waitbar(n/N, wtb, ...
                sprintf('%d/%d done\n Elapsed: %5.1fs | Remaining: %5.1fs', ...
                n, N, tt, tt*(1/n*N- 1)));
end
delete(wtb);

% Assign all output variables
CMA_SD.S         = S;
CMA_SD.k0        = k0;
CMA_SD.PW        = PW;
CMA_SD.FF        = FF;
CMA_SD.P         = [quadrature.x, quadrature.y, quadrature.z];
CMA_SD.tt        = toc(t0);
CMA_SD.model     = model;
CMA_SD.materials = Materials;
try
    save(fullfile('data', [outputFileName '.mat']), 'CMA_SD', '-append');
catch % When 'data' folder and/or *.mat file do not exist
    save(fullfile('data', [outputFileName '.mat']), 'CMA_SD');
end
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