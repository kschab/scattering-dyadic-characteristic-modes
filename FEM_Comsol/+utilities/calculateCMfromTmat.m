function [tCell, fCell] = calculateCMfromTmat(TmatCell)
%% calculate characteristic modes at all frequency samples
%
%  INPUTS
%   TmatCell: transition matrix at all frequency samples, cell {nSW x nSW} x Nka
%   kaVec: electric size, double [1 x Nk]
%
%  OUTPUTS
%   tCell: characteristic numbers t, sorted in descending order in
%            magnitude, cell {nCM x 1} x Nka
%   fCell: characteristic spherical f-vectors, sorted as tCell, double {nnSW x nSW} x Nka
%
%  SYNTAX
%   [tCell, fCell] = calculateCMfromTmat(TmatCell)
%
% (c) 2022, Lukas Jelinek, CTU in Prague, lukas.jelinek@fel.cvut.cz

%% frequency sweep
Nka = size(TmatCell,2); % number of frequencies
fCell = cell(1,Nka); % spherical f-vectors
tCell = cell(1,Nka); % sampled t-values

disp('evaluating characteristic modes')
for ika = 1:Nka
    Tmat = TmatCell{1,ika};
    
    [QT,DT] = eig(Tmat);
    DT = diag(DT);
    [~,I] = sort(abs(DT),'descend');
    
    fCell{1,ika} = QT(:,I);
    tCell{1,ika} = DT(I,1);
    
    disp(['frequency sample ',num2str(ika)])
end