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
prefix = 'plate-auto-fine';
kalist = linspace(1,2,9);
lebDegree = 14;

% internal settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('bin'))
aedtFile = [pwd,'/hfss/plate-leb.aedt'];
scriptFileTemplate = [pwd,'/hfss/mainPlateSingleTemplate.py'];
scriptFileActive = [pwd,'/hfss/mainPlateSingleActive.py'];
command = [HFSSexe,' -features=beta -ng -runscriptandexit ',scriptFileActive,' ',aedtFile];
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
for ka = kalist(7:9)
    
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
    
    % main loop over lebedev points
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for pdex = 1:2
        for idex = 1:lebDegree
            
            % update control script
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            scriptText = string(fileread(scriptFileTemplate));
            scriptText = strrep(scriptText,'xxDATADIRxx',datadirAlt);
            scriptText = strrep(scriptText,'xxTHETALISTDECLARExx',thetalistdeclare);
            scriptText = strrep(scriptText,'xxPHILISTDECLARExx',philistdeclare);
            scriptText = strrep(scriptText,'xxFGHZxx',FGHZSTRING);
            scriptText = strrep(scriptText,'xxPDEXxx',num2str(pdex-1));
            scriptText = strrep(scriptText,'xxIDEXxx',num2str(idex-1));
            scriptText = strrep(scriptText,'%','%%');
            fid = fopen(scriptFileActive,'w');
            fprintf(fid,scriptText);
            fclose(fid);
            
            % call hfss
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp(['ka = ',num2str(ka)])
            disp(['... running incident field ', num2str((pdex-1)*lebDegree + idex),' of ',num2str(2*lebDegree)])
            tic();
            state = system(command);
            toc()
            
            % update compiled dataset
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if (pdex == 1) && (idex ==1)
                f_compiled = fopen([datadir,tag,'.csv'],'w');
            else
                f_compiled = fopen([datadir,tag,'.csv'],'a+');
            end
            data = fileread([datadir,'tmpB.csv']);
            fprintf(f_compiled,data);
            fclose(f_compiled);
            
            % pull convergence data
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            conv = string(fileread('data/latest-convergence.conv'));
            conv = strsplit(conv,'\n');
            conv = conv(18:end-2);
            error_ = [];
            ntets_ = [];
            for cdex = 1:size(conv,2)
                data = strsplit(conv(cdex),{'|',' '});
                if cdex ==1
                    error_ = [error_,NaN];
                else
                    error_ = [error_,str2num(data(4))];
                end
                ntets_ = [ntets_,str2num(data(3))];
            end
            ERROR = {ERROR{:},error_};
            NTETS = {NTETS{:},ntets_};
            
            % update progress plots
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            figure(1)
            subplot(1,3,1)
            if pdex == 1
                scatter3(leb.x(idex),leb.y(idex),leb.z(idex),'r^');
            else
                scatter3(leb.x(idex),leb.y(idex),leb.z(idex),'b*');
            end
            xlabel('x')
            xlabel('y')
            xlabel('z')
            subplot(1,3,2)
            cla()
            for i = 1:size(ERROR,2)
                semilogy(ERROR{i},'.-')
                hold on
            end
            xlabel('iteration')
            ylabel('energy error')
            subplot(1,3,3)
            cla()
            for i = 1:size(NTETS,2)
                semilogy(NTETS{i},'.-')
                hold on
            end
            xlabel('iteration')
            ylabel('# tetrahedra')
            drawnow()
        end
    end
end
