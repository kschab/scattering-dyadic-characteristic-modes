function CstExportFarProbeTXT(mws,AR,savepath)
realsave=strcat(savepath,filesep,'real.txt');
imagsave=strcat(savepath,filesep,'imag.txt');

if AR
    ARfilter=invoke(mws,'PostProcess1D');
    invoke(ARfilter,'ApplyTo','Probes');
    invoke(ARfilter,'AddOperation','AR-filter');
    invoke(ARfilter,'Run');
    release(ARfilter)
    SelectTreeItem = invoke(mws,'SelectTreeItem','1D Results\Probes\E-Farfield (AR)\');
else
    SelectTreeItem = invoke(mws,'SelectTreeItem','1D Results\Probes\E-Farfield\');
end

Plott=invoke(mws,'Plot1D');
invoke(Plott,'SetCurveLimit','true',2000);
invoke(Plott,'plotview','real');
ASCIIExport = invoke(mws,'ASCIIExport');
invoke(ASCIIExport,'Reset');
invoke(ASCIIExport,'SetVersion','2010');
invoke(ASCIIExport,'FileName',realsave);
invoke(ASCIIExport,'Execute');

Plott=invoke(mws,'Plot1D');
invoke(Plott,'plotview','imaginary');

ASCIIExport = invoke(mws,'ASCIIExport');
invoke(ASCIIExport,'Reset');
invoke(ASCIIExport,'SetVersion','2010');
invoke(ASCIIExport,'FileName',imagsave);
invoke(ASCIIExport,'Execute');
release(Plott)
release(ASCIIExport)
end

