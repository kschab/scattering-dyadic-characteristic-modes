%%
A(abs(Tabs)<0.05) = 0;
A(A<0) = A(A<0)+2*pi;
figure()
plot(KA,A,'k*')
ylim([pi/2,3*pi/2])

%%
fid = ['compiled-data/',tag,'-compiled-tabs.tsv'];
f = fopen(fid,'w');
for n = 1:length(Tabs)
    fprintf(f,'%1.3f\t%1.3f\n',KA(n),Tabs(n));
end
fclose(f);

fid = ['compiled-data/',tag,'-compiled-alpha.tsv'];
f = fopen(fid,'w');
for n = 1:length(Tabs)
    fprintf(f,'%1.3f\t%1.3f\n',KA(n),A(n));
end
fclose(f);

    Tabs = [Tabs;abs(t)];
    A = [A,angle(t)];
    KA = [KA,t*0+ka];