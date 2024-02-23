function P = getPermutationMatrix(nodes, d)
%% Get permutation matrix used for iterative algoritms for substructure 
% modes, Lebedev quadrature and scattering dyadic matrix assumed to be used

if nargin == 1
    d = 1;
end

% Round coordinates to find doublets correctly
ndr = round(nodes, 10);
N   = size(nodes, 1);

% Identify doublets, i.e., points (m,n) where r_n = -r_m:
[positions, indices] = ismember(ndr, -ndr, 'rows');
orig_positions = (1:size(ndr,1)).';
pairs = [orig_positions(positions), indices(positions)];

% Expand for two polarizations (theta and phi)
pairs = unique(sort(pairs, 2), 'rows');
Pairs = [pairs; pairs + N];

% Evaluate permutation between pairs of point having inverse symmetry
P   = zeros(2*N);
for n = 1:size(Pairs, 1)
    P(Pairs(n, 1), Pairs(n, 2)) = 1;
    P(Pairs(n, 2), Pairs(n, 1)) = 1;
    P(Pairs(n, 1), Pairs(n, 2)) = 1;
    P(Pairs(n, 2), Pairs(n, 1)) = 1;    
end

% Find +/- z poles ()
zPoles = find(sum(abs(abs(ndr) - [0 0 d]), 2) == 0);

% Switch theta polarization for z-poles
P(zPoles, zPoles) = -1*P(zPoles, zPoles);
% Switch phi polarization everywhere...
P((N+1):(2*N), (N+1):(2*N)) = -1*P((N+1):(2*N), (N+1):(2*N));
% Except for z poles:
P(N+zPoles, N+zPoles) = -1*P(N+zPoles, N+zPoles);