function out = EiSW (kx, ky, kz, k0, ka, sWind, component)

loadFag = 0;
% kx,ky,kz: k0*{x,y,z} [N x 1]
% k0: wavenumber [1 x 1]
% ka: electric size [1 x 1]
% loadFag: {0,1} flag saying if the file with aInc vector is loaded or not
% sWind is the index of spherical waves which follows indexMatrix(5,:), [1 x 1]
% component: {1,2,3} selector of output cartesian vector component

k0 = k0(1,1); % Comsol make it as long as kx
ka = ka(1,1); % Comsol make it as long as kx
sWind = sWind(1,1); % Comsol make it as long as kx
component = component(1,1); % Comsol make it as long as kx

if loadFag
    % aIncVec is ordered according to indexMatrix(5,:)
    % aIncVec [1 x M] is vector of complex amplitudes of waves indexed via sWindVec
    % sWindVec is vector of spherical indices corresponding to aIncVec [1 x M]
    load('aInc.mat')
else
    aIncVec = 1;
    sWindVec = sWind;
end


%% spherical wave setup

waveType = 1; % type of radial function

lmax = ceil(ka + 7*(ka)^(1/3) + 3);

indexMatrix = ...
    sphericalVectorWaves.indexMatrix(lmax);

EincSph = zeros(size(kx,1), 3); % total Ei (initialization)
for i1 = 1:size(sWindVec,2)

% calculate which column of indexMatrix is used
columnInd = find(indexMatrix(5,:) == sWindVec(1,i1), 1);

%% generate incident field - vector spherical wave

% all is normalized to k0, so r is trully k0*r
[r, theta, phi] = utilities.cart2sph(kx, ky, kz);

[u12, u11, u22, u21, ~, ~] = ...
    sphericalVectorWaves.functionU(...
    [indexMatrix(1,columnInd);1], [indexMatrix(2,columnInd);0], theta, phi, r, waveType);

% if there is only one point, the squeeze change rows and columns
squeezeFlag = false;
if size(u12,2) == 1
   squeezeFlag = true; 
end    

% tau = 1, sigma = 1
if indexMatrix(4,columnInd) == 1 && indexMatrix(3,columnInd) == 1
    PartialEincSph = squeeze(u11(1,:,:));
    
% tau = 1, sigma = 2
elseif indexMatrix(4,columnInd) == 1 && indexMatrix(3,columnInd) == 2
    PartialEincSph = squeeze(u12(1,:,:));
    
% tau = 2, sigma = 1
elseif indexMatrix(4,columnInd) == 2 && indexMatrix(3,columnInd) == 1
    PartialEincSph = squeeze(u21(1,:,:));
    
% tau = 2, sigma = 2
elseif indexMatrix(4,columnInd) == 2 && indexMatrix(3,columnInd) == 2
    PartialEincSph = squeeze(u22(1,:,:));
    
else
    error('something wrong')
    
end

% if there is only one point, the squeeze change rows and columns
if squeezeFlag
    PartialEincSph = PartialEincSph.';
end

% total incident field
EincSph = EincSph + PartialEincSph*aIncVec(1,i1);

end

% multiply by proper constant
Z0 = 3.767303137706895e+02;
EincSph = EincSph*k0*sqrt(Z0);

% transform to cartesian coordinates
EincCart = nan(size(EincSph));
[EincCart(:,1), EincCart(:,2), EincCart(:,3)] = utilities.vecSph2Cart( ...
    EincSph(:,1), EincSph(:,2), EincSph(:,3), theta, phi);

% select the desired component
if component == 1 % Ex
    out = EincCart(:,1);
elseif component == 2 % Ey
    out = EincCart(:,2);
elseif component == 3 % Ez
    out = EincCart(:,3);    
else
   error('something wrong') 
end 

    
end