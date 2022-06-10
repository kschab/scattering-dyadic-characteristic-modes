function [F_n, t_n, W] = decomposeScatteringDyadic(S, k0, w)
% DECOMPOSESCATTERINGDYADIC: eigendecomposition yielding characteristic
% modes
% 
% Inputs:
%    S  ~ scattering dyadic matrices (3D array)
%    k0 ~ wavenumber
%    w  ~ quadrature weights of Lebedev quadrature of chosen degree
% 
% Outputs:
%    F_n ~ eigen-vectors
%    t_n ~ eigen-numbers (correspond to char. values of transition matrix)
%    W   ~ normalization matrix (containing quadrature weights)
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

% Allocations
nFreqs = size(S, 3);
nWaves = size(S, 2);

% Upload physical constants
const = bin.constants();

% Allocate matrix for eigenvalues
t_n = nan(nWaves, nFreqs);
F_n = nan(nWaves, nWaves, nFreqs);

% Decompose scattering matrix
W = blkdiag(diag(w), diag(w));
for thisFreq = 1:nFreqs
    SN    = S(:,:,thisFreq) * W;
    [Fn, sigma] = eig(SN);
    
    % Radiated power
    Prad = 1/(2*const.Z0) * diag(real(Fn' * W * Fn));
    
    % Normalization to unitary radiated power
    F_n(:, :, thisFreq) = Fn ./ sqrt(Prad.');
    
    % Characteristic values (lambdan = 1j*(tn + 1)/tn)
    t_n(:, thisFreq) = -1j*k0(thisFreq) / (4*pi) * diag(sigma);
    
    % Sort the data from the most modal significant to the less...
    [~, inds] = sort(abs(t_n(:, thisFreq)), 'descend');
    
    % Re-order data with respect to the magnitude of characteristic numbers
    F_n(:, :, thisFreq) = F_n(:, inds, thisFreq);
    t_n(:, thisFreq)    = t_n(inds, thisFreq);
end