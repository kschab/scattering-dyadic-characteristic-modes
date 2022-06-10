function [Ndegree, Lmax] = minLebedevDegree(ka, c1, c2)
% MINLEBEDEVDEGREE: estimates minumum degree based on eletrical size and
% user-defined precision constants (c1, c2)
% 
% Inputs (optional):
%    c1 ~ constant used for evaluation of minimum quadrature degree.
%         default value = 2. higher value means higher quadrature, more
%         plane waves used, higher precision, but also considerably higher
%         computational time.
%    c2 ~ similarly as constant c1. default value = 3
% 
% Ouputs: 
%    Ndegree ~ recommended degree of Lebedev quadrature
%    Lmax    ~ corresponding Lmax order if spherical waves to evaluate and
%              decompose transition matrix are used instead
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

nInputs = nargin;
% Substitute default values if c1 or c2 were not set
if nInputs < 2
    c1 = 2;
end
if nInputs < 3
    c2 = 3;
end

% Use formulas from the paper (see README file) to get Lmax and Ndegree
Lmax    = ka + c1*ka.^(1/3) + c2;
Ndegree = ceil(4/3 * (Lmax + 1).^2);

end