function [T, indexMatrix] = getTfromSdyad (Sthetatheta, Sthetaphi, ...
    Sphitheta, Sphiphi, k, lebedevOrder, lMax)
%% get transition matrix from scattering dyadic
% Convertor transforming scattering dyadic to transition matrix. The guiding
% relation is T_{\alpha,\beta} = k / (4 \pi j) bra{Psi_\alpha} S
% ket{Psi_\beta} , Psi = - j^(l - \tau) Y, where Y are vector
% spherical harmonics, see "G. Kristensson, Scattering of Electromagnetic
% Waves by Obstacles, 2016". The function assumes the use of Lebedev's
% sampling of far field. Time dependence exp(j \omega t) is assumed. 
% Spherical waves are ordered according to indexMatrix(5,:).
%  
%
%  INPUTS
%   Sthetatheta, Sthetaphi, Sphitheta, Sphiphi: tensor components of 
%   scattering diadic, double [nLeb x nLeb]
%   k: wavenumber, double [1 x 1]
%   lebedevOrder:  order of Lebedev's quadrature, integer [1 x 1]
%   lMax:  maximum degree of spherical vector waves, integer [1 x 1]
%
%  OUTPUTS
%   T: transition matrix, double [nSW x nSW]
%
%  SYNTAX
%   [T, indexMatrix] = getTfromSdyad (Sthetatheta, Sthetaphi, ...
%     Sphitheta, Sphiphi, k, lebedevOrder, lMax)
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

Np = size(theta, 1); % number of Lebedev's points
nSW = size(indexMatrix,2); % number of spherical waves

if size(theta, 1) ~= size(Sthetatheta, 1)
    error('incompatible inputs')
end

% get conjugate Psi functions
PsiConj = conj(utilities.getPsi(lMax, theta, phi));

%% main loop: Sdyad --> T
T = zeros(nSW,nSW);
wb = waitbar(0,'transforming Sdyad to T');
for ip =  1:Np
    for iq =  1:Np

        T = T + ...
            weigths(ip,1)*weigths(iq,1).*( ...
            PsiConj(:,ip,2)*Sthetatheta(ip,iq)*PsiConj(:,iq,2)' + ...
            PsiConj(:,ip,2)*Sthetaphi(ip,iq)*PsiConj(:,iq,3)' + ...
            PsiConj(:,ip,3)*Sphitheta(ip,iq)*PsiConj(:,iq,2)' + ...
            PsiConj(:,ip,3)*Sphiphi(ip,iq)*PsiConj(:,iq,3)' ...
            );
        
    end
    waitbar(ip/Np,wb)
end
close(wb)

% final scaling
T = T*k/(4*pi*1i);

end