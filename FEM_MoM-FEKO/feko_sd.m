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
% (c) 2022-2025, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

options.batchLength     = 10;   % =20 for student's edition of FEKO
options.deleteAuxFiles  = true; % perform cleanup
options.preFEKOfileName = 'scatteringDyadicEvaluation';
options.storeTempData   = true;
if ~isfield(options, 'eigSolver')
    options.eigSolver = 'std'; % {std, subs}
end
fprintf(1, '''%s'' Solver used for the direct CMA evaluation.\n', ...
    upper(options.eigSolver));

%% ------------------------------------------------------------------------
% Calculate scattering dyadic matrices
if ~MRHS % Sequential PW excitation (arbitrary solver, etc.)
    [S, quadrature, PW, FF, tt] = feko.calculateScatteringDyadic(...
        model, k0, Materials, nDegree, solver, EXTR, options);
else % Multiple right hand sides at once (requires direct sparse solver)
    solver = feko.getSolverOption('directSparse');

    EXTR{end+1} = sprintf('\n** Feko solution parameters\n');
    EXTR{end+1} = sprintf('FP: 0 : 0\n');

    [S, quadrature, PW, FF, tt] = feko.calculateScatteringDyadic_MRHS(...
        model, k0, Materials, nDegree, solver, EXTR, options);
end

% Assign all output variables
CMA_SD.S         = S;
CMA_SD.k0        = k0;
CMA_SD.PW        = PW;
CMA_SD.FF        = FF;
CMA_SD.P         = [quadrature.x, quadrature.y, quadrature.z];
CMA_SD.tt        = tt;
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
% "S" contains one specific "model" for 'std' solver and C+U and U "models" 
% for 'subs' solver...
[A_n, t_n, W] = bin.decomposeScatteringDyadic(...
    S, k0, quadrature.w, options.eigSolver);

CMA_SD.W  = W;
CMA_SD.Fn_orig = A_n; % Eigenvectors are characteristic excitation
CMA_SD.tn_orig = t_n;
CMA_SD.type    = options.eigSolver;

% Far-field tracking
if length(k0) > 1
    CMA_SD = bin.farFieldTracking(CMA_SD);
end

% Save the data
fullFileName = fullfile('data', [outputFileName '.mat']);

if exist(fullFileName, 'file')
    save(fullFileName, 'CMA_SD', '-append');
else
    save(fullFileName, 'CMA_SD'); 
end
fprintf(2, '*** CMA Evaluation complete! *** \n');