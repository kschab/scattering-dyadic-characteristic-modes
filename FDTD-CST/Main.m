%Standalone all in one script for running CST with matlab
%This script uses the ActiveX framework to control CST
%The Geometry can be built in this environment but in this example we
%assume an existing CST file with a geometry only, no excitation or probes.
%There are many settings to control and we demonstrate only the basics of
%the implementation to extract the modal significance and alpha values.
%It can be done in several ways and this just demonstrates one, used in
%this work.

%First setup the frequency interval and number of samples in the exported
%data
addpath(genpath('bin'))
addpath(genpath('../shared/bin'))


clear
close all
clc

%%----------------------------------
%General Setup
%-----------------------------------

exampletype='plate'

%If the value is set to 'plate' a rectangular plate is generated.
%If the value is set to 'sphere' the dielectric layered sphere in
%the paper is loaded.

d=200; %distance to the far probes in units of 'a' (Does not need alterations)
a=0.2; %radius in m of the smallest circumscribing sphere around the object of interest. Overwrittin in exampletype plate and sphere.
nLebedev= 14; %Number of levedev points around the object. Example of accepted values are 6, 14, 26, 38, 50, 74, 86, 110, 146, 170.
plotmodes=2*nLebedev; %Maximal number of modes to plot, up to 2*nLebedev, if |t_n| at the end of the frequency interval is less than 0.01 then it is ignored for plotting.
npulses=40; % Max number of pulses in time domain, default CST is 20.

%%----------------------------------
%Frequency Settings
%-----------------------------------

funit='GHz'; %Frequency unit
ffactor=1e9; %Frequency unit
fmin=0.5; %minimal frequency in funit
fmax=1.7; %maximal frequency in funit
fs=101; %frequency samples
fcenter=0.571; %center frequency in funit, frequency corresponding to ka=1 for the examples included

AR=0; %AR filter on the signals (default setting is off (0))

%%----------------------------------
%BasicMesh Settings
%-----------------------------------
CellsPerWavelenth=50;
NearCellsPerWavelenth=50;
FarCellsPerWavelenth=1;
MinimumCell=1;
%%
%Nothing below this points need user input
%

c=299729458;
fss=linspace(fmin,fmax,fs);

%%Start CST
cst = actxserver('CSTStudio.application'); %Establish connection to CST
mws = cst.invoke('NewMWS'); %Start a new instance of microwave studio

%If statement as switch between examples
if strcmp(exampletype,'plate')
    k0=2*pi*fcenter/c*ffactor;
    a=1/k0;
  
else strcmp(exampletype,'sphere')
    mws.invoke('OpenFile',strcat(pwd,filesep,'LayeredDielectricSphere.cst'));
    a=4.771345159236943*1e-3;
    k0=1/a;
   
end

ka=2*pi*fss/c*a*ffactor;
%Setting frequency unit
Units = invoke(mws,'Units');
invoke(Units,'Frequency',funit);

%Estimation of Lebedev degree
EstimatedLebedev=4/3*(ka(end)+2*ka(end)^(1/3)+1)^2;

%If statement contains a check and question to user to update the number of
%Lebedev points based on the frequency interval specified.
if EstimatedLebedev > nLebedev
    allowed= [6, 14, 26, 38, 50, 74, 86, 110, 146, 170, 194, 230, 266, 302, 350, 434, 590, 770, 974, 1202, 1454, 1730, 2030, 2354, 2702, 3074, 3470, 3890, 4334, 4802, 5294, 5810];
    disp(strcat('Estimated number of Lebedevpoints are: ', num2str(ceil(EstimatedLebedev))))
    disp(strcat('You have selected: ', num2str((nLebedev))))
    disp(strcat('Do you want to change to:', num2str(allowed(find(EstimatedLebedev<allowed,1)))));
    txt = input('Input [Y]/[N]:',"s");
    
    if strcmp(txt,'Y')
        nLebedev=allowed(find(EstimatedLebedev<allowed,1));
        disp('The number of Lebedev points have been changed.')
    elseif strcmp(txt,'y')
        nLebedev=allowed(find(EstimatedLebedev<allowed,1));
        disp('The number of Lebedev points have been changed.')
    elseif strcmp(txt,'N')
        disp('Lebedev points unchanged.')
    elseif strcmp(txt,'n')
        disp('Lebedev points unchanged.')
    else
        disp('Could not interpret input, Lebedev points unchanged.')
    end
end


leb = getLebedevSphere(nLebedev);%Obtain the position and the weigths of the lebedev https://www.mathworks.com/matlabcentral/fileexchange/27097-getlebedevsphere
P_xyz = [leb.x leb.y leb.z];
lq_weights = leb.w;

K0vec_xyz=[P_xyz; P_xyz]; %Excitation directions of the plane waves
E0_xyz=PointstoE(P_xyz); %Electric field for the excitations (Phi and Theta)
Probe_xyz=P_xyz*a*d*1000; %Positions for the far field probes d*a is considered far away (CST farfield carries a unit of V/m)

Solver = invoke(mws,'Solver'); %Calls the CST solver
invoke(Solver,'FrequencyRange',num2str(fmin),num2str(fmax)); %Pushes the frequency interval to CST

for n=1:nLebedev
    CstFarProbe(mws,Probe_xyz(n,:),strcat('probe',num2str(n))); %Creates efarfield monitors at the predefined positions
end

%Setting for boundary
Boundary = invoke(mws,'Boundary');
invoke(Boundary,'ReflectionLevel','0.0000000001');  %PML Layer reflection level
invoke(Boundary,'MinimumDistanceType','Fraction');
invoke(Boundary,'MinimumDistancePerWavelengthNewMeshEngine','20'); %Distance to bounding box as 1/argument in wavelength, closest position is 20. Could set it to an absolute distance

%% Creates a sample 2:1 aspect ratio PEC plate if 'example' is selected
if strcmp(exampletype,'plate')
    invoke(Units,'Geometry','mm'); %Tells CST the length unit
    geomfac=sqrt(1+0.5*0.5); %Diagonal length of a 2:1 plate
    brick = invoke(mws,'Brick'); %Prepare CST to create a brick
    invoke(brick,'Reset');
    invoke(brick,'Name','Plate'); %Set the name
    invoke(brick,'component','component1'); %Set the component folder
    invoke(brick,'Material','PEC'); %Set the material
    invoke(brick,'Xrange',num2str(-1000*a/geomfac),num2str(1000*a/geomfac)); %Define the X range of the plate
    invoke(brick,'Yrange',num2str(-500*a/geomfac),num2str(500*a/geomfac));%Define the Y range of the plate
    invoke(brick,'Zrange',num2str(0),num2str(0)); %Define the Z range of the plate, 0 to 0 gives a 2D structure
    invoke(brick,'Create'); %Creates the plate
    release(brick);
end
%% Mesh settings
MeshSettings = invoke(mws,'MeshSettings');
invoke(MeshSettings,'SetMeshType','Hex');

invoke(MeshSettings,'Set','StepsPerWaveNear',num2str(CellsPerWavelenth));
invoke(MeshSettings,'Set','StepsPerWaveFar',num2str(CellsPerWavelenth));
invoke(MeshSettings,'Set','StepsPerBoxNear',num2str(NearCellsPerWavelenth));
invoke(MeshSettings,'Set','StepsPerBoxFar',num2str(FarCellsPerWavelenth));
invoke(MeshSettings,'Set','MaxStepNear',num2str(NearCellsPerWavelenth));
invoke(MeshSettings,'Set','MaxStepFar',num2str(FarCellsPerWavelenth));
invoke(MeshSettings,'Set','RatioLimitGeometry',num2str(MinimumCell));
invoke(MeshSettings,'Set','UseDielectrics','0'); %Turns materialmesh considerations on off
invoke(MeshSettings,'Set','EquilibrateOn','1'); %Turns smooth mesh with equilibrate ratio on off
%%

%Preallocation
map=zeros(1,nLebedev);
E_scat=zeros(nLebedev,3,fs);

tic %Starts timer for completion estimates
%% The main loop over all excitations - Defines plane wave incidence, extracts and saves the far field values at the lebedev points.
for pn=1:2*nLebedev
    CstPlaneWave(mws,K0vec_xyz(pn,:),E0_xyz(pn,:),fcenter) %Defines the source excitation
    CstDefineTimedomainSolver(mws,-40,AR,fs,npulses)  %Starts the time-domain solver
    
    savepath=pwd; %location where the intermediate results will be saved
    
    CstExportFarProbeTXT(mws,AR,savepath); %Locates the results and saves all probe data, real and imaginary for all frequencies.
    
    fileID = fopen('real.txt'); %Opens the file containing the real values
    [real1,~]=ReadCSTFileFar(fileID, length(P_xyz),fss); %parsing the txt-file, returns a vector of the real values
    fclose(fileID); %close the txt file
    
    fileID = fopen('imag.txt'); %Opens the file containing the imaginary values
    [imag1,pos]=ReadCSTFileFar(fileID, length(P_xyz),fss); %parsing the txt-file, returns a vector of the imaginary values
    fclose(fileID); %close the txt file
    
    for n=1:length(P_xyz)
        map(n)=find(sum(abs(P_xyz(n,:)-pos./max(pos(:,1))),2) < 0.0001); %The order of creating probes and extracting data is not alwas the same. This loop sorts the data order.
    end
    
    E_scat(:,:,:,pn)=real1([map],:,:)+1j*imag1([map],:,:);
    
    invoke(mws,'DeleteResults') %Deletes the data in CST
    %Estimate remaining simulation time
    timer=toc;
    clc
    disp(completionbar(pn/length(E0_xyz)*100))
    
    ts=time2str(timer);
    disp(strcat('Elapsed time: ',ts{1}))
    ts=time2str(timer/(pn/length(E0_xyz))-timer);
    disp(strcat('Estimated time remaining: ',ts{1}))
end

invoke(mws,'Quit'); %Closes the file in CST
delete(mws) %deletes the connection to matlab
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
    t3(:,n) = lam;
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
newtt=(exp(1i*angle(sn))/2-1/2); %Projects the values of t to the closes point on the circle

%Plotting the modal significance and alpha angle

figure(2)
clf
ax2 = gca;
hold on
grid on
xlabel('ka')
ylabel('|t_n|')

figure(3)
clf
hold on
ax3 = gca;
grid on
tt2=tt;
newtt2=newtt;
m=1;
plotmodesog=plotmodes;
while m <= plotmodes
    if m> 2*nLebedev      
        disp('No more data')
        disp(strcat('Modes Plotted:',num2str(-1+plotmodesog-(plotmodes-m))))        
        plotmodes=1;
    else
        if max(abs(tt(m,:)))>0.05
            figure(2)
            ax2.ColorOrderIndex = m;
            plot(ka,abs(tt(m,:)))
            
            figure(3)
            ax3.ColorOrderIndex = m;
            newtt2(m,abs(newtt2(m,:))<0.0005)=nan;
            plot(ka,wrapTo2Pi(angle(newtt2(m,1:end))))
        else
            plotmodes=plotmodes+1;
        end
    end
    m=m+1;
end
set(ax3,'YTick',0:pi/2:2*pi)
set(ax3,'YTickLabel',{'0','\pi/2','\pi','3\pi/2','2\pi'})
xlabel('ka')
ylabel('\alpha_n')

