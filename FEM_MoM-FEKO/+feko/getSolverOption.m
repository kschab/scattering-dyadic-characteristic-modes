function solver = getSolverOption(userSolver)
% Returns text option for the PRE FEKO file

nInputs = nargin;
if nInputs == 0
    userSolver = '';
end

switch userSolver
    case 'directSparse' % default factorization
        solver = 'CG: 21 :  : -1 :  :  :  :  :  :  :  :  : 0\n';
    case 'iterativeSettings' % iterations, stopping criterion / max residuum
        solver = 'CG: -1 : 500 : -1 :  :  : 1e-05 :  :  : 1e-05\n';
    otherwise % defauls settings (iterative Bi-CGSTAB)
        solver = 'CG: -1 :  : -1\n';
end
end