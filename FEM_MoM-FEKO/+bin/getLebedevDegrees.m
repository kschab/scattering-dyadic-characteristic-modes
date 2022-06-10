function [degrees, order, Lmax, Npw, Nsph] = getLebedevDegrees(goal)
% GETLEBEDEVDEGREES: 
% 
% Inputs (optional):
%    goal ~ index of Lebedev quadrature degree used. if unused, all data
%           specified below are returned
% 
% Ouputs:
%    degrees ~ degree of the Lebedev quadrature
%    order   ~ order of the spherical waves integrated precisely if
%              corresponding degree is used
%    Lmax    ~ what Lmax is precisely treated
%    Npw     ~ number of plane waves needed
%    Nsph    ~ number of spherical waves needed (it they will be used
%              instead - see the paper referenced in the README for further
%              details)
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

% (Extracted from bin.getLebedevSphere.m:)
degrees = [6, 14, 26, 38, 50, 74, 86, 110, 146, 170, 194, ...
    230, 266, 302, 350, 434, 590, 770, 974, 1202, 1454, ...
    1730, 2030, 2354, 2702, 3074, 3470, 3890, 4334, 4802, 5294, 5810];

order = [3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,35,41,47,53,59,65,71,...
    77,83,89,95,101,107,113,119,125,131];

% Order of spherical waves to be treated precisely:
Lmax  = 1:length(order);
% Number of plane waves required:
Npw   = 2*degrees;
% Equivalent number of spherical waves used:
Nsph  = 2*cumsum(order);

% if "goal" is used by the user, find the closest degree to "goal"
if nargin > 0
    difference = abs(degrees - goal);
    [~, pos] = min(difference);
    degrees  = degrees(pos);
    order    = order(pos);
    Lmax     = Lmax(pos);
    Npw      = Npw(pos);
    Nsph     = Nsph(pos);
end
end

%% Check  the number of plane waves vs. number of spherical waves
% [degrees, order, Lmax, Npw, Nsph] = bin.getLebedevDegrees();
% Npw_ = 2*4/3*(Lmax + 1).^2;
% 
% figure('color', 'w');
% plot(Nsph, Npw);
% hold on;
% grid on;
% loglog(Nsph, Npw_, 'x');
% 
% legend('degree (N_{pw}) X order (L_{max}) from Lebedev table', ...
%        'N_{pw} = 2 * 4/2 * (L_{max} + 1)^2');
% 
% xlabel('N_{sph} (size of T matrix)');
% ylabel('N_{pw} (size of "equivalent" scat. matrix)');