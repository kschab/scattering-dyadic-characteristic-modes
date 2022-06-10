% This script starts the Matlab LiveLink

% this is the path to Comsol (change it accordingly)
ComsolPath = 'C:\Program Files\COMSOL\COMSOL60';

%% start Matlab LiveLInk
Currentdir = pwd;
cd([ComsolPath,'\Multiphysics\mli']);
portNumber = 2036; % port number for communication
mphstart(portNumber);
cd(Currentdir);

import com.comsol.model.*;
import com.comsol.model.util.*