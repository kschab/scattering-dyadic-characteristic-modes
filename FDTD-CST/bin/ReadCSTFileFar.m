function [results,pos] = ReadCSTFileFar(fid,nop,fs)
%Nop=numberofprobes
results=zeros(nop,3);
pos=zeros(nop,3);

for m=1:nop
    line = fgetl(fid);
    line = fgetl(fid);
    line = fgetl(fid);
    data = sscanf(line, '%g');

    while data(1) < fs(end)
        line = fgetl(fid);
        data = sscanf(line, '%g');
    end
    
    %x
    line = fgetl(fid);
    line = fgetl(fid);
    [A,~,~] = sscanf(line(72:end),'%f');
    pos(m,:)=A';
    line = fgetl(fid);
    
    for n=1:length(fs)
        line = fgetl(fid);
        data = sscanf(line, '%g');
        results(m,1,n) = data(2);
    end
    
    %y
    line = fgetl(fid);
    line = fgetl(fid);
    line = fgetl(fid);
    
    for n=1:length(fs)
        line = fgetl(fid);
        data = sscanf(line, '%g');
        results(m,2,n) = data(2);
    end
     
    %z
    line = fgetl(fid);
    line = fgetl(fid);
    line = fgetl(fid);
    
    for n=1:length(fs)
        line = fgetl(fid);
        data = sscanf(line, '%g');
        results(m,3,n) = data(2);
    end
    line = fgetl(fid);
end