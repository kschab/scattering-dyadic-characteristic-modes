function [S, quadrature, PW, FF, tt] = calculateScatteringDyadic_MRHS(...
    models, k0, Materials, nDegree, solver, EXTR, options)
%% CALCULATESCATTERINGDYADIC_MRHS: low-level wrapper for FEKO_SD.m
% 
% Inputs:
%   models    ~ filename(s) of CFM file(s) with the FEKO model and 
%               settings. It is expected that all models are saved in 
%               [models] folder
%   k0        ~ wavenumber (in vacuum)
%   Materials ~ for its structure, see one of the examples
%   nDegree   ~ number of the Lebedev degree
%   solver    ~ EM solver to be used in FEKO (see feko.getSolverOption)
%   EXTR      ~ additional features (like infinite ground plane,
%               etc., see examples how to use it), can be empty
%   options   ~ optional parameters, see FEKO_SD.m for details
% 
% Ouputs:
%   S          ~ 3D array (double complex) containing the scattering dyadic
%                matrices
%   quadrature ~ information about quadrature ([x y z] points and weights)
%   PW         ~ definition of the plane waves used for the excitation,
%                each plane wave is a vector containing:
%                [theta incidence, phi incidence, polarization].
%                This vector is compatible with FEKO coordinate system.
%   FF         ~ definition of the far field points evaluated in FEKO (in
%                FEKO coordinate system)
%   tt         ~ total computational time
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

batchLength     = options.batchLength;
deleteAuxFiles  = options.deleteAuxFiles;
preFEKOfileName = options.preFEKOfileName;
storeTempData   = options.storeTempData;

tempFileName = 'TEMP_calculateScatteringDyadics_MRHS';

%% Upload Lebedev quadrature
quadrature = bin.getLebedevSphere(nDegree);

% theta, phi for the quadrature points
[~, th, ph] = bin.cart2sph(quadrature.x, quadrature.y, quadrature.z);

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

% To allocate for cycles
nWaves     = 2*nDegree;
nFreqs     = length(f0);
nModels    = length(models);

% Allocation for scattering dyadic matrix
S = nan(nWaves, nWaves, nFreqs, nModels);

% Run the sweep for all frequencies
freqA = 1:batchLength:nFreqs;
freqB = [batchLength:batchLength:(nFreqs-1), nFreqs];
iterDone  = 0; % number of plane waves processed (in total)
iterTotal = nModels*nFreqs;

% Display status waitbar
t0  = tic();
wtb = waitbar(0, 'Evaluating for all source plane waves...', ...
    'Name', 'Evaluating scat. dyad. mat. (FEKO)');

%% Simulation:
for thisBatch = 1:length(freqA)
    % Evaluate for all incident point and polarization
    batchFreq   = f0(freqA(thisBatch):freqB(thisBatch));
    nBatchFreqs = length(batchFreq);

    for thisModel = 1:nModels

        % Prepare PRE FEKO wrapper for evaluation for one wave
        feko.preFEKO_nPW_nFF_Sdyadic(preFEKOfileName, models{thisModel}, ...
            Materials, batchFreq, PW, FF, solver, EXTR);

        %% Run PRE-feko file
        clc;
        % it might be problem with memory since multiple RHS
        dos(['runfeko ' preFEKOfileName '.pre --execute-prefeko -np all']);
%         dos(['runfeko ' preFEKOfileName '.pre --execute-prefeko -np 1']);        

        %% Process far fields (for all frequencies in the batch)
        % Upload data from multiple ffe files
        thisBlock(:, 1, :) = feko.readFEKOfarFields(...
                preFEKOfileName, nDegree);
        for n = 2:nWaves
            thisPW = ['(' num2str(n-1) ')'];
            thisBlock(:, n, :) = feko.readFEKOfarFields(...
                preFEKOfileName, nDegree, thisPW);
        end

        % Put data together
        sizeFits = all(size(thisBlock, 1:3) == [nWaves, nWaves, nBatchFreqs]);
        if sizeFits
            S(:, :, freqA(thisBatch):freqB(thisBatch), thisModel) = ...
                thisBlock;
        end

        %% Clean up unnecessary files
        if deleteAuxFiles
            feko.cleanupFEKOsolverFiles(preFEKOfileName);
        end

        %% Update waitbar and progress bar
        iterDone = iterDone + nBatchFreqs;
        tt = toc(t0);
        waitbar(iterDone/iterTotal, wtb, ...
            sprintf('%d/%d done (B: %d)\n Elapsed: %1.0fs | Remaining: %1.0fs', ...
            iterDone, iterTotal, thisBatch, tt, tt*(1/iterDone*iterTotal - 1)));

        %% Back-up temporal data into mat file
        if storeTempData
            save([tempFileName '.mat'], ...
                'S', 'quadrature', 'PW', 'thisBatch', 'thisModel', ...
                'options', 'k0', 'iterDone', 'iterTotal', 'tt');
        end
    end

    %% Delete far field files
    if deleteAuxFiles
        feko.cleanupFEKOfarfieldFiles(preFEKOfileName);
        feko.cleanupFEKOcurrents(preFEKOfileName);
        feko.cleanupFEKOconfigfile();
    end
end

% Clear temporary mat file used to backup columns of the scattering dyadic
if storeTempData
    delete([tempFileName '.mat']);
end

% Delete waitbar, save total computational time
delete(wtb);
tt = toc(t0);