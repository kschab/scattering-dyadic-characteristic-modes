function f0 = k0tof0(k0)
%% k0tof0: converts free space wavenumber to free space frequency
%
% (c) 2024, Miloslav Capek, CTU in Prague, miloslav.capek@antennatoolbox.com

c0 = 299792458;
f0 = k0/(2*pi)*c0;