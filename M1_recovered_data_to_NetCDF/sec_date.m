function c=sec_date(sec1970)

% function sec_date computes the date from the seconds from
% January 1 1970 00:00:00
%
% input = number of seconds since January 1 1970
% output = date string
% 

% nargin is the number of input arguments
nargin;
% Number of seconds in a day
fac=24*60*60;

if (nargin<1 || nargin>1)
  error('function must have 1 input argument')
end

if nargin == 1
% First compute the number of days since 1970,1,1
  d=sec1970./fac;
% compute the datenum for 1970,1,1
  x0=datenum(1970,1,1,0,0,0);
% Now add the number of days to the 1970 datenum
  x=d+x0;
% Now convert from datenum to datevec;
  c=datevec(x);
end
