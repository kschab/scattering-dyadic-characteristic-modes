function [fSW] = projectEsTof(lmax, k0, gridEs, EsCart)
%% get spherical f-vectors from sampled scattered field
% Convertor transforming sampled scattered electric field to spherical 
% expansion coefficients f. The guiding relation is
% Es = k*sqrt(Z) \sum_alpha f_alpha u^(4)_alpha, where u^(4) are outgoing 
% spherical vector waves, see "G. Kristensson, Scattering of 
% Electromagnetic Waves by Obstacles, 2016". The function 
% assumes the use of Lebedev's sampling of the scattered field. The 
% scattered field must be sampled on a sphere circumscribing the scatterer.
% Time dependence exp(j \omega t) is assumed. Spherical waves are ordered
% according to indexMatrix(5,:).
%
%  INPUTS
%   lMax:  maximum degree of spherical vector waves, integer [1 x 1]
%   k0: wavenumber, double [1 x 1]
%   gridEs:  grid of Lebedev's points, double [Nleb x 3]
%   EsCart:  Es at Lebedev's points, double [Nleb x 3]
%
%  OUTPUTS
%   fSW: spherical expansion coefficients, double [nSW x 1]
%
%  SYNTAX
%   [fSW] = projectEsTof(lmax, k0, gridEs, EsCart)
%
% (c) 2022, Lukas Jelinek, CTU in Prague, lukas.jelinek@fel.cvut.cz


%% check validity of Lebedev grid
[gridEs, weigths] = utilities.checkGridEs(gridEs);

%% get auxiliary quantities
indexMatrix = ...
    sphericalVectorWaves.indexMatrix(lmax);

nSW = size(indexMatrix,2);

[r, theta, phi] = utilities.cart2sph(...
    gridEs(:,1), gridEs(:,2), gridEs(:,3));

Np = size(gridEs,1);

% transform E to spherical coordinates
Esph = utilities.vecCart2Sph(EsCart, theta, phi);

%% get radial functions

[R1, R2, ~, ~] = sphericalVectorWaves.functionR(...
    indexMatrix(1,:), k0*r(1,1), 4);

R = zeros(nSW,1);
% tau = 1
ind = (indexMatrix(4, :) == 1);
R(ind, 1) = R1(ind, 1);
% tau = 2
ind = (indexMatrix(4, :) == 2);
R(ind, 1) = R2(ind, 1);

%% calculate projections

fSW = zeros(nSW,1); % spherical expansion vector

bar = waitbar(0,'projection to spherical waves');
for ip = 1:Np
    [Y1, Y2, ~] = sphericalVectorWaves.functionY(...
        indexMatrix(1,:).', indexMatrix(2,:).', theta(ip,1), phi(ip,1));
    Y1 = squeeze(Y1);
    Y2 = squeeze(Y2);
    
    tmp11 = utilities.rowDot(imag(Y1),repmat(Esph(ip,:),[nSW,1]));
    tmp21 = utilities.rowDot(real(Y1),repmat(Esph(ip,:),[nSW,1]));
    tmp12 = utilities.rowDot(imag(Y2),repmat(Esph(ip,:),[nSW,1]));
    tmp22 = utilities.rowDot(real(Y2),repmat(Esph(ip,:),[nSW,1]));
    
    % sigma = 1, tau = 1
    ind = indexMatrix(4, :) == 1 & indexMatrix(3, :) == 1;
    fSW(indexMatrix(5, ind),1) = fSW(indexMatrix(5, ind),1) + weigths(ip,1)*tmp11(ind,1);
    
    % sigma = 2, tau = 1
    ind = indexMatrix(4, :) == 1 & indexMatrix(3, :) == 2;
    fSW(indexMatrix(5, ind),1) = fSW(indexMatrix(5, ind),1) + weigths(ip,1)*tmp21(ind,1);
    
    % sigma = 1, tau = 2
    ind = indexMatrix(4, :) == 2 & indexMatrix(3, :) == 1;
    fSW(indexMatrix(5, ind),1) = fSW(indexMatrix(5, ind),1) + weigths(ip,1)*tmp12(ind,1);
    
    % sigma = 2, tau = 2
    ind = indexMatrix(4, :) == 2 & indexMatrix(3, :) == 2;
    fSW(indexMatrix(5, ind),1) = fSW(indexMatrix(5, ind),1) + weigths(ip,1)*tmp22(ind,1);
    
waitbar(ip/Np,bar,'projection to spherical waves')
end
close(bar)

Z0 = 3.767303137706895e+02;
fSW = fSW./(k0*sqrt(Z0)*R);

end
