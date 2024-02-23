function cleanupFEKOcurrents(preFEKOfileName)
% CLEANUPFEKOCURRENTS: clean all temporary FEKO files related to currents
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

try
    delete([preFEKOfileName '_Currents*.*']);
end