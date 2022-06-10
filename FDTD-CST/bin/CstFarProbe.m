function CstFarProbe(mws,pos,name)
Monitor = invoke(mws,'Probe');
invoke(Monitor,'Reset');
invoke(Monitor,'Name','work');

invoke(Monitor,'Field','efarfield');
invoke(Monitor,'Xpos',pos(1));
invoke(Monitor,'Ypos',pos(2));
invoke(Monitor,'Zpos',pos(3));
invoke(Monitor,'Name','probe');

invoke(Monitor,'Orientation','all');
invoke(Monitor,'Create');
invoke(Monitor,'Name',name);
end

