function [Ev] = PointstoE(pos)
[az,el,~]=cart2sph(pos(:,1),pos(:,2),pos(:,3));
el=-el+pi/2;
az(az<0)=2*pi+az(az<0);

thetahat=[cos(el).*cos(az), cos(el).*sin(az), -sin(el)];
phihat=[-sin(az), cos(az),0.*az];
Ev=[thetahat;phihat];
end

