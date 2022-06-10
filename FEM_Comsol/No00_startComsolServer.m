% This script starts Comsol server

% this is the path to Comsol (change it accordingly)
ComsolPath = 'C:\Program Files\COMSOL\COMSOL60';

%% start Comsol server
Currentdir = pwd;
cd ([ComsolPath,'\Multiphysics\bin\win64']);
system('comsolmphserver &');
cd(Currentdir);