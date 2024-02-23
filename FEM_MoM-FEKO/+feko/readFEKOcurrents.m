function [C, I] = readFEKOcurrents(preFEKOfileName)
% READFEKOCURRENTS: reads given FEKO 'os' file and record data to recover
% current densities
% 
% Inputs:
%   preFEKOfileName ~ name of the file with the currents (without suffix)
% 
% Outputs:
%   C ~ positions where are the current densities defined (vectors)
%   I ~ current densities at positions C (complex vectors)
% 
% Note: this function can be significantly accelerated by considering:
% 1/ allocation of number of lines
% 2/ removing str2num as it is slow
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

n = 1; % There might be more files than one (not using this package).
thisFileName = [preFEKOfileName '_Currents' num2str(n) '.os'];

% Open the file
fileID   = fopen(thisFileName, 'rt');
thisLine = 1;
C = nan(0, 3);
I = nan(0, 3);
% Go through the file and find all relevant lines
while ~feof(fileID)
    thisData = str2num(fgetl(fileID));
    % When the line contains numerical data, store them
    if ~isempty(thisData)
        C(thisLine, :) = thisData(2:4);
        I(thisLine, :) = [thisData(:, 5) + 1j*thisData(:,6), ...
                          thisData(:, 7) + 1j*thisData(:,8), ...
                          thisData(:, 9) + 1j*thisData(:,10)];
        thisLine = 1 + thisLine;
    end
end
fclose(fileID);