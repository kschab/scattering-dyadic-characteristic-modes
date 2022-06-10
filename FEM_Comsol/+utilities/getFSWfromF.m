function [fSW, indexMatrix] = getFSWfromF (Ftheta, Fphi, lebedevOrder, lMax)
%% get spherical f-vectors from far field vectors
% Convertor transforming far field F vectors to spherical expansion
% coefficients f. The guiding relation is
% F = sqrt(Z) \sum_alpha f_alpha Psi_alpha, Psi = - j^(l - \tau) Y,
% where Y are vector spherical harmonics, see "G. Kristensson, 
% Scattering of Electromagnetic Waves by Obstacles, 2016". The function 
% assumes the use of Lebedev's sampling of far field. Time dependence 
% exp(j \omega t) is assumed. Spherical waves are ordered
% according to indexMatrix(5,:).
%
%  INPUTS
%   Ftheta, Fphi: vector components of far field vectors sampled at nLeb
%                 points, double [nLeb x M]
%   lebedevOrder:  order of Lebedev's quadrature, integer [1 x 1]
%   lMax:  maximum degree of spherical vector waves, integer [1 x 1]
%
%  OUTPUTS
%   fSW: spherical expansion coefficients, double [nSW x M]
%   indexMatrix: ordering of spherical vector waves, integer [5 x nSW]
%
%  SYNTAX
%   [fSW, indexMatrix] = getFSWfromF (Ftheta, Fphi, lebedevOrder, lMax)
%
% (c) 2022, Lukas Jelinek, CTU in Prague, lukas.jelinek@fel.cvut.cz


%% minimum neccesary Lebedev's order
lebedevOrderMin = 4/3*(lMax - 2)^2;

if lebedevOrderMin > lebedevOrder
    warning('Minimum Lebedev order is smaller than the supplied one')
end

%% precalculate spherical harmonics and initialize variables
indexMatrix = ...
    sphericalVectorWaves.indexMatrix(lMax);

% get Lebedev's quadrature points and weights
[rHat, weigths, ~] = utilities.getLebedevSphere(lebedevOrder);
[~, theta, phi] = utilities.cart2sph(...
    rHat(:,1), rHat(:,2), rHat(:,3));

nF = size(Fphi,2); % number of farfields
Np = size(theta, 1); % number of Lebedev's points
nSW = size(indexMatrix,2); % number of spherical waves

if size(theta, 1) ~= size(Fphi, 1)
    error('incompatible inputs')
end

% get conjugated Psi functions
PsiConj = conj(utilities.getPsi (lMax, theta, phi));

%% main loop: F --> f
fSW = zeros(nSW,nF);
wb = waitbar(0,'transforming F to f');
for iff =  1:nF
    for ip =  1:Np

        fSW(:,iff) = fSW(:,iff) + ...
            weigths(ip,1).*( Ftheta(ip,iff)*PsiConj(:,ip,2) + ...
            Fphi(ip,iff)*PsiConj(:,ip,3));
    end
    waitbar(iff/nF,wb)
end
close(wb)

% final scaling
Z0 = 3.767303137706895e+02;
fSW = fSW/sqrt(Z0);

end