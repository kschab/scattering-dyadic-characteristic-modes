close all
clear
clc

%{
hfss02_parseData.m

Kurt Schab
Santa Clara University
kschab@scu.edu
2022
%}

addpath(genpath('../shared/bin'))
addpath(genpath('bin'))

% parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
directory = 'data/';
tag = 'plate-preset';
lebDegree = 14;

% collect all possible ka datasets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kalist = [];
aobj = 83.8525e-3;
files = dir([directory,tag,'*','-',num2str(lebDegree),'*']);
for i = 1:size(files,1)
    name = files(i).name;
    name = strsplit(name,{'ka-','-leb'});
    kalist = [kalist,str2double(name{2})];
end
disp(['... querying for datasets:         ',directory,tag,'*','-',num2str(lebDegree),'*'])
disp(['... number of datasets identified: ',num2str(length(kalist))])

% initialize storage for scattering dyadic matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nka = length(kalist);
SD = zeros(lebDegree*2,lebDegree*2,Nka);

% main loop over all ka datasets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for kadex = 1:Nka
    % setup
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ka = kalist(kadex);
    fid = [directory,tag,'-ka-',sprintf('%1.3f',ka),'-leb-',num2str(lebDegree),'.csv'];
    disp(['... parsing:   ',fid])
    Spp = zeros(lebDegree);
    Spt = zeros(lebDegree);
    Stp = zeros(lebDegree);
    Stt = zeros(lebDegree);
    leb = getLebedevSphere(lebDegree);
    w = leb.w;

    % load data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    f = fopen(fid,'r');

    % phi incidence blocks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:lebDegree
        for j = 1:lebDegree
            header = strsplit(fgetl(f),{'[',']'});
            data = strsplit(fgetl(f),',');
            Spp(j,i) = -(str2double(data(6))*unitScaling(header{12})+1j*str2double(data(7))*unitScaling(header{14}))*sqrt(w(i)*w(i));
            Stp(j,i) = -(str2double(data(8))*unitScaling(header{16})+1j*str2double(data(9))*unitScaling(header{18}))*sqrt(w(i)*w(i));
        end
    end
    
    % theta incidence blocks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:lebDegree
        for j = 1:lebDegree
            header = strsplit(fgetl(f),{'[',']'});
            data = strsplit(fgetl(f),',');
            Spt(j,i) = (str2double(data(6))*unitScaling(header{12})+1j*str2double(data(7))*unitScaling(header{14}))*sqrt(w(i)*w(j));
            Stt(j,i) = (str2double(data(8))*unitScaling(header{16})+1j*str2double(data(9))*unitScaling(header{18}))*sqrt(w(i)*w(j));
        end
    end
    
    % construct and store complete scattering dyadic
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fclose(f);
    Smat = [Spp, Spt; Stp, Stt];
    SD(:,:,kadex) = Smat;
    
end

% save compiled data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['... saving compiled data: ','compiled-data/',tag,'-compiled','-leb-',num2str(lebDegree),'.mat'])
save(['compiled-data/',tag,'-compiled','-leb-',num2str(lebDegree),'.mat'],'SD','kalist','aobj')