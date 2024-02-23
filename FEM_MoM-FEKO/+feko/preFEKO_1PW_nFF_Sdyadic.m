function [] = preFEKO_1PW_nFF_Sdyadic(...
    preFEKOfileName, modelFEKOfileName, Materials, freqs, PW, FF, solver, EXTR)
% PREFEKO_1PW_NFF_SDYADIC: generates PRE FEKO file to evaluate one column
% of scattering dyadic matrix/matrices (depends on batch size)
% 
% Inputs:
%   preFEKOfileName   ~ name of the PRE FEKO file to be generated
%   modelFEKOfileName ~ name of the CFM FEKO file with the model to be used
%   Materials         ~ structure defining all the materials
%   freqs             ~ frequencies to be treated
%   PW                ~ definition of the plane wave used
%   FF                ~ far field directions and polarizations studied
%   solver            ~ EM solver to be used in FEKO
%                       (see feko.getSolverOption)
%   EXTR              ~ additional features (like infinite ground plane,
%                       etc., see examples how to use it), can be empty
% 
% Note: there are no ouputs as the result of this function is PRE FEKO
% file generated.
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

nMaterials  = size(Materials, 1);
nBatchFreqs = length(freqs);

%% Generate all PRE-feko commands
HD{1} = sprintf(...
    '** PREFEKO input file generated for scattering dyadics evaluation\n');

% Import model
MD{1} = sprintf('\n** Import mesh model\n');
MD{2} = sprintf('IN   8 1055  "models/%s.cfm"\n', modelFEKOfileName);

% End of geometry (mandatory)
EG{1} = sprintf('\n** End of geometry\n');
EG{2} = sprintf('EG: 1 : 0 : 0 :  :  : 1e-6 :  :  :  :  :  :  : 1\n');

% Dielectric object
MATER = cell(nMaterials+5, 1);
MATER{1} = sprintf('\n** Solution control\n');
MATER{2} = sprintf('PS: 0 : 0 : 3 : 1 :  : 1\n');
MATER{3} = sprintf(solver);

% % default
% MATER{3} = sprintf('CG: -1 :  : -1\n');
% % (FEM:) direct solver
% MATER{3} = sprintf('CG: 21 :  : -1 :  :  :  :  :  :  :  :  : 0\n');
% % (MoM:) iterative, residuum check
% MATER{3} = sprintf('CG: -1 : 500 : -1 :  :  : 1e-07 :  :  : 1e-07\n');

MATER{4} = sprintf(...
    '\n** Set medium properties, coatings and skin effects\n');
for iextr = 1:nMaterials
    materialSettings = length(Materials(iextr, :));
    if materialSettings == 3
        MATER{4+iextr} = sprintf(...
            'DI: %s : 0 : -1 :  :  : %1.3f :  :  :  : %1.6f : 1000\n', ...
            Materials{iextr, 1}, Materials{iextr, 2}, Materials{iextr, 3});
    elseif materialSettings == 5
        MATER{4+iextr} = sprintf(...
            'DI: %s : 0 : 0 :  :  : %1.3f : %1.3f :  : %1.6f : %1.6f : 1000\n', ...
            Materials{iextr, 1}, Materials{iextr, 2}, Materials{iextr, 4}, ...
            Materials{iextr, 5}, Materials{iextr, 3});
    elseif materialSettings == 1
        MATER{4+iextr} = sprintf('%s\n', Materials{iextr});
    else
        fprintf(2, 'Wrong material settings!\n');
    end
end
MATER{end} = sprintf('DI: 0 :  : -1 :  :  : 1 :  :  :  : 0 : 1000\n'); % always there

% Set frequencies
FR{1} = sprintf('\n** Set frequency\n');
FR{2} = sprintf('FR: %d : 3 :  :  :  : %1.0f\n', nBatchFreqs, freqs(1));
for thisFreq = 2:nBatchFreqs
    FR{1+thisFreq} = sprintf('  :  :  :  :  :  : %1.0f\n', freqs(thisFreq));
end

if isempty(EXTR)
    EXTR{1} = newline;
end

% Set sources (plane waves)
SR{1} = sprintf('\n** Sources\n');
SR{2} = sprintf(...
    'A0: 0 : 0 : 1 : 1 : 1 : 1 : 0 : %1.3f : %1.3f : %1.3f : 0 : 0\n', ...
    PW(1), PW(2), PW(3));
SR{3} = sprintf('  : 0 :  :  :  :  :  :  : 0 : 0 : 0 : 0 : 0 : 0\n');

% Set far field points
nFF = size(FF, 1);
FRF = cell(4*nFF, 1);
for n = 1:nFF
    FRF{(4*(n-1))+1} = sprintf('\n** Far fields: FarField%d\n', n);
    FRF{(4*(n-1))+2} = sprintf('DA:  :  : 1 :  : 0 :  : 0\n');
    FRF{(4*(n-1))+3} = sprintf('OF: 1 : 0 :  :  :  : 0 : 0 : 0 : 0 : 0 : 0\n');
    % Scattered field only:
    FRF{(4*(n-1))+4} = sprintf(...
        'FF: -1 : 1 : 1 : 0 : 0 : %1.3f : %1.3f : 0 : 0   ** FarField%d\n', ...
        FF(n, 1), FF(n, 2), n);
    % Total field evaluated:
%     FRF{(4*(n-1))+4} = sprintf(...
%         'FF: 1 : 1 : 1 : 0 : 0 : %1.3f : %1.3f : 0 : 0   ** FarField%d\n', ...
%         FF(n, 1), FF(n, 2), n);    
end

% End of file
EN{1} = sprintf('\n** End of file\n');
EN{2} = sprintf('EN\n');

%% Generate PRE-feko file 
fileID   = fopen([preFEKOfileName '.pre'], 'w+');
fprintf(fileID, [HD{:}]);
fprintf(fileID, [MD{:}]);
fprintf(fileID, [EXTR{:}]);
fprintf(fileID, [EG{:}]);
fprintf(fileID, [MATER{:}]);
fprintf(fileID, [FR{:}]);
fprintf(fileID, [SR{:}]);
fprintf(fileID, [FRF{:}]);
fprintf(fileID, [EN{:}]);
fclose(fileID);

end