%This script loads previously generated data and computes the tn values and
%saves them for plotting using the CST_PlotData script.

clear
close all
clc

addpath(genpath('bin'))
addpath(genpath('../shared/bin'))
loadname='example';
savename=strcat(loadname,'_tn');

load(loadname) %Should include E_scat, a, d, nLebedev, fss, ka


plotmodes=2*nLebedev; %Maximal number of modes to plot, up to 2*nLebedev, if max |t_n| is less than 0.01 then it is ignored for plotting.

c=299729458;

leb = getLebedevSphere(nLebedev);%Obtain the position and the weigths of the lebedev https://www.mathworks.com/matlabcentral/fileexchange/27097-getlebedevsphere
P_xyz = [leb.x leb.y leb.z];
lq_weights = leb.w;


Probe_xyz=P_xyz*a*d*1000; %Positions for the far field probes d*a is considered far away (CST farfield carries a unit of V/m)

Pns=zeros(2*nLebedev,2*nLebedev,length(fss));
t3=zeros(2*nLebedev,length(fss));

%Converts the retrieved values to t_n
for n=1:length(fss)
    Es=squeeze(E_scat(:,:,n,:));
    Fs_pw = Es*d*a*exp(+1j*d*ka(n)); %Convert CST field data to far field.
    Fs_pw_rthph= carth2sph(Probe_xyz, Fs_pw); %Converts xyz to theta and phi far field values
    Fs_th_th = squeeze(Fs_pw_rthph(:, 2, 1:nLebedev)).';
    Fs_th_ph = squeeze(Fs_pw_rthph(:, 3, 1:nLebedev)).';
    Fs_ph_th = squeeze(Fs_pw_rthph(:, 2, (nLebedev+1):(2*nLebedev))).';
    Fs_ph_ph = squeeze(Fs_pw_rthph(:, 3, (nLebedev+1):(2*nLebedev))).';
    
    % Scattering dyadics
    S2 = [Fs_th_th, Fs_th_ph; Fs_ph_th, Fs_ph_ph]; %Assemble the scattering matrix
    S2=S2.';
    LQ   = [lq_weights; lq_weights];
    LQs  = sqrt(LQ);
    SLQ2 = LQs .* S2 .* LQs.'; %compensate using the lebedev weights
    SLQ2=-1j*2*pi*fss(n)*1e9/c/(4*pi)*SLQ2;

    [Pn, lam] = eig(SLQ2,'Vector');
    [lam, ind] = sort(lam,'descend','ComparisonMethod','abs');
    Pn = Pn(:, ind);
    
    Pns(:,:,n)=Pn;
    t3(:,n) = (lam);
end

%%
%Tracking according to the eigenvectors
Pd=Pns(:,:,1);
for n=1:length(fss)-1
    map=[];
    nn=0;
    Pu=Pns(:,:,n+1);
    [gg,ind]=max(abs(Pd'*Pu),[],2);
    while length(unique(ind)) < 2*nLebedev
        [~,ind2]=sort(gg,'descend');
        map2=zeros(1,2*nLebedev);
        for m=1:2*nLebedev
            map2(ind2(m))=ind(ind2(m));
            if length(unique(map2)) < m+1
                full= [1:1:2*nLebedev];
                sample = map2;
                idx = ismember(full, sample);
                if sum(idx)== 2*nLebedev
                else
                    Pdn=Pd(:,ind2(m));
                    A=Pdn'*Pu;
                    map2(ind2(m))=find(abs(A)==max(abs(A(full(~idx)))));
                end
            end
        end
        ind=map2;
    end
    Pd = Pu(:,ind);
    tt(:,n) = t3(ind,n+1);
end
tt=[t3(:,1) tt];

sn=2*tt+1;
ttproj=(exp(1i*angle(sn))/2-1/2); %Projects the values of t to the closest point on the circle
save(savename,"ttproj","nLebedev","tt","ka","fss") %Saves the tn and projected values for plotting purposes.