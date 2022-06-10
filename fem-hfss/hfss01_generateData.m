close all
clear
clc

%{
hfss01_generateData.m

Kurt Schab
Santa Clara University
kschab@scu.edu
2022
%}

% notes --
%* must enable beta option of non graphical execution in HFSS.  Tools /
%options / general options / beta ...

% user settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HFSSexe = '"C:\Program Files\AnsysEM\AnsysEM21.1\Win64\ansysedt.exe"';
prefix = 'plate-preset';
kalist = linspace(1,3,17);
lebDegree = 14;
guiEnable = 1;

% internal settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('bin'))
addpath(genpath('../shared/bin'))
if guiEnable
    ngflag = '';
else
    ngflag = '-ng';
end
aedtFile = [pwd,'/hfss/plate-compute.aedt'];
scriptFileTemplate = [pwd,'/hfss/plateComputeTemplate.py'];
scriptFileActive = [pwd,'/hfss/plateComputeActive.py'];
command = [HFSSexe,' -features=beta ',ngflag,' -runscriptandexit ',scriptFileActive,' ',aedtFile];
datadir = [pwd,'/data/'];
datadirAlt = strrep(datadir,'\','/');

% set up lebedev quadrature point
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
leb = getLebedevSphere(lebDegree);
p = sqrt(leb.x.^2 + leb.y.^2);
theta = atan2(p,leb.z)*180/pi;
phi = atan2(leb.y,leb.x)*180/pi;
w = leb.w;

% loop over frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ka = kalist
    
    % parse constants and prepare filename
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    aobj = 83.8525e-3;
    tag = [prefix,sprintf('-ka-%2.3f-leb-%d',ka, lebDegree)];
    FGHZSTRING = sprintf('%1.4f', ka*3e8/(2*3.141592654*aobj)/1e9);
    
    % construct list of angles for HFSS control script
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    
    % initialize convergence storage
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NTETS = {};
    ERROR = {};
    
    % initialize progress plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(1)
    subplot(1,3,1)
    cla()
    scatter3(leb.x,leb.y,leb.z,'k');
    axis square
    hold on
    
    % update control script
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scriptText = string(fileread(scriptFileTemplate));
    scriptText = strrep(scriptText,'xxDATADIRxx',datadirAlt);
    scriptText = strrep(scriptText,'xxTHETALISTDECLARExx',thetalistdeclare);
    scriptText = strrep(scriptText,'xxPHILISTDECLARExx',philistdeclare);
    scriptText = strrep(scriptText,'xxFGHZxx',FGHZSTRING);
    scriptText = strrep(scriptText,'%','%%');
    fid = fopen(scriptFileActive,'w');
    fprintf(fid,scriptText);
    fclose(fid);

    % call hfss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['ka = ',num2str(ka)])
    disp('... running hfss')
    tic();
    state = system(command);
    toc()

    % update compiled dataset
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    f_compiled = fopen([datadir,tag,'.csv'],'w');
    data = fileread([datadir,'tmpB.csv']);
    fprintf(f_compiled,data);
    fclose(f_compiled);
end
