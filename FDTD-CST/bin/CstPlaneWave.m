function CstPlaneWave(mws,Normal,EVector,ReferenceFrequency)
PlaneWave = invoke(mws,'PlaneWave');
invoke(PlaneWave,'Reset');
invoke(PlaneWave,'Normal',num2str(Normal(1)),num2str(Normal(2)),num2str(Normal(3)));
invoke(PlaneWave,'EVector',num2str(EVector(1)),num2str(EVector(2)),num2str(EVector(3)));
invoke(PlaneWave,'ReferenceFrequency',num2str(ReferenceFrequency));
invoke(PlaneWave,'SetUserDecouplingPlane','False');
invoke(PlaneWave,'Store');
end