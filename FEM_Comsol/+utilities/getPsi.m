function [Psi, indexMatrix] = getPsi (lMax, theta, phi)
%% get spherical Psi-functions
% Function returning spherical Psi functions defined as 
% Psi = - j^(l - \tau) Y, where Y are vector spherical harmonics, see 
% "G. Kristensson, Scattering of Electromagnetic Waves by Obstacles, 2016". 
% Time dependence exp(j \omega t) is assumed. Spherical waves are ordered
% according to indexMatrix(5,:).
%
%  INPUTS
%   lMax:  maximum degree of spherical vector waves, integer [1 x 1]
%   theta, phi: observation spherical angles, double [Np x 1]
%
%  OUTPUTS
%   Psi: sampled Psi functions [r0; theta0; phi0], double [nSW x Np x 3]
%
%  SYNTAX
%   [Psi, indexMatrix] = getPsi (lMax, theta, phi)
%
% (c) 2022, Lukas Jelinek, CTU in Prague, lukas.jelinek@fel.cvut.cz

indexMatrix = ...
    sphericalVectorWaves.indexMatrix(lMax);

Np = size(theta, 1); % number of observation points
nSW = size(indexMatrix,2); % number of spherical waves

% spherical harmonics
[Y1, Y2, ~] = sphericalVectorWaves.functionY(...
    indexMatrix(1,:).', indexMatrix(2,:).', theta(:,1), phi(:,1));

% Psi = - j^(l - \tau) Y
% (tau, sigma)
Psi11 = repmat(- (1i).^(indexMatrix(1,:).' - 1), [1, Np, 3]).*imag(Y1);
Psi12 = repmat(- (1i).^(indexMatrix(1,:).' - 1), [1, Np, 3]).*real(Y1);
Psi21 = repmat(- (1i).^(indexMatrix(1,:).' - 2), [1, Np, 3]).*imag(Y2);
Psi22 = repmat(- (1i).^(indexMatrix(1,:).' - 2), [1, Np, 3]).*real(Y2);

% precalculation of indexing vectors (tau, sigma)
ind11 = indexMatrix(4, :) == 1 & indexMatrix(3, :) == 1;
ind12 = indexMatrix(4, :) == 1 & indexMatrix(3, :) == 2;
ind21 = indexMatrix(4, :) == 2 & indexMatrix(3, :) == 1;
ind22 = indexMatrix(4, :) == 2 & indexMatrix(3, :) == 2;

% construct final Psi
Psi = zeros(nSW,Np,3);
Psi(ind11,:,:) = Psi11(ind11,:,:);
Psi(ind12,:,:) = Psi12(ind12,:,:);
Psi(ind21,:,:) = Psi21(ind21,:,:);
Psi(ind22,:,:) = Psi22(ind22,:,:);

% reordering according to indexMatrix
Psi(indexMatrix(5, :),:,:) = Psi;

end