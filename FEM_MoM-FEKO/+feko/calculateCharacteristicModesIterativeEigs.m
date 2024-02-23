function [V, N, quadrature, PW, FF, Info] = ...
    calculateCharacteristicModesIterativeEigs(...
    models, k0, Materials, nDegree, solver, EXTR, options)
%% CALCULATECHARACTERISTICMODESITERATIVEEIGS: low-level iterative wrapper
%  for FEKO_ICM.m
% 
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

deleteAuxFiles  = options.deleteAuxFiles;
preFEKOfileName = options.preFEKOfileName;
modes           = options.nModes;
relError        = options.relativeError;
eigSolver       = options.eigSolver;

%% Upload Lebedev quadrature
quadrature = bin.getLebedevSphere(nDegree);

% theta, phi for the quadrature points
[~, th, ph] = bin.cart2sph(quadrature.x, quadrature.y, quadrature.z);

% Wavenumber
const = bin.constants();
f0    = const.c0*k0/(2*pi);
r2d   = @(x) 180*x/pi; % radians to degre

% Excitation via plane waves
thPW = r2d(pi - [th; th]); % rotate angles to agree with our definition of
phPW = r2d(pi + [ph; ph]); % scattering dyadics
pol  = r2d([pi*ones(nDegree,1); -pi/2*ones(nDegree,1)]); % [th ph]
PW   = [thPW, phPW, pol];

% Far field measurements
FF = r2d([th ph]);
W  = blkdiag(diag(quadrature.w), diag(quadrature.w));

t0 = tic();
Info.iter  = 0;

switch lower(eigSolver)
%     case 'eigs'
%         [V, N]  = eigs(...
%             @iterativeEvaluation, ...
%             size(PW, 1), modes, 'largestabs', 'Tolerance', 1e-5);
%     case 'eit'
%         [V, N, Info.iter, Info.error] = feko.iterativeEig(...
%             @iterativeEvaluation, ...
%             size(PW, 1), modes, relError);
    case 'std'
        [V, N, Info.Sn, Info.iter, Info.tn, Info.Error, Info.error] = ...
            feko.iterativeEigStable(@iterativeEvaluation, ...
            W, size(PW, 1), modes, relError);
    case 'subs'
        nodes = [quadrature.x, quadrature.y, quadrature.z];
        % Get permutation matrix:
        C     = bin.getPermutationMatrix(nodes);

        [V, N, Info.Sn, Info.iter, Info.tn, Info.Error, Info.error] = ...
            feko.iterativeEigStableSubs(@iterativeEvaluation, ...
            W, C, size(PW, 1), modes, relError);        
    otherwise
        fprintf(2, 'Wrong solver selection!\n');
        V = [];
        N = [];
end

    function Fn1 = iterativeEvaluation(En0, model)
        % For non-substructure (standard call)
        if nargin == 1
            model = 1;
        end
        if model == 1
            Info.iter = Info.iter + 1;
        end        

        % Provide excitation with Lebedev weights to give the problem
        % physical scaling (equivalent to sqrt(W).' * S * sqrt(W))
        En0   = W * En0;

        amp   = abs(En0);
        phase = r2d(angle(En0));
        PW0   = [amp, phase, PW];

        feko.preFEKO_nPW_nFF_charMode(preFEKOfileName, ...
            models{model}, Materials, f0, PW0, FF, solver, EXTR);
        
        %% Run PRE-feko file
        clc;
        fprintf(1, 'Iteration: %d, k0 = %1.1f, model: %d\n\n', ...
            Info.iter, k0, model);
        dos(['runfeko ' preFEKOfileName '.pre --execute-prefeko -np all']);
        
        %% Process far fields (for all frequencies in the batch)
        Fn1 = feko.readFEKOfarFields(preFEKOfileName, nDegree); % K * 
        
        % Rescale the far-field so that eig(Fn*An') gives directly tn,
        % i.e., T-matrix-type structure is directly constructed
        K   = -1j * k0 / (4*pi);
        Fn1 = K * Fn1;

        %% Clean up unnecessary files
        if deleteAuxFiles
            fclose('all');
            feko.cleanupFEKOsolverFiles(preFEKOfileName);
            feko.cleanupFEKOfarfieldFiles(preFEKOfileName);
        end

        Info.En(:, Info.iter) = En0;
        Info.Fn(:, Info.iter) = Fn1;

        save('Info.mat', 'Info');
    end

Info.tt = toc(t0);
delete('Info.mat');
end