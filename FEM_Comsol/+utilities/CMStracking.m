function [tTracked, fTracked] = CMStracking(weigths, tCell, fCell, nModes)
%% track characteristic modes represented by far fields
% Tracking of characteristic modes based on far field correlation.
%
%  INPUTS
%   weights: Lebedev's weights, cell {nLeb x 1} x Nka
%   tCell: characteristic numbers t, sorted in descending order in
%            magnitude, cell {nCM x 1} x Nka
%   fCell: characteristic far fields, sorted as tSorted, double {nLeb x nCM} x Nka
%   nModes: % number of modes to be tracked (sorted by significance),
%   integer [1 x 1]
%
%  OUTPUTS
%   tSorted: tracked characteristic numbers t, double [nModes x Nka]
%   fSorted: tracked characteristic far fields, cell {nLeb x nCM} x Nka
%
%  SYNTAX
%   [tTracked, fTracked] = CMStracking(weigths, tCell, fCell, nModes)
%
% (c) 2022, Lukas Jelinek, CTU in Prague, lukas.jelinek@fel.cvut.cz

Nka = size(tCell,2); % number of frequencies

tTracked = nan(nModes,Nka);
fTracked = cell(1,Nka);

fLeft = fCell{1,1};
fLeft = fLeft(:,(1:nModes));

fRight = fCell{1,1};
tRight = tCell{1,1};

tTracked(:,1) = tRight((1:nModes),1);
fTracked{1,1} = fRight(:,(1:nModes));

disp('tracking')
for ika = 2:Nka
    
    fRight = fCell{1,ika};
    tRight = tCell{1,ika};
    
    tmp = fLeft'*diag([weigths{1,ika};weigths{1,ika}])*fRight;
    
    %     close all
    %     figure
    %     plot(abs(tmp(1,:)),'x')
    %     hold on
    %     plot(abs(tmp(2,:)),'o')
    
    [~,I] = max(abs(tmp).');
    
    tTracked(:,ika) = tRight(I,1);
    fTracked{1,ika} = fRight(:,I);
    
    fLeft = fRight(:,I);
    fLeft = fLeft(:,(1:nModes));
    
disp(['frequency sample ',num2str(ika)])    
end

end