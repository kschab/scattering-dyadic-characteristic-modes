%% get characteristic mode data

%% scattering dyadic
% uncomment to load the precalculated results
load([pwd,'\results\SdyadfullComsolCell.mat']);

% calculate characteristic modes
[tCell, fCell, weigths] = utilities.calculateCMfromScatteringDyadic(...
    SdyadfullCell, kaVec/a);

% track modes
[tTracked, fTracked] = utilities.CMStracking(weigths, tCell, fCell, 10);