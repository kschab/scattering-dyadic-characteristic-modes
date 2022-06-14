%% plot tracked CM results
Nka = size(tTracked,2); % number of frequencies
nModes = size(tTracked,1); % number of tracked modes

lambdaTracked = 1i*(1 + 1./tTracked);
sTracked = 1 + 2*tTracked;
phiTracked = angle(sTracked);
phiTracked = phiTracked + ((1 - sign(phiTracked))/2)*2*pi; % interval (0,2*pi)

% phase unwrapping
% for ika = 2:Nka
%     shift = round((phiTracked(:,ika) - phiTracked(:,ika - 1))/pi);
%     phiTracked(:,(ika:Nka)) = phiTracked(:,(ika:Nka)) - pi*repmat(shift,[1,Nka-ika+1]);
% end 

figure
for iMode = 1:nModes
plot(kaVec(1,:),(abs(tTracked(iMode,:))),'-x')
hold on
end
grid on
xlabel('$ka  \left[ - \right]$','Interpreter','latex','FontSize', 16)
ylabel('$|t_n| = |1 + \mathrm{j} \lambda_n|^{-1}  \left[ - \right]$','Interpreter','latex','FontSize', 16)

figure
for iMode = 1:nModes
plot(kaVec(1,:),(abs(sTracked(iMode,:))),'-x')
hold on
end
grid on
xlabel('$ka  \left[ - \right]$','Interpreter','latex','FontSize', 16)
ylabel('$|s_n|  \left[ - \right]$','Interpreter','latex','FontSize', 16)

figure
for iMode = 1:nModes
plot3(real(sTracked(iMode,:)),imag(sTracked(iMode,:)),kaVec(1,:),'-x','LineWidth',2)
hold on
end
grid on
xlim([-1,1])
ylim([-1,1])
xlabel('$\mathrm{Re} \left\{ s_n \right\}  \left[ - \right]$','Interpreter','latex','FontSize', 16)
ylabel('$\mathrm{Im} \left\{ s_n \right\}  \left[ - \right]$','Interpreter','latex','FontSize', 16)
zlabel('$ka  \left[ - \right]$','Interpreter','latex','FontSize', 16)
view(-63,20)


figure
for iMode = 1:nModes
plot(kaVec(1,:),phiTracked(iMode,:)/pi,'-x')
hold on
end
grid on
xlabel('$ka  \left[ - \right]$','Interpreter','latex','FontSize', 16)
ylabel('$\phi_n / \pi  \left[ - \right]$','Interpreter','latex','FontSize', 16)

figure
for iMode = 1:nModes
plot(kaVec(1,:),(phiTracked(iMode,:) + pi)/2/pi,'-x')
hold on
end
grid on
xlabel('$ka  \left[ - \right]$','Interpreter','latex','FontSize', 16)
ylabel('$\alpha_n / \pi  \left[ - \right]$','Interpreter','latex','FontSize', 16)

figure
for iMode = 1:nModes
plot(kaVec(1,:),real(lambdaTracked(iMode,:)))
hold on
end
grid on
xlabel('$ka  \left[ - \right]$','Interpreter','latex','FontSize', 16)
ylabel('$\lambda_n  \left[ - \right]$','Interpreter','latex','FontSize', 16)
ylim([-1000 1000])