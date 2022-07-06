%This script uses the ActiveX framework to control CST
%It loads an existing CST file with a geometry only, no excitation or probes.
%There are many settings to control and we demonstrate only the basics of
%the implementation to extract the modal significance and alpha values.
%It can be done in several ways and this just demonstrates one, used in
%this work.

%After this script the CST_ProcessData can be run to generate the tn
%values.

%First setup the frequency interval and number of samples in the exported

clear
close all
clc
addpath(genpath('bin'))
addpath(genpath('../shared/bin'))

%%----------------------------------
%General Setup
%
CSTfile='LayeredDielectricSphere' %CST file to open and run, geometry/design only. In the current folder.
savename='example';

a= 4.771345159236943/1000; %Largest enscribing radius of the design in meter.
d=200; %distance to the far probes in units of 'a'
nLebedev= 6; %Number of levedev points around the object. Example of accepted values are 6, 14, 26, 38, 50, 74, 86, 110, 146, 170.
plotmodes=2*nLebedev; %Maximal number of modes to plot, up to 2*nLebedev, if |t_n| at the end of the frequency interval is less than 0.01 then it is ignored for plotting.
npulses=40; % Max number of pulses in time domain, default CST is 20.

%%----------------------------------
%Frequency Settings
%-----------------------------------
funit='GHz'; %Frequency unit
ffactor=1e9; %Frequency unit
fmin=5; %minimal frequency in funit
fmax=40; %maximal frequency in funit
fs=2001; %frequency samples
fcenter=10; %center frequency in funit, frequency corresponding to ka=1 for the examples included

AR=0; %AR filter on the signals (default setting is off (0))
%%----------------------------------
%BasicMesh Settings
%-----------------------------------
CellsPerWavelenth=30;
NearCellsPerWavelenth=30;
FarCellsPerWavelenth=1;
MinimumCell=1;



%%----------------------------------
%Nothing below this points need user input
%-----------------------------------

c=299729458;
fss=linspace(fmin,fmax,fs);
ka=2*pi*fss/c*a*ffactor;


%%Start CST
cst = actxserver('CSTStudio.application'); %Establish connection to CST
mws = cst.invoke('NewMWS'); %Start a new instance of microwave studio
mws.invoke('OpenFile',strcat(pwd,filesep,CSTfile,'.cst'));


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
    pause(0.1)
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
    pause(0.1)
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

save(savename, "E_scat","a","d","ka","fss","nLebedev") %Saves the data for further usage. Should include E_scat, a, d, nLebedev, fss, ka



