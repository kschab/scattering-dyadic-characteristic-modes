function [Q, D, Sn, nIter, tn, Err, err] = iterativeEigStable(...
    Afun, W, nPW, nModes, relError)
% Implemented according Mats' proposal,
% https://en.wikipedia.org/wiki/Gram%E2%80%93Schmidt_process#Numerical_stability
%
% Afun     - function processing one call of FEKO solver
% W        - (Lebedev) quadrature weights
% nPW      - number of plane waves used
% nModes   - number of modes required
% relError - maximum allowable relative error between two iterations

nModes = min(nModes, nPW);

An = zeros(nPW);
Fn = zeros(nPW);
tn = double.empty(nPW, 0);

Err    = [];
err(1) = inf;
% random initial (far field) excitation
an     = complex(randn(nPW, 1), randn(nPW, 1));

nIter = 1;
while err(end) > relError

    an = an/norm(an); % normalization of excitation
    for m1 = 1:(nIter-1)     % Modified GS for projection matrix
        an = an - (An(:,m1)'*an)*An(:,m1);
    end

    % normAn = norm(an);
    normAn = sqrt(an' * an);

    An(:,nIter) = an / normAn;
    P = An*An';  % projection matrix
    % TODO: check eigenvalues of P (should be unitary, can be
    % rank-deficient)

    fn = Afun(an, 1); % scattered field computed with FEKO

    An(:,nIter) = an;  % excitations
    Fn(:,nIter) = fn;  % scattered field

    Sn = Fn(:,1:nIter)*An(:,1:nIter)'; % estimated T-matrix

    % get the estimate of characteristic mode decomposition
    [Q, D] = eig(Sn);
    tn(:, nIter) = sort(diag(D), 'descend', 'ComparisonMethod', 'abs');
    an = fn - P*fn;  % next excitation

    % relative error
    if nIter > 1
        Err(:, nIter) = ...
            abs(tn(1:nModes, nIter) - tn(1:nModes, nIter-1)) ./ ...
            abs(tn(1:nModes, nIter));
        err(nIter) = max(Err(:, nIter));
    end

    % save and terminate this iteration
    nIter = nIter + 1;
    save('TEMP_EITS.mat', 'nIter', 'err', 'Err', 'An', 'Fn', 'tn');
end
end