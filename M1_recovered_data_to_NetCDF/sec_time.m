function c=sec_time(d,year)

% function sec_time computes seconds from January 1 1970 00:00:00
%
% input = datenum or
%       = yearday, year
% output = seconds from January 1 1970 00:00:00
%
%
% 

% nargin is the number of input arguments
nargin;
% Number of seconds in a day
% Note we add the small number to prevent problems associated with reals vs
% integers in their internal representation of numbers.
fac=(24*60*60)+0.000000001;
%fac=(24*60*60);

if (nargin<1 || nargin>2)
  error('function must have 1 or 2 input arguments')
end

if nargin == 1
  x0=datenum(1970,1,1,0,0,0);
  % error check that d is really a datenum!!!
  if d<367
    error('inputed datenum too small')
  return %#ok<UNRCH>
  end
  x=d-x0;   % number of days from 1970
  c=x.*fac; % seconds since 1970 to present
  c=fix(c);
end

if nargin == 2
  % check that we are not working on datenums
  if d>367
    error('inputed yearday too big')
  return %#ok<UNRCH>
  end
   % convert year and yearday to calendar day
   [year, month, day, hour, minute, second]=yd2cal( year, d);
   % convert calendar day to datenum
    d=datenum(year,month,day,hour,minute,second);
    x0=datenum(1970,1,1,0,0,0);
    x=d-x0;   % number of days from 1970
    c=x.*fac; % seconds since 1970 to present
    c=fix(c);   
end
   
