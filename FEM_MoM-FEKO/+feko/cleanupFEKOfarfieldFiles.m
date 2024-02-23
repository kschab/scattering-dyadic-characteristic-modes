function cleanupFEKOfarfieldFiles(preFEKOfileName)
% CLEANUPFEKOFARFIELDFILES: clean all temporary FEKO files related to far
% fields
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

try
    delete([preFEKOfileName '_FarField*.ffe']);
end