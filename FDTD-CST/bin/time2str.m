function [timestr] = time2str(s)
days=floor(s/(3600*24));
s=s-days*(3600*24);
hours=floor(s/(3600));
s=s-hours*(3600);
minutes=floor(s/(60));
seconds=round(s-minutes*(60));

if seconds==60
    seconds=59;
end

ds='';
ms='';
hs='';
ss='';
if days > 0
    if days > 1
        ds=strcat(num2str(days),' days');
    else
        ds=strcat(num2str(days),' day');
    end
end

if hours > 0
    if hours > 1
        hs=strcat(num2str(hours),' hours');
    else
        hs=strcat(num2str(hours),' hour');
    end
end

if minutes > 0
    if minutes > 1
        ms=strcat(num2str(minutes),' minutes');
    else
        ms=strcat(num2str(minutes),' minute');
    end
end

if seconds > 0
    if seconds > 1
        ss=strcat(num2str(seconds),' seconds');
    else
        ss=strcat(num2str(seconds),' second');
    end
end

timestr=strcat(ds,{' '},hs,{' '},ms,{' '},ss);

end

