function [tCell, fCell, weigths] = calculateCMfromScatteringDyadic(...
    SdyadfullCell, k0Vec)
%% calculate characteristic modes at all frequency samples
% Lebedev's sampling is assumed
%
%  INPUTS
%   SdyadfullCell: scattering dyadic at all frequency samples, cell {nLeb x nLeb} x Nka
%   k0Vec: wavenumber, double [1 x Nk]
%
%  OUTPUTS
%   tCell: characteristic numbers t, sorted in descending order in
%            magnitude, cell {nCM x 1} x Nka
%   fCell: characteristic far fields, sorted as tCell, double {nLeb x nLeb} x Nka
%   weights: Lebedev's weights, cell {nLeb x 1} x Nka
%
%  SYNTAX
%   [tCell, fCell, weigths] = calculateCMfromScatteringDyadic(...
%     SdyadfullCell, k0Vec)
%
% (c) 2022, Lukas Jelinek, CTU in Prague, lukas.jelinek@fel.cvut.cz

%% frequency sweep
Nk = size(k0Vec,2); % number of frequencies
fCell = cell(1,Nk); % sampled far-fields
tCell = cell(1,Nk); % sampled t-values
weigths = cell(1,Nk); % Lebedev's weights

disp('evaluating characteristic modes')
for ik = 1:Nk
    Sfull = SdyadfullCell{1,ik};
    
    % get Lebedev's weights
    [~, weigths{1,ik}, ~] = utilities.getLebedevSphere(size(Sfull,1)/2);
    
    [QS,DS] = eig(Sfull*diag([weigths{1,ik};weigths{1,ik}]));
    tSval = diag(DS)*k0Vec(1,ik)/(4*pi*1i);
    [~,I] = sort(abs(tSval),'descend');
    
    fCell{1,ik} = QS(:,I);
    tCell{1,ik} = tSval(I,1);
    
    disp(['frequency sample ',num2str(ik)])
end