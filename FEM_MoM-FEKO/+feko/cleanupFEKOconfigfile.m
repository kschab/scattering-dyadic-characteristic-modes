function cleanupFEKOconfigfile()
% CLEANUPFEKOCONFIGFILE: clean all runtime config file temporary FEKO files
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

try
    delete('runfeko_tmp_configfile*.*');
end