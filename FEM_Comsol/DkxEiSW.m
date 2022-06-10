function out = DkxEiSW (kx, ky, kz, k0, ka, sWind, component)
deltaK = 1e-3;

out = (EiSW (kx + deltaK, ky, kz, k0, ka, sWind, component) - ...
    EiSW (kx - deltaK, ky, kz, k0, ka, sWind, component))/(2*deltaK);

end