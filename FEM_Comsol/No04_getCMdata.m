%% get characteristic mode data

%% scattering dyadic
% uncomment to load the precalculated results
load([pwd,'\results\SdyadfullComsolCell.mat']);

% calculate characteristic modes
[tCell, fCell, weigths] = utilities.calculateCMfromScatteringDyadic(...
    SdyadfullCell, kaVec/a);

% track modes
[tTracked, fTracked] = utilities.CMStracking(weigths, tCell, fCell, 10);

%% transition matrix
% % uncomment to load the precalculated results
% load([pwd,'\results\TmatAToMCell.mat']);
% 
% % calculate characteristic modes
% [tCell, fCell] = utilities.calculateCMfromTmat(TmatCell);
% 
% % track modes
% [tTracked, fTracked] = utilities.CMTtracking(tCell, fCell, 10);