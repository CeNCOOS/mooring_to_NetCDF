% code to test flag setup in NetCDF files
%
file=['OS_M1_19920116_D_TMTS_new.nc'];
time=ncread(file,'time');
%time=ncread(file,'TIME');
temp=ncread(file,'temperature');
tempqc=ncread(file,'temperature_qc');
salt=ncread(file,'salinity');
saltqc=ncread(file,'salinity_qc');
%temp=ncread(file,'TEMP');
%tempqc=ncread(file,'TEMP_QC');
%salt=ncread(file,'PSAL');
%saltqc=ncread(file,'PSAL_QC');
time=time/24/60/60;
offset=datenum(1970,1,1); %#ok<DATNM>
time=time+offset;
temp=squeeze(temp);
tempqc=squeeze(tempqc);
salt=squeeze(salt);
saltqc=squeeze(saltqc);
ll=saltqc > 0;

