function [Ftheta, Fphi] = getFfromFSW (fSW, lebedevOrder, lMax)
%% get spherical far field vectors from f-vectors
% Convertor transforming spherical expansion coefficients f to far field F 
% vectors. The guiding relation is
% F = sqrt(Z) \sum_alpha f_alpha Psi_alpha, Psi = - j^(l - \tau) Y,
% where Y are vector spherical harmonics, see "G. Kristensson, 
% Scattering of Electromagnetic Waves by Obstacles, 2016". The function 
% assumes the use of Lebedev's sampling of far field. Time dependence 
% exp(j \omega t) is assumed. Spherical waves are ordered
% according to indexMatrix(5,:).
%
%  INPUTS
%   fSW: spherical expansion coefficients, double [nSW x M]
%   lebedevOrder:  order of Lebedev's quadrature, integer [1 x 1]
%   lMax:  maximum degree of spherical vector waves, integer [1 x 1]
%
%  OUTPUTS
%   Ftheta, Fphi: vector components of far field vectors sampled at nLeb
%                 points, double [nLeb x M]
%
%  SYNTAX
%   [Ftheta, Fphi] = getFfromFSW (fSW, lebedevOrder, lMax)
%
% (c) 2022, Lukas Jelinek, CTU in Prague, lukas.jelinek@fel.cvut.cz


%% maximum allowed Lebedev's order

% find closest Lebedev's order higher thant the desired one
lebTmp = [6, 14, 26, 38, 50, 74, 86, 110, 146, 170, 194, 230, 266, 302, ...
  350, 434, 590, 770, 974, 1202, 1454, 1730, 2030, 2354, 2702, 3074, ...
  3470, 3890, 4334, 4802, 5294, 5810];
ind = find(lebTmp > 4/3*(lMax - 2)^2,1 );
lebedevOrderMax = lebTmp(1, ind);

if lebedevOrderMax < lebedevOrder
    warning('Desired Lebedev order is too high')
end

%% precalculate spherical harmonics and initialize variables

% get Lebedev's quadrature points and weights
[rHat, ~, ~] = utilities.getLebedevSphere(lebedevOrder);
[~, theta, phi] = utilities.cart2sph(...
    rHat(:,1), rHat(:,2), rHat(:,3));

nF = size(fSW,2); % number of farfields
Np = size(theta, 1); % number of Lebedev's points

% get Psi functions
Psi = utilities.getPsi(lMax, theta, phi);

%% main loop: f --> F
Ftheta = zeros(Np,nF);
Fphi = zeros(Np,nF);

wb = waitbar(0,'transforming f to F');
for iff =  1:nF
    Ftheta(:,iff) = sum(repmat(fSW(:,iff),[1,Np,1]).*Psi(:,:,2),1).';
    Fphi(:,iff) = sum(repmat(fSW(:,iff),[1,Np,1]).*Psi(:,:,3),1).';
waitbar(iff/nF,wb)
end
close(wb)

% final scaling
Z0 = 3.767303137706895e+02;
Ftheta = Ftheta*sqrt(Z0);
Fphi = Fphi*sqrt(Z0);

end