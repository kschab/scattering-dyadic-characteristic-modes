function [normLegendreSing, normLegendreSingDer, normLegendre] = ...
    legendreComponents(degreeL, orderM, cosTheta)
%% legendreComponents Calculates associated legendre polynomials and its 
% multiplies 
% It is used to buid M and N functons. Singularity treatment is 
% used.
%
%  INPUTS
%   degreeL:  degree l of legendre polynomial, double [N x 1]
%   orderM:   vector of orderes m belongings to degreel, double [N x 1]
%   cosTheta: cosinus of theta component coordinate of integration point, 
%             double [N x 1]
%   
%  OUTPUTS
%   normLegendreSing:    associated legendre polynomial with solved 
%                        singularities, (m/sin(theta)) * P, double [N x 1]
%   normLegendreSingDer: derivative of legenre polynomial, double [N x 1]
%   normLegendre:        legendre polynomial for degree l and order m, 
%                        double [N x 1]
%
%  SYNTAX
%   [normLegendreSing, normLegendreSingDer, normLegendre] = ...
%                           legendreComponents(degreeL, orderM, cosTheta)
%
% Included in AToM, info@antennatoolbox.com
% (c) 2019, Vit Losenicky, CTU in Prague, vit.losenicky@antennatoolbox.com
% mcode

%% precalculation
singConst1 =  ( (1/2) * sqrt( (2 * degreeL + 1) ./ (2 * degreeL + 3) ));
singConst2 =  ( sqrt( (degreeL + orderM + 2) .* (degreeL + orderM + 1) ));
singConst3 =  ( sqrt( (degreeL - orderM + 2) .* (degreeL - orderM + 1) ));

singConstDer1 = (sqrt((degreeL + 1) .* degreeL));
singConstDer2 = (sqrt((degreeL + orderM) .* (degreeL - orderM + 1)));

maxDegreeL = max(degreeL);

%% memory allocation
% normalized Legendre with with singulatiry solution incorporated
normLegendreSing = nan(length(degreeL), length(cosTheta));

normLegendreSingMplus1 = normLegendreSing;
normLegendreSingMminus1 = normLegendreSing;

% derivative of normalized Legendre with singulatiry solution incorporated
normLegendreSingMminus1_D = normLegendreSing;
normLegendreSingM1 = normLegendreSing;
% normalized Legendre
normLegendre = normLegendreSing;

%% derivative of normalized Legendre
temp = legendre(1, cosTheta, 'norm');
for thisDegreeL = 1:maxDegreeL
    %% normalized Legendre
    temp1 = legendre(thisDegreeL + 1, cosTheta, 'norm');
    
    index = degreeL == thisDegreeL;
    Mplus1 = temp1(orderM(index) + 2, :);
    
    Mminus1 = zeros(size(Mplus1));
    tempIndex = orderM(index);
    tempIndex(tempIndex == 0) = [];
    Mminus1(orderM(index) ~= 0, :) = temp1(tempIndex, :);
    normLegendreSingMplus1(index, :) = Mplus1;
    normLegendreSingMminus1(index, :) = Mminus1;
    
    Mminus1 = zeros(length(orderM(index) ~= 0), length(cosTheta));
    Mminus1(orderM(index) ~= 0, :) = temp(tempIndex, :);        
    
    normLegendreSingMminus1_D(index, :) = Mminus1;
    normLegendreSingM1(orderM == 0 & degreeL == thisDegreeL, :) = ...
        repmat(temp(2, :), sum(orderM(index) == 0), 1);
    normLegendre(index, :) = temp(orderM(degreeL == thisDegreeL) + 1, :);
    temp = temp1;
end

%% recursive relation assebled from prepared values
normLegendreSing = (singConst1 .* ...
    (singConst2 .* normLegendreSingMplus1 + ...
    singConst3 .* normLegendreSingMminus1));

normLegendreSing(orderM == 0, :) = 0;

normLegendreSingDer = singConstDer2 .* normLegendreSingMminus1_D - ...
    cosTheta.' .* normLegendreSing;

normLegendreSingDer(orderM == 0, :) = ...
    - singConstDer1(orderM == 0) .* normLegendreSingM1(orderM == 0, :);
end