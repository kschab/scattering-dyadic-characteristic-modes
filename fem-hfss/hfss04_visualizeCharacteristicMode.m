clear
close all
clc

%{
hfss04_visualizeCharacteristicMode.m

Kurt Schab
Santa Clara University
kschab@scu.edu
2022
%}

% parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tag = 'plate-preset';
lebDegree = 14;
modedex = 10;
kadex = 5;

% internal settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('bin'))
scriptFileTemplate = [pwd,'/hfss/plateVisualizeTemplate.py'];
scriptFileActive = [pwd,'/hfss/plateVisualizeActive.py'];
datadir = [pwd,'/data/'];
datadirAlt = strrep(datadir,'\','/');

% load compiled data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(['compiled-data/',tag,'-compiled','-leb-',num2str(lebDegree),'.mat'],'SD','kalist','aobj')

% select mode, frequency, and relevant scattering dyadic data
ka = kalist(kadex);
Smat = squeeze(SD(:,:,kadex));

% determine whether a simulation needs to be rerun
rrl = strsplit(fileread([pwd,'/hfss/rerunlog.txt']),' ');
if (strcmp(num2str(lebDegree),rrl{1})) & (strcmp(num2str(ka),rrl{2}))
    rerunflag = 0;
else
    rerunflag = 1;
end
fid = fopen([pwd,'/hfss/rerunlog.txt'],'w');
fprintf(fid,[num2str(lebDegree),' ',num2str(ka)]);
fclose(fid);


% characteristic mode calculation
aobj = 83.8525e-3;
k0 = ka/aobj;
[U,L] = eig(Smat);
t = k0/(4*pi*1j)*diag(L);
s = 2*t+1;
f = U(:,modedex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write hfss visualization script

% obtain lebedev points 
leb = getLebedevSphere(lebDegree);
p = sqrt(leb.x.^2 + leb.y.^2);
theta = atan2(p,leb.z)*180/pi;
phi = atan2(leb.y,leb.x)*180/pi;
w = leb.w;

% define incident wave directions 
FGHZSTRING = sprintf('%1.4f', k0*3e8/(2*3.141592654)/1e9);
thetalistdeclare = '[';
philistdeclare = '[';
for n = 1:lebDegree
    if n>1
        thetalistdeclare = [thetalistdeclare,', ',num2str(theta(n))];
        philistdeclare = [philistdeclare,', ',num2str(phi(n))];
    else
        thetalistdeclare = [thetalistdeclare,num2str(theta(n))];
        philistdeclare = [philistdeclare,num2str(phi(n))];
    end
end
thetalistdeclare = [thetalistdeclare,']'];
philistdeclare = [philistdeclare,']'];

% define incident wave weights
f(1:lebDegree) = -f(1:lebDegree);
fabslistdeclare = '[';
fphalistdeclare = '[';
for n = 1:2*lebDegree
    if n>1
        fabslistdeclare = [fabslistdeclare,', ',num2str(abs(f(n)))];
        fphalistdeclare = [fphalistdeclare,', ',num2str(angle(f(n))*180/pi)];
    else
        fabslistdeclare = [fabslistdeclare,num2str(abs(f(n)))];
        fphalistdeclare = [fphalistdeclare,num2str(angle(f(n))*180/pi)];
    end
end
fabslistdeclare = [fabslistdeclare,']'];
fphalistdeclare = [fphalistdeclare,']'];

% send data to script, update, and save
scriptText = string(fileread(scriptFileTemplate));
scriptText = strrep(scriptText,'xxDATADIRxx',datadirAlt);
scriptText = strrep(scriptText,'xxTHETALISTDECLARExx',thetalistdeclare);
scriptText = strrep(scriptText,'xxPHILISTDECLARExx',philistdeclare);
scriptText = strrep(scriptText,'xxFGHZxx',FGHZSTRING);
scriptText = strrep(scriptText,'xxFABSxx',fabslistdeclare);
scriptText = strrep(scriptText,'xxFPHAxx',fphalistdeclare);
scriptText = strrep(scriptText,'xxRERUNFLAGxx',num2str(rerunflag));
scriptText = strrep(scriptText,'%','%%');
fid = fopen(scriptFileActive,'w');
fprintf(fid,scriptText);
fclose(fid);

% plot far-field correlation 
figure()
imagesc(log10(abs(U'*U)))
caxis([-2,0])
shading flat
axis square
colorbar
xlabel('mode index n')
ylabel('mode index m')
title('log_{10}|F_m^HF_n|')

    

