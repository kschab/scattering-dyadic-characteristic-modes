function Sdyad = getSdyadFromT (T, k, lebedevOrder, lMax)
%% get scattering dyadic from transition matrix
% Convertor transforming transition matrix to scattering dyadic. The guiding
% relation is S = 4 \pi j / k \sum_{\alpha,\beta} T_{\alpha,\beta}
% ket{Psi_\alpha} bra{Psi_\beta}, Psi = - j^(l - \tau) Y, where Y are vector
% spherical harmonics, see "G. Kristensson, Scattering of Electromagnetic
% Waves by Obstacles, 2016". The function assumes the use of Lebedev's
% sampling of far field. Time dependence exp(j \omega t) is assumed. 
% Spherical waves are ordered according to indexMatrix(5,:).
% S = [[Sthetatheta, Sthetaphi];[Sphitheta,Sphiphi]]
%
%  INPUTS
%   T: transition matrix, double [nSW x nSW]
%   k: wavenumber, double [1 x 1]
%   lebedevOrder: order of Lebedev's quadrature, integer [1 x 1]
%   lMax:  maximum degree of spherical vector waves, integer [1 x 1]
%
%  OUTPUTS
%   Sdyad: scattering dyadic, double [(2 nLeb) x (2 nLeb)]
%
%  SYNTAX
%   Sdyad = getSdyadFromT (T, lebedevOrder, lMax)
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

Np = size(theta, 1); % number of Lebedev's points

% get Psi functions, Spherical waves are ordered according to indexMatrix(5,:).
Psi = utilities.getPsi(lMax, theta, phi);

% initialization
Sdyadthetatheta = zeros(Np);
Sdyadthetaphi = zeros(Np);
Sdyadphitheta = zeros(Np);
Sdyadphiphi = zeros(Np);

%%
wb = waitbar(0,'transforming T to Sdyad');
for ip =  1:Np
    for iq =  1:Np

        Sdyadthetatheta(ip,iq) = Psi(:,iq,2)'*T*Psi(:,ip,2);
        Sdyadthetaphi(ip,iq) = Psi(:,iq,3)'*T*Psi(:,ip,2);
        Sdyadphitheta(ip,iq) = Psi(:,iq,2)'*T*Psi(:,ip,3);
        Sdyadphiphi(ip,iq) = Psi(:,iq,3)'*T*Psi(:,ip,3);

    end
    waitbar(ip/Np,wb)
end
close(wb)

%%

% final matrix form
Sdyad = [[Sdyadthetatheta, Sdyadthetaphi];[Sdyadphitheta,Sdyadphiphi]];

% multiplication by units
Sdyad = 4*pi*1i/k*Sdyad;

end