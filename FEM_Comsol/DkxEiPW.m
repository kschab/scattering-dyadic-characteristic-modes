function out = DkxEiPW (kx, ky, kz, k0, nx, ny, nz, e0x, e0y, e0z, component)

% kx,ky,kz: k0*{x,y,z} [N x 1]
% k0: wavenumber [1 x 1]
% nx,ny,nz: propagation vector (unit vector)
% e0x, e0y, e0z: electric field vector
% component: {1,2,3} selector of output cartesian vector component

k0 = k0(1,1); % Comsol make it as long as kx
nx = nx(1,1); % Comsol make it as long as kx
ny = ny(1,1); % Comsol make it as long as kx
nz = nz(1,1); % Comsol make it as long as kx
e0x = e0x(1,1); % Comsol make it as long as kx
e0y = e0y(1,1); % Comsol make it as long as kx
e0z = e0z(1,1); % Comsol make it as long as kx
component = component(1,1); % Comsol make it as long as kx

tmp = -1i*nx*exp(-1i*(nx*kx+ ny*ky + nz*kz));

% select the desired component
if component == 1 % Ex
    out = e0x*tmp;
elseif component == 2 % Ey
    out = e0y*tmp;
elseif component == 3 % Ez
    out = e0z*tmp;
else
   error('something wrong') 
end 
    
end

