function  [year,month,day,hour,min,sec] = yd2cal(year,yd)

% YD2CAL - convert yeardays to [year month day hour min sec] format.
%
% Valid usages:
% [year, month, day] = yd2cal(year, yearday)
% [year, month, day, hour] = yd2cal(year, yearday)
% [year, month, day, hour, min] = yd2cal(year, yearday)
% [year, month, day, hour, min, sec] = yd2cal(year, yearday)
%
% NOTE: YD2CAL it won't handle negative yeardays, so YD2CAL(1997,-1) won't
% give you 31 Dec 96 @0000, rather you get -1 Jan 97 @0000.

% Ver 1.0 - Mike Cook, NPS Oceanography, FEB 96
% Ver 2.0 - Mike Cook, 24 Feb 98
%           extend the function to calculate yeardays that extend   
%           beyond the base year.  For example, this function now
%           will handle :  [1996, 364
%                           1996, 365
%                           1996, 366
%                           1996, 367]; 


% Check for both input arguments
if nargin < 2
   error('Must supply year and yearday vectors ... TERMINATING!')
end


% Yearday lookup table. First row is regular years, second is
% leap years lookup.
ydtable = [1,32,60,91,121,152,182,213,244,274,305,335
           1,32,61,92,122,153,183,214,245,275,306,336];

% Add ~ 1 milliseconds before calendar calculation to prevent
% roundoff error resulting from math operations on time 
% from occasionally representing midnight as 
% (for example) 1990 11 30 23 59 59 instead of 1990 12 1 0 0 0;
yd = yd+2.e-8;

yd = yd(:);
ydRows = size(yd,1);

year = year(:);
rows = size(year,1);

% If user inputs only 1 year and yd is an vector, make year a vector
% the same size.
if ydRows ~= rows
    if rows == 1
        year = year * ones(ydRows,1);
	    rows = ydRows;
    else
        error('The # of input years does not equal the # of input yeardays')
    end
end

leap = ones(rows, 1);

% Find all leap years, and increase index into ydtable from 1 to 2.
leapIndex = find( (rem(year,4) == 0 & rem(year,100) ~= 0)  |  rem(year,400) == 0);
leap(leapIndex) = leap(leapIndex) + ones(size(leapIndex));

% Create the output arrays
month = zeros(rows, 1);
day = zeros(rows, 1);
hour = zeros(rows, 1);
min = zeros(rows, 1);
sec = zeros(rows, 1);

% Main processing loop.
for i = 1:rows

   % If yearday is relative to a previous year, such as yd2cal(1996,390.5),
   % recompute the yd and year.
   while  yd(i) >= (ydtable(leap(i),12)+31)
      year(i) = year(i) + 1;
      yd(i) = yd(i) - (ydtable(leap(i),12) + 31 - 1);
   end
   
   % Recalculate the leap year in case the year has changed.  This is a very
   % wasteful calculation if no times extend into next year, may want to think
   % of a better way of doing this for future versions.
   if ((rem(year(i),4) == 0 && rem(year(i),100) ~= 0)  ||  rem(year(i),400) == 0)
      leap(i) = 2;
   else
      leap(i) = 1;
   end
   
   index = find(ydtable(leap(i),:) <= yd(i));
   if ~isempty(index)
      month(i) = index(length(index));
      remain = yd(i) - ydtable(leap(i),index(month(i))) + 1;  % add 1 to yd, ydtable is
   else                                                       % rel. to 1st of next month.
      remain = yd(i);
      month(i) = 1;
   end
   day(i) = floor(remain);
   if nargout > 3
      remain = remain - day(i);
      hour(i) = floor(remain * 24);
   end
   if nargout > 4
      remain = (remain*24) - hour(i);
      min(i) = floor(remain * 60);
   end
   if nargout > 5
      remain = (remain*60) - min(i);
      sec(i) = round(remain * 60);
   end
   
end
