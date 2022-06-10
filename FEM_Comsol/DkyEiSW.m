function out = DkyEiSW (kx, ky, kz, k0, ka, sWind, component)
deltaK = 1e-3;

out = (EiSW (kx, ky + deltaK, kz, k0, ka, sWind, component) - ...
    EiSW (kx, ky - deltaK, kz, k0, ka, sWind, component))/(2*deltaK);

end