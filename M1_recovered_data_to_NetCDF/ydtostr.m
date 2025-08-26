function y=ydtostr(year,yd)
% This function changes decmial year days to 
% the matlab datestring for plotting of data on
% a time axis.  Inputs are year of positive year days
% and the decimal year days.  Output is the string.
% negative year days correspond to the previous year.

if(rem(year,4)==0)
	ileap=1; %#ok<NASGU>
	maxd=367; %#ok<NASGU>
else
	ileap=0; %#ok<NASGU>
	maxd=366; %#ok<NASGU>
end
% see if any of the yeardays belong to the previous year
ind=find(yd <= 0);
if isempty(ind)==0
	yearo=year-1;
	if(rem(yearo,4)==0)
		maxd=367;
    else
		maxd=366;
	end
	otemp=yd(ind);
	otemp=otemp+maxd;
	[by, bm, bd, bh, bn, bs]=yd2cal(yearo,otemp);
else
	by=[];
	bm=[];
	bd=[];
	bh=[];
	bs=[];
end
idd=yd > 0;
	ptemp=yd(idd);
[cy, cm, cd, ch, cn, cs]=yd2cal(year,ptemp);
if isempty(ind)==0
d=[by(:), bm(:), bd(:), bh(:), bn(:), bs(:)
   cy(:), cm(:), cd(:), ch(:), cn(:), cs(:)];
else
d=[cy(:), cm(:), cd(:), ch(:), cn(:), cs(:)];
end
y=datenum(d(:,1),d(:,2),d(:,3),d(:,4),d(:,5),d(:,6));
	
