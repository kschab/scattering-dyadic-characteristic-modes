function k0 = f0tok0(f0)
%% f0tok0: converts free space frequency to free space wavenumber
%
% (c) 2024, Miloslav Capek, CTU in Prague, miloslav.capek@antennatoolbox.com

c0 = 299792458;
k0 = 2*pi*f0/c0;