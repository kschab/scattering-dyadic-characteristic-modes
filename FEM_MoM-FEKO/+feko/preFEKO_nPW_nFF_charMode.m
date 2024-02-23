function [] = preFEKO_nPW_nFF_charMode(...
    preFEKOfileName, modelFEKOfileName, Materials, freq, PW, FF, solver, EXTR)
% PREFEKO_NPW_NFF_CHARMODE: generates PRE FEKO file to XXXXXXXXXX
% 
% Inputs:
%   preFEKOfileName   ~ name of the PRE FEKO file to be generated
%   modelFEKOfileName ~ name of the CFM FEKO file with the model to be used
%   Materials         ~ structure defining all the materials
%   freqs             ~ frequencies to be treated
%   PW0               ~ definition of the plane wave used (incl. amp+phase)
%   FF                ~ far field directions and polarizations studied
%   EXTR              ~ additional features (like infinite ground plane,
%                       etc., see examples how to use it), can be empty
% 
% Note: there are no ouputs are the results of this function is PRE FEKO
% file generated.
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

nMaterials  = size(Materials, 1);

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
    if length(Materials(iextr, :)) < 4 || isempty(Materials{iextr, 4})
        MATER{4+iextr} = sprintf(...
            'DI: %s : 0 : -1 :  :  : %1.3f :  :  :  : %1.6f : 1000\n', ...
            Materials{iextr, 1}, Materials{iextr, 2}, Materials{iextr, 3});
    else
        MATER{4+iextr} = sprintf(...
            'DI: %s : 0 : 0 :  :  : %1.3f : %1.3f :  : %1.6f : %1.6f : 1000\n', ...
            Materials{iextr, 1}, Materials{iextr, 2}, Materials{iextr, 4}, ...
            Materials{iextr, 5}, Materials{iextr, 3});
    end
end
MATER{end} = sprintf('DI: 0 :  : -1 :  :  : 1 :  :  :  : 0 : 1000\n'); % always there

% Set frequencies
FR{1} = sprintf('\n** Set frequency\n');
FR{2} = sprintf('FR: %d : 3 :  :  :  : %1.0f\n', 1, freq);

if isempty(EXTR)
    EXTR{1} = newline;
end

% Set sources (plane waves)
nPW = size(PW, 1);
SR  = cell(2*nPW+1, 1);
SR{1} = sprintf('\n** Sources\n');
SR{2} = sprintf(...
    'A0: 0 : : 1 : 1 : 1 : %1.5f : %1.5f : %1.3f : %1.3f : %1.3f : 0 : 0 : 0\n', ...
    PW(1, 1), PW(1, 2), PW(1, 3), PW(1, 4), PW(1, 5));
SR{3} = sprintf('  : 0 :  :  :  :  :  :  : 0 : 0 : 0 : 0 : 0 : 0\n');
for n = 2:nPW
    SR{2*(n-1)+2} = sprintf(...
        'A0: 1 : : 1 : 1 : 1 : %1.5f : %1.5f : %1.3f : %1.3f : %1.3f : 0 : 0 : 0\n', ...
        PW(n, 1), PW(n, 2), PW(n, 3), PW(n, 4), PW(n, 5));
    SR{2*(n-1)+3} = sprintf('  : 0 :  :  :  :  :  :  : 0 : 0 : 0 : 0 : 0 : 0\n');
end

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