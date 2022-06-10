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

addpath('../shared/reference-data/')

% parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
directory = 'data/';
tag = 'plate-auto-multi-pml';
Nleb = 14;
aobj = 83.8525e-3;

% load compiled data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(['compiled-data/',tag,'-compiled.mat'],'SD','kalist','aobj')

% select 
modedex = 4;
kadex = 1;
ka = kalist(kadex);
Smat = squeeze(SD(:,:,kadex));

% characteristic mode calculation
k0 = ka/aobj;
[U,L] = eig(Smat);
t = k0/(4*pi*1j)*diag(L);
s = 2*t+1;

f = U(:,modedex);


leb = getLebedevSphere(Nleb);
p = sqrt(leb.x.^2 + leb.y.^2);
theta = atan2(p,leb.z)*180/pi;
phi = atan2(leb.y,leb.x)*180/pi;
w = leb.w;


scriptFileTemplate = [pwd,'/hfss/mainPlateVisualizeModeTemplate.py'];
scriptFileActive = [pwd,'/hfss/mainPlateVisualizeModeActive.py'];
pwPhiTemplate = string(fileread('hfss/incidentPhiWaveForm.txt'));
pwThetaTemplate = string(fileread('hfss/incidentThetaWaveForm.txt'));
intHeader = string(fileread('hfss/pwScalingHeader.txt'));
weightTemplate = string(fileread('hfss/incidentFieldWeightForm.txt'));

fid = fopen(scriptFileActive,'w');
header = string(fileread(scriptFileTemplate));

fprintf(fid,header);

% for n = 1:Nleb
% tI = num2str(theta(n));
% pI = num2str(phi(n));
% pw = strrep(pwPhiTemplate,'xxTHETAxx',tI);
% pw = strrep(pw,'xxPHIxx',pI);
% pw = strrep(pw,'xxNxx',num2str(n));
% fprintf(fid,pw);
% end
% for n = 1:Nleb
% tI = num2str(theta(n));
% pI = num2str(phi(n));
% pw = strrep(pwThetaTemplate,'xxTHETAxx',tI);
% pw = strrep(pw,'xxPHIxx',pI);
% pw = strrep(pw,'xxNxx',num2str(n+Nleb));
% fprintf(fid,pw);
% end
% 
% fprintf(fid,'oProject.Save()\n')
% fprintf(fid,'oDesign.AnalyzeAll()\n')
fprintf(fid,intHeader);

for n = 1:Nleb*2
    vabs = num2str(abs(f(n)));
    vph = num2str(180/pi*angle(f(n)));
    pw = strrep(weightTemplate,'xxNxx',num2str(n));
    pw = strrep(pw,'xxVabsxx',vabs);
    pw = strrep(pw,'xxVphxx',vph);
fprintf(fid,pw);
if n~=Nleb*2
    fprintf(fid,',\n');
else
    fprintf(fid,'\n');
end
end
fprintf(fid,'\t])')

fclose(fid)



            
    

