function [Fn_, tn_] = farFieldTracking(CMA_SD)
% FARFIELDTRACKING: characteristic mode tracking based on far fields
% 
% Inputs:
%   CMA_SD ~ data structure generated by FEKO_SD.m containing all
%            informations neede (scattering dyadics, characteristic
%            vectors, characteristic numbers, etc.).
% 
% Outputs:
%    Fn_ ~ tracked characteristic vectors (far fields)
%    tn_ ~ tracked characteristic numbers
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

const = bin.constants();

Npw = size(CMA_SD.Fn_orig, 1);
Nf  = size(CMA_SD.Fn_orig, 3);

IND = nan(Npw, Nf);
IND(:, 1) = 1:Npw;
for n = 1:(Nf-1)
    % Correlation between far fields in terms of radiated power.
    % The actual frequency points are reindexed.
    T = 1/(2*const.Z0) * ...
        abs(CMA_SD.Fn_orig(:,IND(:, n),n)'*CMA_SD.W*CMA_SD.Fn_orig(:,:,n+1));
    
    % Check all rows of T and find the highest (unused) correlation.
    posPlaces = 1:Npw;
    for md = 1:Npw
        [~, pos] = max(T(md, posPlaces));    
        IND(md, n+1)   = posPlaces(pos);
        posPlaces(pos) = [];
    end
end

% Reorder data according precalculated correlation table
Fn_ = nan(size(CMA_SD.Fn_orig));
tn_ = nan(size(CMA_SD.tn_orig));
for n = 1:Nf
    Fn_(:, :, n) = CMA_SD.Fn_orig(:, IND(:, n), n);
    tn_(:, n)    = CMA_SD.tn_orig(IND(:, n), n);
end