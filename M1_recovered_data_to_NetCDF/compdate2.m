function y=compdate %#ok<FNDEF>
% This is a function that returns the system time as a date
% string of the form Month Day, Year (e.g. May 10, 2000)
%
monc=['January  '
      'February '
      'March    '
      'April    '
      'May      '
      'June     '
      'July     '
      'August   '
      'September'
      'October  '
      'November '
      'December ']; %#ok<NASGU>
mond=[7,8,5,5,3,4,4,6,9,7,8,8]; %#ok<NASGU>
dvec=clock;
y=sprintf('%2.2d/%2.2d/%4.4d',dvec(2),dvec(3),dvec(1));
%y=[monc(dvec(2),[1:mond(dvec(2))]),'/'num2str(dvec(3)),', ',num2str(dvec(1))];
