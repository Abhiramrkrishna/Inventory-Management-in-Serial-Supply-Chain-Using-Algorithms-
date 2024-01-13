function [sum30tscc]=bp2simu(sbstock,mbstock,dbstock,rbstock)
chc=0;          %cum holding cost initialisation
csc=0;          %cum shortage cost initialisation
sum30tscc=0;    %cum sum of tscc initialisation

%----------------------------
% sbstock=169;
% mbstock=276;
% dbstock=142;
% rbstock=112;
%-----------------------
rlt     =   1;%2;
rhc0    =   100;
rsc0    =   200;%150;
%rsc0=24;
%----------------------
dlt     =   1;%3;
dhc0    =   100;
dsc0    =   0;%0;
%dsc0=12;
%-----------------------
mlt     =   1;%6;
mhc0    =   100;
msc0    =   0;%0;
%msc0=6;
%----------------------
slt     =   1;%4;
shc0    =   100;
ssc0    =   0;%0;
%ssc0=3;
%-------------------------

    rdemand     =   zeros(1,1000);
    ddemand     =   zeros(1,1000);
    mdemand     =   zeros(1,1000);
    sdemand     =   zeros(1,1000);
    
for j=30 % 20 to read data from 20 files
    file    =strcat('Demand\Dem-0-1000\dem_',num2str(j),'.txt');
    rdemand =load(file);
    chc=0;csc=0;tscc=0;
 %-------------------------------------   
  % rdemand(1) = 21
  % rdemand(2) = 33
  % rdemand(3) = 30

%----------------------------

    
    ronorder        =   zeros(1,1000);%retailer on order inventory
    donorder        =   zeros(1,1000);
    monorder        =   zeros(1,1000);
    sonorder        =   zeros(1,1000);
    rreceipt        =   zeros(1,1000);
    dreceipt        =   zeros(1,1000);
    mreceipt        =   zeros(1,1000);
    sreceipt        =   zeros(1,1000);
    rbacklogsatisfy =   zeros(1,1000);
    dbacklogsatisfy =   zeros(1,1000);
    mbacklogsatisfy =   zeros(1,1000);
    sbacklogsatisfy =   zeros(1,1000);
    rsohi           =   zeros(1,1000);%retailer starting on hand inventory
    dsohi           =   zeros(1,1000);
    msohi           =   zeros(1,1000);
    ssohi           =   zeros(1,1000);
    rsatisfied      =   zeros(1,1000);
    dsatisfied      =   zeros(1,1000);
    msatisfied      =   zeros(1,1000);
    ssatisfied      =   zeros(1,1000);
    rbacklog        =   zeros(1,1000);
    dbacklog        =   zeros(1,1000);
    mbacklog        =   zeros(1,1000);
    sbacklog        =   zeros(1,1000);
    rcloseohi       =   zeros(1,1000);
    dcloseohi       =   zeros(1,1000);
    mcloseohi       =   zeros(1,1000);
    scloseohi       =   zeros(1,1000);
    rtoorder        =   zeros(1,1000);%retailer to order
    dtoorder        =   zeros(1,1000);
    mtoorder        =   zeros(1,1000);
    stoorder        =   zeros(1,1000);
    rhc             =   zeros(1,1000);
    dhc             =   zeros(1,1000);
    mhc             =   zeros(1,1000);
    shc             =   zeros(1,1000);
    rsc             =   zeros(1,1000);
    dsc             =   zeros(1,1000);
    msc             =   zeros(1,1000);
    ssc             =   zeros(1,1000);
    trscc           =   zeros(1,1000);
    tdscc           =   zeros(1,1000);
    tmscc           =   zeros(1,1000);
    tsscc           =   zeros(1,1000);
    thc             =   zeros(1,1000);
    tsc             =   zeros(1,1000);
    
    for i=1:1000 % Number of days
        
        if i==1
            ronorder(i)=0;rreceipt(i)=0;rbacklogsatisfy(i)=0;%rsohi(i)=0;rsatisfied(i)=0;
            donorder(i)=0;dreceipt(i)=0;dbacklogsatisfy(i)=0;%dsohi(i)=0;dsatisfied(i)=0;
            monorder(i)=0;mreceipt(i)=0;mbacklogsatisfy(i)=0;%msohi(i)=0;msatisfied(i)=0;
            sonorder(i)=0;sreceipt(i)=0;sbacklogsatisfy(i)=0;%ssohi(i)=0;ssatisfied(i)=0;
            
            
            rsohi(i)        =rbstock;
            rsatisfied(i)   =min(rdemand(i),rsohi(i));
            rbacklog(i)     =abs(min(0,(rsohi(i)-rdemand(i))));            
            rcloseohi(i)    =max(0,(rsohi(i)-rsatisfied(i)));
            rtoorder(i)     =rbstock-rcloseohi(i)+rbacklog(i)-ronorder(i);
            
            dsohi(i)        =dbstock;
            ddemand(i)      =rtoorder(i);
            dsatisfied(i)   =min(ddemand(i),dsohi(i));
            dbacklog(i)     =abs(min(0,(dsohi(i)-ddemand(i))));
            dcloseohi(i)    =max(0,(dsohi(i)-dsatisfied(i)));
            dtoorder(i)     =dbstock-dcloseohi(i)+dbacklog(i)-donorder(i);
            
            msohi(i)        =mbstock;
            mdemand(i)      =dtoorder(i);
            msatisfied(i)   =min(mdemand(i),msohi(i));
            mbacklog(i)     =abs(min(0,(msohi(i)-mdemand(i))));
            mcloseohi(i)    =max(0,(msohi(i)-msatisfied(i)));
            mtoorder(i)     =mbstock-mcloseohi(i)+mbacklog(i)-monorder(i);
            
            ssohi(i)        =sbstock;
            sdemand(i)      =mtoorder(i);
            ssatisfied(i)   =min(sdemand(i),ssohi(i));
            sbacklog(i)     =abs(min(0,(ssohi(i)-sdemand(i))));            
            scloseohi(i)    =max(0,(ssohi(i)-ssatisfied(i)));
            stoorder(i)     =sbstock-scloseohi(i)+abs(sbacklog(i))-sonorder(i);            
        end
        
        if i>rlt
           rreceipt(i)     =dsatisfied(i-rlt)+dbacklogsatisfy(i-rlt);
        else
            rreceipt(i)=0 ;
        end
        if i>dlt 
            dreceipt(i)     =msatisfied(i-dlt)+mbacklogsatisfy(i-dlt);
        else
           dreceipt(i)=0;
        end
        if i>mlt 
           mreceipt(i)     =ssatisfied(i-mlt)+sbacklogsatisfy(i-mlt);
        else
           mreceipt(i)=0;
        end
        if i>slt 
          sreceipt(i)     =stoorder(i-slt);
        else
           sreceipt(i)=0;
        end
        
        if i>1
            rbacklogsatisfy(i)=min(rbacklog(i-1),rreceipt(i));
            rsohi(i)        =rcloseohi(i-1)+rreceipt(i)-rbacklogsatisfy(i);
            ronorder(i)     =ronorder(i-1)+rtoorder(i-1)-rreceipt(i);
            rsatisfied(i)   =min(rdemand(i),rsohi(i));
            rbacklog(i)     =rbacklog(i-1)-rbacklogsatisfy(i)+abs(min(0,(rsohi(i)-rdemand(i))));
            rcloseohi(i)    =max(0,(rsohi(i)-rsatisfied(i)));
            rtoorder(i)     =rbstock-rcloseohi(i)+rbacklog(i)-ronorder(i);
            
            dbacklogsatisfy(i)=min(dbacklog(i-1),dreceipt(i));
            dsohi(i)        =dcloseohi(i-1)+dreceipt(i)-dbacklogsatisfy(i);
            donorder(i)     =donorder(i-1)+dtoorder(i-1)-dreceipt(i);
            ddemand(i)      =rtoorder(i);
            dsatisfied(i)   =min(ddemand(i),dsohi(i));
            dbacklog(i)     =dbacklog(i-1)-dbacklogsatisfy(i)+abs(min(0,(dsohi(i)-ddemand(i))));
            dcloseohi(i)    =max(0,(dsohi(i)-dsatisfied(i)));
            dtoorder(i)     =dbstock-dcloseohi(i)+dbacklog(i)-donorder(i);
            
            mbacklogsatisfy(i)=min(mbacklog(i-1),mreceipt(i));
            msohi(i)        =mcloseohi(i-1)+mreceipt(i)-mbacklogsatisfy(i);
            monorder(i)     =monorder(i-1)+mtoorder(i-1)-mreceipt(i);
            mdemand(i)      =dtoorder(i);
            msatisfied(i)   =min(mdemand(i),msohi(i));
            mbacklog(i)     =mbacklog(i-1)-mbacklogsatisfy(i)+abs(min(0,(msohi(i)-mdemand(i))));
            mcloseohi(i)    =max(0,(msohi(i)-msatisfied(i)));
            mtoorder(i)     =mbstock-mcloseohi(i)+mbacklog(i)-monorder(i);
            
            sbacklogsatisfy(i)=min(sbacklog(i-1),sreceipt(i));
            ssohi(i)        =scloseohi(i-1)+sreceipt(i)-sbacklogsatisfy(i);
            sonorder(i)     =sonorder(i-1)+stoorder(i-1)-sreceipt(i);
            sdemand(i)      =mtoorder(i);
            ssatisfied(i)   =min(sdemand(i),ssohi(i));
            sbacklog(i)     =sbacklog(i-1)-sbacklogsatisfy(i)+abs(min(0,(ssohi(i)-sdemand(i))));
            scloseohi(i)    =max(0,(ssohi(i)-ssatisfied(i)));
            stoorder(i)     =sbstock-scloseohi(i)+abs(sbacklog(i))-sonorder(i);            
        end
        
%------ Calculation of costs-----
        rhc(i)=rcloseohi(i)*rhc0;   rsc(i)=rbacklog(i)*rsc0;    trscc(i)=rhc(i)+rsc(i);
        dhc(i)=dcloseohi(i)*dhc0;   dsc(i)=dbacklog(i)*dsc0;    tdscc(i)=dhc(i)+dsc(i);
        mhc(i)=mcloseohi(i)*mhc0;   msc(i)=mbacklog(i)*msc0;    tmscc(i)=mhc(i)+msc(i);
        shc(i)=scloseohi(i)*shc0;   ssc(i)=sbacklog(i)*ssc0;    tsscc(i)=shc(i)+ssc(i);
        thc(i)=rhc(i)+dhc(i)+mhc(i)+shc(i);
        tsc(i)=rsc(i)+dsc(i)+msc(i)+ssc(i);
        chc=chc+thc(i);
        csc=csc+tsc(i);    
        tscc=chc+csc;
%----------------------------------
    end
%   fprintf('CUMULATIVE HOLDING COST%8d\t\t CUMULATIVE SHORTAGE COST%8d\t\tCUMULATIVE SCC COST%10d \n',chc,csc,chc+csc);
    tscc=chc+csc;
    sum30tscc=sum30tscc+tscc;
    
end % end of 30 file loop
    
%     fprintf('Mean supply chain cost for 30 data sets = %f \n',ave30tscc);

