function out = DkzEiSW (kx, ky, kz, k0, ka, sWind, component)
deltaK = 1e-3;

out = (EiSW (kx, ky, kz + deltaK, k0, ka, sWind, component) - ...
    EiSW (kx, ky, kz - deltaK, k0, ka, sWind, component))/(2*deltaK);

end