function cleanupFEKOsolverFiles(preFEKOfileName, skipTheseFiles)
% CLEANUPFEKOSOLVERFILES: clean all temporary FEKO files used for
% generation of PRE FEKO file and its solution
% 
% Inputs:
%   preFEKOfileName ~ name of the FEKO files to be deleted
%   skipTheseFiles  ~ cell of (file) extentions to be skipped
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

nInputs = nargin;
if nInputs < 2
    skipTheseFiles = {};
end

cleanup = {'.bof', '.fek', '.out', '.str', '.pre'};
for thisFile = find(~ismember(cleanup, skipTheseFiles))
    try
        delete([preFEKOfileName cleanup{thisFile}]);
    end
end

end