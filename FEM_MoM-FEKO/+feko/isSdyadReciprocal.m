function [isReciprocal, P, Pairs] = isSdyadReciprocal(SD, lebDegree)
% ISSDYADRECIPROCAL: checks if the S-dyad "SD" is reciprocal. It is a guess
% based on 0.01 threshold between matrix difference and matrix addition of
% SD and P'*SD*P
% 
% Inputs:
%   SD        ~ scattering dyadics (matrix 2*D x 2*D, where D is lebedev
%               degree)
%   lebDegree ~ lebedev degree used to evaluate scattering dyadics
%
% Outputs:
%   isReciprocal ~ logical value (0/1) whether SD represents reciprocal
%                  system (1) or not (0)
%   P     ~ indexing matrix such that P'*SD*P should be equal to SD for
%           reciprocal systems (except of numerical errors)
%   Pairs ~ mapping pairs
% 
% Note: there are no ouputs are the results of this function is PRE FEKO
% file generated.
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

% Recover all information about the Lebedev quadrature:
leb = bin.getLebedevSphere(lebDegree);

Npw = size(leb.x, 1);
R   = [leb.x, leb.y, leb.z];

% Calculate pairs for lebedev points which have inverse symmetry:
[positions, indices] = ismember(R, -R, 'rows');
orig_positions = (1:Npw).';
pairs = [orig_positions(positions), indices(positions)];

pairs = unique(sort(pairs, 2), 'rows');
Pairs = [pairs; pairs + size(R,1)];

% Create indexing matrix rearranging scattering dyadics SD:
P = zeros(2*Npw, 2*Npw);
for n = 1:Npw
    P(Pairs(n, 1), Pairs(n, 2)) = 1;
    P(Pairs(n, 2), Pairs(n, 1)) = 1;
end

% Rearrange terms as disctated bz reciprocity:
% (SDT = SD for reciprocal devices.)
SDT = P' * SD * P;

% Decide about (non-)reciprocity, just a guess!
if (norm(SDT - SD) / norm(SD + SDT)) < 0.01
    isReciprocal = true;
else
    isReciprocal = false;
end