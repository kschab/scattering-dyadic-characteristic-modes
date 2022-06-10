function Scolumn = readFEKOfarFields(preFEKOfileName, nFarFields)
% READFEKOFARFIELDS: reads given FEKO 'ffe' file and record far field data
% 
% Inputs:
%   preFEKOfileName ~ name of the file with the currents (without suffix)
%   nFarFields      ~ how many far field directions were evaluated
%                     (corresponds to number of far field files)
% 
% Outputs:
%   Scolumn ~ once data from all far field directions are collected, they
%             create one column of scattering dyadic matrix/matrices
% 
% Note: this function can be significantly accelerated by considering:
% 1/ allocation of number of lines
% 2/ removing str2num as it is slow
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

farfieldFileNames = [preFEKOfileName '_FarField'];
data = nan(nFarFields, 9);

% There are possibly many files, one for each far field direction
for n = 1:nFarFields
    thisFileName = [farfieldFileNames num2str(n) '.ffe'];
    fileID   = fopen(thisFileName, 'rt');
    thisLine = 1;
    % Go through the file and find all relevant lines
    while ~feof(fileID)
        thisFF = str2num(fgetl(fileID));
        % When the line contains numerical data, store them
        if ~isempty(thisFF)
            data(n, :, thisLine) = thisFF;
            thisLine = 1 + thisLine;
        end
    end
    fclose(fileID);
end

% Reorder far field data
Fth = data(:, 3, :) + 1j*data(:, 4, :);
Fph = data(:, 5, :) + 1j*data(:, 6, :);

% Arrange data as single column (of scattering dyadic)
Scolumn = [Fth; Fph];