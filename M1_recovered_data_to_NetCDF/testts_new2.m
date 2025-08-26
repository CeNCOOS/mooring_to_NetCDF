% test netCDF file creation
% Program to create NetCDF files from the ICON store *.mat files for
% distribution to MBARI.

% First load the NetCDF library functions 
%ncstartup
% Get Mooring id to load data for
mid=input('Enter the mooring id: ');
% Create a string for the mooring id
mst=['M',num2str(mid)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For this file we want to place surface CTD and subsurface Microcat data
% together.  To do this in a NetCDF files we will have to create an artificial
% time variable and match up time in the other variable to the nearest value
% we use the artifical time line as the record variable. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Get the starting and ending dates
ddate=input('Enter the starting and Ending dates (e.g. [yyyymmdd yyyymmdd]): ');
wztime=input('Enter the startin and ending times (e.g. [hhmmss hhmmss] or []): ');
if isempty(wztime)==0
	years=fix(ddate(1)./10000);
	yeare=fix(ddate(2)./10000);
	mons=fix((ddate(1)-years.*10000)./100);
	mone=fix((ddate(2)-yeare.*10000)./100);
	days=rem(ddate(1),100);
	daye=rem(ddate(2),100);
	hours=fix(wztime(1)./10000);
	houre=fix(wztime(2)./10000);
	mins=fix((wztime(1)-hours.*10000)./100);
	mine=fix((wztime(2)-houre.*10000)./100);
	secs=rem(wztime(1),100);
	sece=rem(wztime(2),100);
	startit=datenum(years,mons,days,hours,mins,secs); %#ok<DATNM> 
	stopit=datenum(yeare,mone,daye,houre,mine,sece); %#ok<DATNM> 
end
fout=input('Enter the output file name (no extension .nc is appended: ','s');
% append .nc to the filename
fileout=[fout,'.nc'];
% The following is for loading data for the use below.
% The arrays tX have the format [time,serial number,temperature,
% conductivity, serial number]
% The arrays fX have the format [serial number flag, temperature flag,
% conductivity flag, salinity flag]
% so the array tX has size [ntimes X 6]
% the array fX has the size [ntimes X 5]
%
if mid==4
	[t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,tn,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11]=dataloader(mid,ddate(1),ddate(2),3);
mzm=11;
else
    %[t1,t2,t3,t4,t5,t6,t7,t8,t9,tn,f1,f2,f3,f4,f5,f6,f7,f8,f9]=dataloader(mid,ddate(1),ddate(2),3);
	[t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,tn,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10]=dataloader(mid,ddate(1),ddate(2),3);
mzm=10;
%mzm=9;
% mzm is the number of instruments on the mooring
end
% The following is for loading the surface microcat data which is stored
% seperately from the subsurface data.
[ctdn,ctdf] =dataloader(mid,ddate(1),ddate(2),2);
% Now truncate data to only the period of time for a deployment or such.
% This section truncates for the surface CTD data.
ttl=((ctdn(:,1) > startit)&(ctdn(:,1) < stopit));
ctdn=ctdn(ttl,:);
ctdf=ctdf(ttl,:);
% This section truncates for the subsurface data.
for i=1:mzm
	i %#ok<NOPTS> This is the help monitor the loop.
	eval(['ttl=((t',num2str(i),'(:,1) > startit)&(t',num2str(i),'(:,1)< stopit));']);
	eval(['t',num2str(i),'=t',num2str(i),'(ttl,:);']); %#ok<EVLSEQVAR>
	eval(['f',num2str(i),'=f',num2str(i),'(ttl,:);']); %#ok<EVLSEQVAR>
end
% mooring location and depth
% Below are the mooring number, nominal water depths and nominal positions.
switch mid
	case 1
		wdepth='1600m';
		nlon=-122.03;
		nlat=36.75;
	case 2
		wdepth='1800m';
		nlon=-122.39;
		nlat=36.70;
	case 3
		wdepth='3000m';
		nlon=-122.96;
		nlat=36.56;
	case 4
		wdepth='2000m';
		nlon=-122.45;
		nlat=36.19;
    otherwise
		wdepth=-999;
		nlon=-999;
		nlat=-999;
end
% First we need to create our artificial time array
% Now we create a uniform array to match all the data to.  
% Each instrument has its own time-base, so we want to put them on a
% uniform time base as old NetCDF allowed for only 1 unlimited dimension.
ystart=fix(ddate(1)./10000);
yend=fix(ddate(2)./10000);
smon=fix((ddate(1)-ystart.*10000)./100);
emon=fix((ddate(2)-yend.*10000)./100);
sday=rem(ddate(1),100);
eday=rem(ddate(2),100);
tbeg=datenum(ystart,smon,sday,00,00,00); %#ok<DATNM,NASGU>
tend=datenum(yend,emon,eday,00,00,00); %#ok<DATNM,NASGU>
tbeg=sec_time(startit);
tend=sec_time(stopit);
% now to create the time array with values every 10 minutes (600sec)
% 10 minutes is the frequency at which these instruments sampled.
tarr=tbeg:600:tend;
xtime=tarr;
xtime=xtime/24/60/60;
xtime=xtime+datenum(1970,1,1); %#ok<DATNM> 
% To use this array, we need to convert times in all of our other
% arrays to seconds since Jan 1 1970....
% You can set up the time you want to use however you want but this is what
% was done for this data.
ctdn(:,1)=sec_time(ctdn(:,1));
%%%%%%%%%%%%%
%
% Note: We need to handle M1 Nov 2000-Nov 2001 different.  Depths of 
% microcats were nonstandard !
%
%%%%%%%%%%%%%
if mid==4
	ntt=11;
	ndep=[1 10 20 40 60 80 100 150 200 250 300 350];
else
	ntt=10;
	ndep=[1 10 20 40 60 80 100 150 200 250 300];
    if mid==2
        ntt=9;
        ndep=[1 10 20 40 60 80 100 150 200 300];
    end
%	ndep=[1 10 30 50 70 90 140 190 240 290 360];
end
% This converts the subsurface time data as was done above.
for i=1:ntt
	i %#ok<NOPTS>
	eval(['t',num2str(i),'(:,1)=sec_time(t',num2str(i),'(:,1));']);
end
% Now the fun stuff.  We need to sort times to create our huge array
% that contains all of the data in the appropriate spots and we need
% to resolve if two points fall within the same spot.........
% all the instruments that we are working with are sampled at 10 minutes
lt=length(tarr) %#ok<NOPTS>
ztemp=-999.*ones(lt,ntt+1);
zcond=-999.*ones(lt,ntt+1);
zsalt=-999.*ones(lt,ntt+1);
zpres=-999.*ones(lt,ntt+1);
ftemp=ones(lt,ntt+1);
fcond=ones(lt,ntt+1);
fsalt=ones(lt,ntt+1);
fpres=ones(lt,ntt+1);
y=stufftcp(tarr,ctdn,ctdf);
ztime(:,1)=y(:,1);
zpres(:,1)=y(:,2);
ztemp(:,1)=y(:,3);
zcond(:,1)=y(:,4);
zsalt(:,1)=y(:,5);
fpres(:,1)=y(:,6);
ftemp(:,1)=y(:,7);
fcond(:,1)=y(:,8);
fsalt(:,1)=y(:,9);
% The following code takes the instrument data and nudges it to the nearest
% 10 minute time in the defined time vectory.   If there were more than one
% sample in the intermal a mean value was computed (but flags are used to
% determine if both values are to be used and what the output flag base on
% the two flags should be.
for k=1:ntt
	disp(k)
	eval(['y=stufftcp(tarr,t',num2str(k),'(:,[1 3:6]),f',num2str(k),'(:,[2:5]));']);
	ztime(:,k+1)=y(:,1);
	zpres(:,k+1)=y(:,2);
	ztemp(:,k+1)=y(:,3);
	zcond(:,k+1)=y(:,4);
	zsalt(:,k+1)=y(:,5);
	fpres(:,k+1)=y(:,6);
	ftemp(:,k+1)=y(:,7);
	fcond(:,k+1)=y(:,8);
	fsalt(:,k+1)=y(:,9);
end
% convert flags of type 3 to type 1 (bad data)
% there was an issue with the flag of type 3.
lt=ftemp==3;
ftemp(lt)=1;
ll=fsalt==3;
fsalt(ll)=1;
% step 2) open our netCDF file
ncid=netcdf.create(fileout,'NETCDF4');
% time is our record variable
timeID=netcdf.defDim(ncid,'time',netcdf.getConstant('NC_UNLIMITED'));
% other coordinate variables needed
% Number of instruments
latID=netcdf.defDim(ncid,'latitude',1);
lonID=netcdf.defDim(ncid,'longitude',1);
depthID=netcdf.defDim(ncid,'depth',ntt+1);
% get system time
cdate=compdate2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following creates and writes the NetCDF Global attributes.
% Change as appropriate for your mooring.
% Global attributes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc_global=netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid,nc_global,'title','"Gridded 10 minute MBARI Mooring M1 Sea Water Temperature and Salinity Observations');
netcdf.putAtt(ncid,nc_global,'date_created',datestr(localpacifictoUTC(now),'yyyy-mm-ddTHH:MM:SSZ')); %#ok<DATST,TNOW1> 
netcdf.putAtt(ncid,nc_global,'acknowlegement','MBARI');
netcdf.putAtt(ncid,nc_global,'cdm_data_type','Station');
netcdf.putAtt(ncid,nc_global,'comment','M1 Deployment');
netcdf.putAtt(ncid,nc_global,'contributor_name','Fred Bahr, Francisco Chavez, Jared Figurski, MBARI');
netcdf.putAtt(ncid,nc_global,'contributor_role','author, data provider, deployer, facility');
netcdf.putAtt(ncid,nc_global,'conventions','CF-1.6');
netcdf.putAtt(ncid,nc_global,'creator_name','Fred Bahr');
netcdf.putAtt(ncid,nc_global,'creator_email','flbahr@mbari.org');
netcdf.putAtt(ncid,nc_global,'creator_url','http://www.mbari.org/');
netcdf.putAtt(ncid,nc_global,'date_issued',datestr(localpacifictoUTC(now),'yyyy-mm-ddTHH:MM:SSZ')); %#ok<DATST,TNOW1> 
netcdf.putAtt(ncid,nc_global,'date_modified',datestr(localpacifictoUTC(now),'yyyy-mm-ddTHH:MM:SSZ')); %#ok<DATST,TNOW1> 
netcdf.putAtt(ncid,nc_global,'date_update',datestr(localpacifictoUTC(now),'yyyy-mm-ddTHH:MM:SSZ')); %#ok<DATST,TNOW1> 
netcdf.putAtt(ncid,nc_global,'featureType','timeSeriesProfile');
netcdf.putAtt(ncid,nc_global,'data_type','OceanSites time-series data');
netcdf.putAtt(ncid,nc_global,'geospatial_lat_max',num2str(36.763));
netcdf.putAtt(ncid,nc_global,'geospatial_lat_min',num2str(36.745));
netcdf.putAtt(ncid,nc_global,'geospatial_lat_resolution','point');
netcdf.putAtt(ncid,nc_global,'geospatial_lat_units','degrees_north');
netcdf.putAtt(ncid,nc_global,'geospatial_lon_max',num2str(122.02));
netcdf.putAtt(ncid,nc_global,'geospatial_lon_min',num2str(121.036));
netcdf.putAtt(ncid,nc_global,'geospatial_lon_resolution','point');
netcdf.putAtt(ncid,nc_global,'geospatial_lon_units','degrees_east');
netcdf.putAtt(ncid,nc_global,'geospatial_vertical_max',num2str(300));
netcdf.putAtt(ncid,nc_global,'geospatial_vertical_min',num2str(0));
netcdf.putAtt(ncid,nc_global,'geospatial_vertical_positive','down');
netcdf.putAtt(ncid,nc_global,'geospatial_vertical_resolution','point');
netcdf.putAtt(ncid,nc_global,'geospatial_vertical_units','meters');
netcdf.putAtt(ncid,nc_global,'history','Data manually inspected.');
netcdf.putAtt(ncid,nc_global,'time_coverage_start',datestr(xtime(1),'yyyy-mm-ddTHH:MM:SSZ')); %#ok<DATST> 
netcdf.putAtt(ncid,nc_global,'time_coverage_end',datestr(xtime(end),'yyyy-mm-ddTHH:MM:SSZ')); %#ok<DATST> 
dstr=['P',num2str(xtime(end)-xtime(1)),'D'];
netcdf.putAtt(ncid,nc_global,'time_coverage_duration',dstr);
netcdf.putAtt(ncid,nc_global,'time_coverage_resolution','PT10M')
netcdf.putAtt(ncid,nc_global,'id',fileout);
netcdf.putAtt(ncid,nc_global,'institution','MBARI');
netcdf.putAtt(ncid,nc_global,'ioos_regional_association','CeNCOOS');
netcdf.putAtt(ncid,nc_global,'keywords_vocabulary','GCMD Science Keywords');
keywords=['Oceans>Oceans Pressure>Water  Pressure, Oceans, Ocean Temperature>Water Temperature,']; %#ok<NBRAK>
keywords=[keywords,'Oceans>Salinity/Density>Salinity/Density>Salinity']; 
netcdf.putAtt(ncid,nc_global,'keywords',keywords);
netcdf.putAtt(ncid,nc_global,'keywords_vocabulary','GCMD Science Keywords');
netcdf.putAtt(ncid,nc_global,'license','The data may be used and redistributed for free but is not intended for legal use, since it may contain inaccuracies. Neither the data Contributor, MBARI, CeNCOOS, NOAA, State of California nor the United States Government, nor any of their employees or contractors, makes any warranty, express or implied, including warranties of merchantability and fitness for a particular purpose, or assumes any legal liability for the accuracy, completeness, or usefulness, of this information.');
netcdf.putAtt(ncid,nc_global,'Metadata_Conventions','Unidata Dataset Discovery v1.0, OceanSITES Manual 1.1, CF-1.6');
netcdf.putAtt(ncid,nc_global,'metadata_link',' ');
netcdf.putAtt(ncid,nc_global,'naming_authority','OceanSITES');
netcdf.putAtt(ncid,nc_global,'processing_level','Data from MBARI microcats manually reviewed');
netcdf.putAtt(ncid,nc_global,'project','OASIS,MBARI Time-Series');
netcdf.putAtt(ncid,nc_global,'publisher_email','flbahr@mbari.org');
netcdf.putAtt(ncid,nc_global,'publisher_name','Fred Bahr');
netcdf.putAtt(ncid,nc_global,'publisher_url','http://www.mbari.org/thredds/');
netcdf.putAtt(ncid,nc_global,'references','http://www.mbari.org');
netcdf.putAtt(ncid,nc_global,'sea_name','North Pacific Ocean');
netcdf.putAtt(ncid,nc_global,'source','Microcat Observations from MBARI mooring M1');
netcdf.putAtt(ncid,nc_global,'instrumentType','Mooring M1 SeaCat and MicroCat Data');
netcdf.putAtt(ncid,nc_global,'waterDepth',wdepth);
netcdf.putAtt(ncid,nc_global,'dataflagcomment','Good data flag=0, bad data=1,3 marginal data=2');
netcdf.putAtt(ncid,nc_global,'contributor_email','chfr@mbari.org');
netcdf.putAtt(ncid,nc_global,'site_code','MBARI');
netcdf.putAtt(ncid,nc_global,'platform_code','M1');
netcdf.putAtt(ncid,nc_global,'data_mode','D');
netcdf.putAtt(ncid,nc_global,'data_assembly_center','MBARI');
netcdf.putAtt(ncid,nc_global,'update_interval','void');
netcdf.putAtt(ncid,nc_global,'wmo_platform_code','46091');
netcdf.putAtt(ncid,nc_global,'source','Mooring observation');
netcdf.putAtt(ncid,nc_global,'principal_investigator','Francisco Chavez');
netcdf.putAtt(ncid,nc_global,'citation','These data were collected and made freely available by the Monterey Bay Aquarium Research Institute.');
netcdf.putAtt(ncid,nc_global,'QC_indicator','mixed');
netcdf.putAtt(ncid,nc_global,'format_version','1.3');
netcdf.putAtt(ncid,nc_global,'netcdfd_version','3.5');
netcdf.putAtt(ncid,nc_global,'calibrationFiles','null');
netcdf.putAtt(ncid,nc_global,'configurationFile','null');

% Record variable
% define the record and dimension variables.
vartimeID=netcdf.defVar(ncid,'time','double',timeID);
netcdf.putAtt(ncid,vartimeID,'axis','T');
netcdf.putAtt(ncid,vartimeID,'calendar','gregorian');
netcdf.putAtt(ncid,vartimeID,'standard_name','time');
netcdf.putAtt(ncid,vartimeID,'long_name','Time');
netcdf.putAtt(ncid,vartimeID,'units','seconds since 1970-01-01 00:00:00');
netcdf.defVarFill(ncid,vartimeID,false,-99999.0);
netcdf.putAtt(ncid,vartimeID,'valid_min',tarr(1));
netcdf.putAtt(ncid,vartimeID,'valid_max',tarr(end));
netcdf.putAtt(ncid,vartimeID,'uncertainty',0.003);
netcdf.putAtt(ncid,vartimeID,'observation_type','measured');
netcdf.putAtt(ncid,vartimeID,'sensor_name',' ');

vlatID=netcdf.defVar(ncid,'latitude','double',latID);
netcdf.putAtt(ncid,vlatID,'standard_name','latitude');
netcdf.putAtt(ncid,vlatID,'long_name','Latitude');
netcdf.putAtt(ncid,vlatID,'units','degrees_north');
netcdf.putAtt(ncid,vlatID,'axis','Y');
netcdf.defVarFill(ncid,vlatID,false,99999.0);
netcdf.putAtt(ncid,vlatID,'valid_min',-90.0);
netcdf.putAtt(ncid,vlatID,'valid_max',90.0);
netcdf.putAtt(ncid,vlatID,'uncertainty',0.01);
netcdf.putAtt(ncid,vlatID,'reference','WGS84');
netcdf.putAtt(ncid,vlatID,'sensor_name',' ');
netcdf.putAtt(ncid,vlatID,'reference_datum','Geographical Coordinates, WGS84 projections');
netcdf.putAtt(ncid,vlatID,'coordinate_reference_frame','urn:ogc:crs:EPSG::4326');

vlonID=netcdf.defVar(ncid,'longitude','double',lonID);
netcdf.putAtt(ncid,vlonID,'long_name','Longitude');
netcdf.putAtt(ncid,vlonID,'standard_name','longitude');
netcdf.putAtt(ncid,vlonID,'units','degrees_east');
netcdf.defVarFill(ncid,vlonID,false,99999.0);
netcdf.putAtt(ncid,vlonID,'valid_min',-180.0);
netcdf.putAtt(ncid,vlonID,'valid_max',180.0);
netcdf.putAtt(ncid,vlonID,'uncertainty',0.01);
netcdf.putAtt(ncid,vlonID,'axis','X');
netcdf.putAtt(ncid,vlonID,'reference','WGS84');
netcdf.putAtt(ncid,vlonID,'sensor_name',' ');
netcdf.putAtt(ncid,vlonID,'reference_datum','Geographical Coordinates, WGS84 projections');

vdepthID=netcdf.defVar(ncid,'depth','float',depthID);
netcdf.putAtt(ncid,vdepthID,'long_name','Instrument Depth');
netcdf.putAtt(ncid,vdepthID,'standard_name','depth');
netcdf.putAtt(ncid,vdepthID,'units','meters');
netcdf.putAtt(ncid,vdepthID,'positive','down');
netcdf.putAtt(ncid,vdepthID,'valid_min',0.0);
netcdf.putAtt(ncid,vdepthID,'valid_max',400.0);
netcdf.putAtt(ncid,vdepthID,'uncertainty',0.1);
netcdf.putAtt(ncid,vdepthID,'reference_datum','sea_surface');
netcdf.putAtt(ncid,vdepthID,'coordinate_reference_frame','urn:ogc:crs:EPSG:5113');
netcdf.putAtt(ncid,vdepthID,'axis','Z');
%
% The code below is for all the different variables to include in the file.
tempID=netcdf.defVar(ncid,'temperature','float',[lonID latID depthID timeID]);
netcdf.putAtt(ncid,tempID,'units','Celsius');
netcdf.putAtt(ncid,tempID,'long_name','Temperature');
netcdf.putAtt(ncid,tempID,'standard_name','sea_water_temperature');
netcdf.defVarFill(ncid,tempID,false,-999);
netcdf.putAtt(ncid,tempID,'valid_min',0);
netcdf.putAtt(ncid,tempID,'valid_max',30);
netcdf.putAtt(ncid,tempID,'resolution',0.001);
netcdf.putAtt(ncid,tempID,'coordinates','longitude latitude depth time');
netcdf.putAtt(ncid,tempID,'ancillary_variables','temperature_qc');
netcdf.putAtt(ncid,tempID,'precision',0.0001);
netcdf.putAtt(ncid,tempID,'DM_indicator','D');
netcdf.putAtt(ncid,tempID,'observation_type','measured');
netcdf.putAtt(ncid,tempID,'sensor_name','microcat');

tqcID=netcdf.defVar(ncid,'temperature_qc','float',[lonID latID depthID timeID]);
netcdf.putAtt(ncid,tqcID,'units','none');
netcdf.putAtt(ncid,tqcID,'long_name','sea water temperature flag');
netcdf.defVarFill(ncid,tqcID,false,3);
netcdf.putAtt(ncid,tqcID,'missing_value',3);
netcdf.putAtt(ncid,tqcID,'valid_min',0);
netcdf.putAtt(ncid,tqcID,'valid_max',3);
netcdf.putAtt(ncid,tqcID,'flag_values','0,1,2,3');
netcdf.putAtt(ncid,tqcID,'flag_meanings','good, bad, probably bad, missing');
netcdf.putAtt(ncid,tqcID,'coordinates','longitude latitude depth time');

condID=netcdf.defVar(ncid,'conductivity','float',[lonID latID depthID timeID]);
netcdf.putAtt(ncid,condID,'units','Siemens/m');
netcdf.putAtt(ncid,condID,'long_name','Conductivity');
netcdf.putAtt(ncid,condID,'standard_name','sea_water_electrical_conductivity');
netcdf.defVarFill(ncid,condID,false,-999);
netcdf.putAtt(ncid,condID,'missing_value',-999);
netcdf.putAtt(ncid,condID,'valid_min',2);
netcdf.putAtt(ncid,condID,'valid_max',5);
netcdf.putAtt(ncid,condID,'resolution',0.0001);
netcdf.putAtt(ncid,condID,'coordinates','longitude latitude depth time');
netcdf.putAtt(ncid,condID,'ancillary_variables','conductivity_qc');
netcdf.putAtt(ncid,condID,'precision',0.00001);
netcdf.putAtt(ncid,condID,'DM_indicator','D');
netcdf.putAtt(ncid,condID,'observation_type','measured');
netcdf.putAtt(ncid,condID,'sensor_name','microcat');

cqcID=netcdf.defVar(ncid,'conductivity_qc','float',[lonID latID depthID timeID]);
netcdf.putAtt(ncid,cqcID,'units','none');
netcdf.putAtt(ncid,cqcID,'long_name','conductivity flag');
netcdf.defVarFill(ncid,cqcID,false,3);
netcdf.putAtt(ncid,cqcID,'missing_value',3);
netcdf.putAtt(ncid,cqcID,'valid_min',0);
netcdf.putAtt(ncid,cqcID,'valid_max',3);
netcdf.putAtt(ncid,cqcID,'flag_values','0,1,2,3');
netcdf.putAtt(ncid,cqcID,'flag_meanings','good, bad, probably bad, missing');
netcdf.putAtt(ncid,cqcID,'coordinates','longitude latitude depth time');

saltID=netcdf.defVar(ncid,'salinity','double',[lonID latID depthID timeID]);
netcdf.putAtt(ncid,saltID,'long_name','Sea Water Salinity in-situ PSS 1978 scale');
netcdf.putAtt(ncid,saltID,'standard_name','sea_water_salinity');
netcdf.putAtt(ncid,saltID,'units','1e-3');
netcdf.defVarFill(ncid,saltID,false,-999);
netcdf.putAtt(ncid,saltID,'valid_min',30.0);
netcdf.putAtt(ncid,saltID,'valid_max',37.0);
netcdf.putAtt(ncid,saltID,'resolution',0.001);
netcdf.putAtt(ncid,saltID,'uncertainty',0.002);
netcdf.putAtt(ncid,saltID,'observation_type','calculated');
netcdf.putAtt(ncid,saltID,'instrument','instrument_ctd');
netcdf.putAtt(ncid,saltID,'coordinates','longitude latitude depth time');
netcdf.putAtt(ncid,saltID,'sensor_name','microcat');
netcdf.putAtt(ncid,saltID,'ancillary_variables','salinity_qc');
netcdf.putAtt(ncid,saltID,'comment','Salinity drifted low for surface, and 10m for most of the deployment, it has not been flagged or almost all of the salinity data would have been flagged as bad');

sqcID=netcdf.defVar(ncid,'salinity_qc','float',[lonID latID depthID timeID]);
netcdf.putAtt(ncid,sqcID,'units','none');
netcdf.putAtt(ncid,sqcID,'long_name','sea water salinity flag');
netcdf.defVarFill(ncid,sqcID,false,3);
netcdf.putAtt(ncid,sqcID,'missing_value',3);
netcdf.putAtt(ncid,sqcID,'valid_min',0);
netcdf.putAtt(ncid,sqcID,'valid_max',3);
netcdf.putAtt(ncid,sqcID,'flag_values','0,1,2,3');
netcdf.putAtt(ncid,sqcID,'flag_meanings','good, bad, probably bad, missing');
netcdf.putAtt(ncid,sqcID,'coordinates','longitude latitude depth time');

presID=netcdf.defVar(ncid,'pressure','float',[lonID latID depthID timeID]);
netcdf.putAtt(ncid,presID,'long_name','Pressure');
netcdf.putAtt(ncid,presID,'standard_name','sea_water_pressure');
netcdf.putAtt(ncid,presID,'units','dbar');
netcdf.putAtt(ncid,presID,'positive','down');
netcdf.defVarFill(ncid,presID,false,-999);
netcdf.putAtt(ncid,presID,'valid_min',0.0);
netcdf.putAtt(ncid,presID,'valid_max',400.0);
netcdf.putAtt(ncid,presID,'uncertainty',0.1);
netcdf.putAtt(ncid,presID,'reference_datum','sea_surface');
netcdf.putAtt(ncid,presID,'observation_type','measured');
netcdf.putAtt(ncid,presID,'axis','Z');
netcdf.putAtt(ncid,presID,'sensor_name','microcat');
netcdf.putAtt(ncid,presID,'accuracy',' ');
netcdf.putAtt(ncid,presID,'precision',' ');
netcdf.putAtt(ncid,presID,'resolution',' ');
netcdf.putAtt(ncid,presID,'ancillary_variables','pressure_qc');
netcdf.putAtt(ncid,presID,'coordinates','longitude latitude depth time');

pqcID=netcdf.defVar(ncid,'pressure_qc','float',[lonID latID depthID timeID]);
netcdf.putAtt(ncid,pqcID,'units','none');
netcdf.putAtt(ncid,pqcID,'long_name','sea water pressure flag');
netcdf.defVarFill(ncid,pqcID,false,3);
netcdf.putAtt(ncid,pqcID,'missing_value',3);
netcdf.putAtt(ncid,pqcID,'valid_min',0);
netcdf.putAtt(ncid,pqcID,'valid_max',3);
netcdf.putAtt(ncid,pqcID,'flag_values','0,1,2,3');
netcdf.putAtt(ncid,pqcID,'flag_meanings','good, bad, probably bad, missing');
netcdf.putAtt(ncid,pqcID,'coordinates','longitude latitude depth time');
% end the definition of the NetCDF file
netcdf.endDef(ncid);
% Actually put the data into the define variables
netcdf.putVar(ncid,vartimeID,0,length(tarr),tarr);
netcdf.putVar(ncid,vlatID,nlat);
netcdf.putVar(ncid,vlonID,nlon);
netcdf.putVar(ncid,vdepthID,ndep);
netcdf.putVar(ncid,tempID,ztemp');
netcdf.putVar(ncid,tqcID,ftemp');
netcdf.putVar(ncid,condID,zcond');
netcdf.putVar(ncid,cqcID,fcond');
netcdf.putVar(ncid,saltID,zsalt');
netcdf.putVar(ncid,sqcID,fsalt');
netcdf.putVar(ncid,presID,zpres');
netcdf.putVar(ncid,pqcID,fpres');
% close the NetCDF file
netcdf.close(ncid);

