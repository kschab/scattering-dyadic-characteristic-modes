function indexMatrix = indexMatrix(maxDegreeL)
%% indexMatrix Calculates index matrix for S matrix computation
%
%  INPUTS
%   maxDegreeL:      maximal degree of used spherical functions,
%
%  OUTPUTS
%   indexMatrix: matrix of ordering in S matrix, double [5 x N]
%
%  SYNTAX
%
%  indexMatrix = indexMatrix(maxDegreeL)
%
% Included in AToM, info@antennatoolbox.com
% (c) 2018, Vit Losenicky, CTU in Prague, vit.losenicky@antennatoolbox.com
% mcode

%% Index matrix
% index matrix preparation
indexMatrix = NaN(5, 2*maxDegreeL*(maxDegreeL+3));

% degreeL index
temp1 = triu(ones(maxDegreeL+1,1)*(0:maxDegreeL));
indexMatrix(1, :) = kron(temp1(temp1 ~= 0), ones(4,1));

% orderM index
temp2 = (0:maxDegreeL).' * ones(1,maxDegreeL+1);
temp3 = temp2(triu(true(maxDegreeL+1)));
indexMatrix(2, :) = kron(temp3(2:end), ones(4,1));

% sigma index
indexMatrix(3, :) = repmat([1 1 2 2], 1, maxDegreeL*(maxDegreeL+3)/2);

% tau index
indexMatrix(4, :) = repmat([1 2 1 2], 1, maxDegreeL*(maxDegreeL+3)/2);

% calculation of alpha index
indexMatrix(5, :) = 2*(indexMatrix(1, :).^2+indexMatrix(1, :)-1+ ...
    ((-1).^indexMatrix(3, :)).*indexMatrix(2, :))+indexMatrix(4, :);

% applying alpha index rules - removing indexes which are overwritten
% according to alpha index
indexMatrix(:, indexMatrix(2,:) == 0 & indexMatrix(3,:) == 1) = [];
end

