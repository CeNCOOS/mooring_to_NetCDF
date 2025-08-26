function y=localpacifictoUTC(time) %#ok<INUSD>
%
% function to figure out if we are in PST or PDT and use appropriate
% conversion to UTC.
%
time=clock;
ms=0;
i=0;
while ms < 2
    i=i+1;
    ztime=datenum(time(1),3,i,0,0,0);
    dstr=datestr(ztime,8);
    if(strcmp(dstr,'Sun')==1)
        ms=ms+1;
        if ms==2
            daylightstart=datenum(time(1),3,i,2,0,0);
        end
    end
end
me=0;
i=0;
while me < 1
    i=i+1;
    ztime=datenum(time(1),11,i,0,0,0);
    dstr=datestr(ztime,8);
    if(strcmp(dstr,'Sun')==1)
        me=me+1;
        daylightend=datenum(time(1),11,i,2,0,0);
    end
end
mytime=datenum(time(1),time(2),time(3),time(4),time(5),time(6));
if((mytime >= daylightstart)&&(mytime <= daylightend))
    mytime=mytime+7/24;
else
    mytime=mytime+8/24;
end
y=mytime;
return;
    