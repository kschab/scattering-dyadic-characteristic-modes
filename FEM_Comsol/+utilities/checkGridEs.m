function [lebedevGrid, weigths] = checkGridEs(gridEs)
%% check the correctness of Lebedev's point grid and evaluation of weights

% radius of the measurement sphere
scattRadius = mean(sqrt(gridEs(:,1).^2 + gridEs(:,2).^2 + gridEs(:,3).^2));

% allowed degree
degree =[ 6, 14, 26, 38, 50, 74, 86, 110, 146, 170, 194, 230, 266, 302,...
350, 434, 590, 770, 974, 1202, 1454, 1730, 2030, 2354, 2702, 3074, ...
3470, 3890, 4334, 4802, 5294, 5810];

% get degree
degreeEs = intersect(size(gridEs,1), degree);

if isempty(degreeEs)
    error('invalid Lebedev grid')
else
[lebedevGrid, weigths, ~] = utilities.getLebedevSphere(degreeEs);
lebedevGrid = lebedevGrid.*scattRadius;
end

% check grids
err = 2*max(max(abs((lebedevGrid - gridEs)./(lebedevGrid + gridEs))));
check = err < 1e-6;

if check
  disp(['valid Lebedev grid, maximum error = ',num2str(err)])
else
  error('invalid Lebedev grid')  
end

% save('gridEs.txt','gridEs','-ascii','-double')
% 
% figure
% plot3(lebedevGrid(:,1), lebedevGrid(:,2), lebedevGrid(:,3),'x')
% grid on
% xlabel('x [m]')
% ylabel('y [m]')
% zlabel('z [m]')
% title('point grid for scattered field')

end