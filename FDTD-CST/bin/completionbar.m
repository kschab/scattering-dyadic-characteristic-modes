function [bar] = completionbar(percent)

bar='|----------------------------------------|';
ind=round(40*percent/100);
bar(2:ind-2)='*';

if percent >= 99.5
    bar(37:42)=strcat('|',num2str(round(percent)),'%|');
    
elseif percent > 98
    bar(38:42)=strcat('|',num2str(round(percent)),'%|');
    
elseif percent > 9.5
    bar(ind-1:ind+3)=strcat('|',num2str(round(percent)),'%|');
else
    if ind < 3
        bar(1:4)=strcat('|',num2str(round(percent)),'%|');
    else
        bar(ind-2:ind+1)=strcat('|',num2str(round(percent)),'%|');
    end
end




