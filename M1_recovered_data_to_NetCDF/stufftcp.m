function y=stufftcp(tarr,tcp,tcpf)
% This function assumes that the input has the format:
% tcp=[time, pressure, temperature, conductivity, salinity]
% for microcat data when this function is called the array
% tXn should be sent as tXn(:,[1 3:6]) to skip the s/n column in
% the array.
% This will be a compiled function to place data into various arrays
% based upon tarr
% create empty arrays based upon the input time vector
lt=length(tarr);
ztemp=-999.*ones(lt,1);
zcond=-999.*ones(lt,1);
zsalt=-999.*ones(lt,1);
zpres=-999.*ones(lt,1);
ztime=-999.*ones(lt,1);
ftemp=ones(lt,1);
fcond=ones(lt,1);
fsalt=ones(lt,1);
fpres=ones(lt,1);
% go through the data and "stuff" it into the appropriate time.
% display every 500 sample to monitor progress.
for i=1:lt
    if rem(i,500)==0
		disp(i);
    end
     secoff=300; % normally
    % 
    %secoff=43200;
	ictd=find((tcp(:,1) > (tarr(i)-secoff))&(tcp(:,1) <= (tarr(i)+secoff)));
	tcpt=[]; tcpc=[]; tcps=[]; tcpp=[]; %#ok<NASGU>
	if isempty(ictd)==0
		if isscalar(ictd)
			zpres(i)=tcp(ictd,2);
			fpres(i)=tcpf(ictd,1);
			ztemp(i)=tcp(ictd,3);
			ftemp(i)=tcpf(ictd,2);
			zcond(i)=tcp(ictd,4);
			fcond(i)=tcpf(ictd,3);
			zsalt(i)=tcp(ictd,5);
			fsalt(i)=tcpf(ictd,4);
			ztime(i)=tcp(ictd,1);
        else	
			jp=tcpf(ictd,1)==0;
			jt=tcpf(ictd,2)==0;
			jc=tcpf(ictd,3)==0;
			js=tcpf(ictd,4)==0;
			ctdp=tcp(ictd(jp),2);
			ctdt=tcp(ictd(jt),3);
			ctdc=tcp(ictd(jc),4);
			ctds=tcp(ictd(js),5);
            %keyboard;
            % YIKES we DO NOT WANT a mean value of bad data...
			ztime(i)=mean(tcp(ictd,1));
			if isempty(ctdp)==0
				zpres(i)=mean(ctdp);
				fpres(i)=0;
            else
                zpres(i)=-999;
                fpres(i)=3;
			end
			if isempty(ctdt)==0
				ztemp(i)=mean(ctdt);
				ftemp(i)=0;
            else
                ztemp(i)=-999;
                ftemp(i)=3;
			end
			if isempty(ctdc)==0
				zcond(i)=mean(ctdc);
				fcond(i)=0;
            else
                zcond(i)=-999;
                fcond(i)=3;
			end
			if isempty(ctds)==0
				zsalt(i)=mean(ctds);
				fsalt(i)=0;
            else
                zsalt(i)=-999;
                fsalt(i)=3;
			end
		end
	end
end
% Return the filled arrays
y=[ztime zpres ztemp zcond zsalt fpres ftemp fcond fsalt];

