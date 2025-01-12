function FF = sphericalFarField(frequency, fVec, indexVec, theta, phi)
%% sphericalFarField computes far-field base on f vector
% Computes spherical waves far-field dependent on vector fVec containing
% expansion coefficients.
%
%  INPUTS
%   frequency:    frequency, double [1 x 1]
%   fVec:         weighting vector, double [M x 1]
%   indexVec:     logical vector of containing information about use of
%                 specific spherical wave, must have M ones,
%                   logical [K x 1]
%   theta         vector of points in theta spherical coordinate,
%                  double [N x 1]
%   phi           vector of points in phi spherical coordinate,
%                  double [N x 1]
%
%  OUTPUTS
%   FF:           structure with all computed quantities,
%                   struct [1 x 1]
%
%  SYNTAX
%   FF = sphericalFarField(frequency, fVec)
%   FF = sphericalFarField(frequency, fVec, theta, phi)
%
% Included in AToM, info@antennatoolbox.com
% (c) 2021, Vit Losenicky, CTU in Prague, vit.losenicky@antennatoolbox.com
% mcode

%% input
nInputs = nargin;
if nInputs < 2
    error('sphericalFarField: Not enought input arguments.');
end
if nInputs < 3 || isempty(indexVec)
    indexVec = true(length(fVec), 1);
    fprintf(['sphericalFarField: Parameter ''indexVec'' ' ...
        'set automatically\n']);
end
if nInputs < 4
    theta = linspace(0, pi, 51);
    fprintf(['sphericalFarField: Parameter ''theta'' set to ' ...
        'vector with %.0f elements starting at %f ending at %f\n'], ...
        51, 0, pi);
end
if nInputs < 5
    phi = linspace(0, 2*pi, 102);
    fprintf(['sphericalFarField: Parameter ''phi'' set to ' ...
        'vector with %.0f elements starting at %f ending at %f\n'], ...
        102, 0, 2*pi);
end

%% prepare
c0  = 299792458;
mu0 = 4*pi*1.00000000082e-7;
Z0  = c0 * mu0;

maxL = roots([2 0 -(length(indexVec)+2)])-1;
maxL = round(maxL(maxL > 0));


indexVec = logical(indexVec);

FTheta = zeros(length(theta), length(phi));
FPhi = FTheta;

nTheta = length(theta);
nPhi = length(phi);

phi = phi.';

indexMatrix = sphWaves.indexMatrix(maxL);
indexMatrix = sortrows(indexMatrix.', 5).';

indexMatrix = indexMatrix(:, indexVec);
k = 2*pi*frequency/c0;

constant = fVec.' .* 1/k .* ...
    (1i).^(indexMatrix(1, :) + 2 - indexMatrix(4, :));

%% compute
for thetaInd = 1:nTheta
    thisTheta = theta(thetaInd) * ones(nPhi, 1);

    % compute spherical harmonics
    [Y1, Y2, ~] = sphWaves.functionY( ...
        indexMatrix(1,:).', indexMatrix(2, :).', thisTheta, phi);

    % fill part sigma = 1, tau = 1
    index = indexMatrix(4, :).' == 1 & indexMatrix(3, :).' == 1;

    FTheta(thetaInd, :) = ...
        FTheta(thetaInd, :) + (constant(index) * imag(Y1(index, :, 2)));

    FPhi(thetaInd, :) = ...
        FPhi(thetaInd, :) + (constant(index) * imag(Y1(index, :, 3)));

    % fill part sigma = 2, tau = 1
    index = indexMatrix(4, :).' == 1 & indexMatrix(3, :).' == 2;

    FTheta(thetaInd, :) = ...
        FTheta(thetaInd, :) + (constant(index) * real(Y1(index, :, 2)));

    FPhi(thetaInd, :) = ...
        FPhi(thetaInd, :) + (constant(index) * real(Y1(index, :, 3)));


    % fill part sigma = 1, tau = 2
    index = indexMatrix(4, :).' == 2 & indexMatrix(3, :).' == 1;

    FTheta(thetaInd, :) = ...
        FTheta(thetaInd, :) + (constant(index) * imag(Y2(index, :, 2)));

    FPhi(thetaInd, :) = ...
        FPhi(thetaInd, :) + (constant(index) * imag(Y2(index, :, 3)));

    % fill part sigma = 2, tau = 2
    index = indexMatrix(4, :).' == 2 & indexMatrix(3, :).' == 2;

    FTheta(thetaInd, :) = ...
        FTheta(thetaInd, :) + (constant(index) * real(Y2(index, :, 2)));

    FPhi(thetaInd, :) = ...
        FPhi(thetaInd, :) + (constant(index) * real(Y2(index, :, 3)));
end

%radiation intensity
Uconst = 1 / (2 * Z0);
UTheta = Uconst * abs(FTheta) .^2;
UPhi = Uconst * abs(FPhi) .^2;
U = UTheta + UPhi;

% total power integration
Prad = 0.5*(fVec')*fVec/k^2/Z0;

% directivity
if ~isempty(Prad) && Prad ~= 0
    DTheta = 4 * pi * UTheta / Prad;
    DPhi = 4 * pi * UPhi / Prad;
    D = DTheta + DPhi;
else
    DTheta = [];
    DPhi = [];
    D = [];
end

%% output
FF.theta = theta;
FF.phi = phi;
FF.FTheta = FTheta;
FF.FPhi = FPhi;
FF.U = U;
FF.UTheta = UTheta;
FF.UPhi = UPhi;
FF.D = D;
FF.DTheta = DTheta;
FF.DPhi = DPhi;
FF.Prad = Prad;
end
