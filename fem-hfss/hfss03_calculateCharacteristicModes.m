clear
close all
clc

%{
hfss03_calculateCharacteristicModes.m

Kurt Schab
Santa Clara University
kschab@scu.edu
2022
%}

addpath('../shared/reference-data/')

% parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tag = 'plate-preset';
lebDegree = 14;
plotDetailedView = 1;

% load compiled data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(['compiled-data/',tag,'-compiled','-leb-',num2str(lebDegree),'.mat'],'SD','kalist','aobj')

% open reference figures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
openfig('efie_plate_Abst.fig');
cols = get(gca,'colororder');
figure(10);

% main loop over all possible ka datasets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
aobj = 83.8525e-3;
A = [];
KA = [];
Tabs = [];
Nka = length(kalist);
for kadex = 1:Nka
    ka = kalist(kadex);
    Smat = squeeze(SD(:,:,kadex));
    
    % characteristic mode calculation
    k0 = ka/aobj;
    [U,S,V] = eigs(Smat,10,'lm');
    s = diag(S);
    t = k0/(4*pi*1j)*s;

    % projection onto |s| = 1 circle
    s = 2*t+1;
    phi = angle(s);
    s_ = exp(1j*phi);
    t_ = (s_-1)/2;
    
    % figures
    if plotDetailedView
        h = figure();
        set(h,'position',[110 355 1246 436]);
        subplot(1,2,1)
        pcolor(abs(Smat))
        shading flat
        axis square
        colorbar
        title({'|S|';['ka = ',num2str(ka)]})
        subplot(1,2,2)
        plot(real(t),imag(t),'ko')
        hold on
        scatter(real(t_),imag(t_),'r*')
        phi = linspace(0,2*pi,501);
        plot(0.5*cos(phi)-0.5,0.5*sin(phi),'k:')
        xlim([-1,0]*1.2)
        ylim([-0.5,0.5]*1.2)
        axis equal
        xlabel('Re t_n')
        ylabel('Im t_n')
        title({'t_n';['ka = ',num2str(ka)]})
    end
    
    figure(1)
    hold on
    plot(t*0+ka,abs(t),'ko')
    plot(t_*0+ka,abs(t_),'r*')
    xlim([0.9,2.8])
    
    figure(10)
    plot(t*0+ka,abs(s),'k^')
    hold on
    xlabel('ka')
    ylabel('|\sigma_n|')
    drawnow()
    
end



