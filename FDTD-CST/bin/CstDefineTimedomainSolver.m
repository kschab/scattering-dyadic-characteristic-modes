function CstDefineTimedomainSolver(mws,SteadyStateLimit,AR,samples,pulses)
Mesh = invoke(mws,'Mesh');
invoke(Mesh,'SetCreator','High Frequency');

Solver = invoke(mws,'Solver');
invoke(Solver,'Method','Hexahedral');
invoke(Solver,'SteadyStateLimit',int2str(SteadyStateLimit));
invoke(Solver,'MeshAdaption','False'); %Turns off mesh refinement
invoke(Solver,'FrequencySamples',num2str(samples));
invoke(Solver,'HardwareAcceleration','True'); %If a GPU is availible it will be used
invoke(Solver,'NumberOfPulseWidths',num2str(pulses));
if AR
    invoke(Solver,'UseArfilter','true'); %Activates AR filter, there are additional settings to alter.
    invoke(Solver,'StartArfilter'); %Activates AR filter
end
invoke(Solver,'Start'); %initializes simulation

end



