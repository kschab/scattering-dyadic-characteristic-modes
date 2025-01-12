function [A_n, t_n, W] = decomposeScatteringDyadic(S, k0, w, solver)
% DECOMPOSESCATTERINGDYADIC: eigendecomposition yielding characteristic
% modes
% 
% Inputs:
%    S  ~ scattering dyadic matrices (3D array)
%    k0 ~ wavenumber
%    w  ~ quadrature weights of Lebedev quadrature of chosen degree
% 
% Outputs:
%    A_n ~ eigen-vectors
%    t_n ~ eigen-numbers (correspond to char. values of transition matrix)
%    W   ~ normalization matrix (containing quadrature weights)
% 
% (c) 2022-2025, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

% Allocations
nFreqs = size(S, 3);
nWaves = size(S, 2);

% Upload physical constants
% const = bin.constants();

% Allocate matrix for eigenvalues
t_n = nan(nWaves, nFreqs);
A_n = nan(nWaves, nWaves, nFreqs);

% Decompose scattering matrix
W  = blkdiag(diag(w), diag(w));
W2 = blkdiag(diag(sqrt(w)), diag(sqrt(w)));
for thisFreq = 1:nFreqs
    % Normalization constant (consult the paper 10.1109/TAP.2022.3213945)
    K = -1j*k0(thisFreq) / (4*pi);

    if strcmp(solver, 'subs') % 'subs' solver (two models required)
        E   = eye(nWaves);

        % Transform scattering dyadics to matrices and normalize
        SM  = K * (W2.' * S(:,:,thisFreq,1) * W2);
        SM0 = K * (W2.' * S(:,:,thisFreq,2) * W2);
    
        % Transform normalized scat. dyad. mat. to T-matrix type structure
        % (being unitary - all eigenvalues are =1 for a lossless structure)
        S_  = (2*SM + E);
        S0_ = (2*SM0 + E);
    
        % Decompose as proposed in substructure paper
        [An, t] = eig(S_, S0_);
        t = diag((diag(t) - 1) / 2);
    else % 'std' solver (all decomposed individually)
        % Decomposition of normalized scattering dyadics
        SN = K * S(:,:,thisFreq) * W;
        [An, t] = eig(SN);
    end

    % Characteristic values (lambdan = 1j*(tn + 1)/tn)
    t_n(:, thisFreq) = diag(t);

    % % Radiated power
    % Prad = 1/(2*const.Z0) * diag(real(An' * W * An));
    % 
    % % Normalization to unitary radiated power
    % A_n(:, :, thisFreq) = An ./ sqrt(Prad.');

    % Normalization to unitary radiated power
    A_n(:, :, thisFreq) = bin.normalizeAnToRadiatedPower(An, W);

    % Sort the data from the most modal significant to the less...
    [~, inds] = sort(abs(t_n(:, thisFreq)), 'descend');
    
    % Re-order data with respect to the magnitude of characteristic numbers
    A_n(:, :, thisFreq) = A_n(:, inds, thisFreq);
    t_n(:, thisFreq)    = t_n(inds, thisFreq);
end