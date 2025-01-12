function Fn = calculateCharacteristicFarField(CMA, solver, EXTR, model, An, k0)
% 
% 
% 
% (c) 2025, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

r2d     = @(x) 180*x/pi; % radians to degre
nDegree = size(CMA.P, 1);
const   = bin.constants;

preFEKOfileName = 'characteristicFarField';

% Provide excitation with Lebedev weights to give the problem
% physical scaling (equivalent to sqrt(W).' * S * sqrt(W))

En0 = CMA.W * An;
f0  = const.c0 * k0 / (2*pi);

amp   = abs(En0);
phase = r2d(angle(En0));
PW0   = [amp, phase, CMA.PW];

feko.preFEKO_nPW_nFF_charMode(preFEKOfileName, ...
    CMA.model{model}, CMA.materials, f0, PW0, CMA.FF, solver, EXTR);

%% Run PRE-feko file
dos(['runfeko ' preFEKOfileName '.pre --execute-prefeko -np all']);

%% Process far fields (for all frequencies in the batch)
Fn1 = feko.readFEKOfarFields(preFEKOfileName, nDegree); % K *

% Rescale the far-field so that eig(Fn*An') gives directly tn,
% i.e., T-matrix-type structure is directly constructed
K  = -1j * k0 / (4*pi);
Fn = K * Fn1;

%% Clean up unnecessary files
fclose('all');
feko.cleanupFEKOsolverFiles(preFEKOfileName);
feko.cleanupFEKOfarfieldFiles(preFEKOfileName);