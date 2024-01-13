clear;
clc;
tic
rng('default')
maxdemand=1000;% maxdemand=input('maxdemand?');
mindemand=0;% mindemand=input('mindemand?');
rlt=1;%2 ;% rlt=input('retailer lead time');
dlt=1;%3;% dlt=input('distri lead time');
mlt=1;%6;% mlt=input('manufact lead time');
slt=1;%4;% slt=input('supplier lead time');
rltmin=rlt;
rltmax=rlt+dlt+mlt+slt;
dltmin=dlt;
dltmax=dlt+mlt+slt;
mltmin=mlt;
mltmax=mlt+slt;
sltmin=slt;
sltmax=slt;
rbstock_ul=maxdemand*rltmax; %retailer base stock upper limit
rbstock_ll=mindemand*rltmin; %retailer base stock lower limit
dbstock_ul=maxdemand*dltmax;
dbstock_ll=mindemand*dltmin;
mbstock_ul=maxdemand*mltmax;
mbstock_ll=mindemand*mltmin;
sbstock_ul=maxdemand*sltmax;
sbstock_ll=mindemand*sltmin;
pd=4; % number of decision variables
N=20; % Flock (population) size
AP=0.1; % Awareness probability
fl=2; % Flight length
x=zeros(N,pd);%preallocation for saving memory
for i=1:N
    for j=1:pd
        if j==1                   %supplier
            stock_ul=sbstock_ul; % A COMMON NAME FOR upper limits of stock for various stages
            stock_ll=sbstock_ll; % A COMMON NAME FOR lower limits of stock for various stages
        elseif j==2
            stock_ul=mbstock_ul;
            stock_ll=mbstock_ll;
        elseif j==3
            stock_ul=dbstock_ul;
            stock_ll=dbstock_ll; 
        elseif j==4
            stock_ul=rbstock_ul;  %retailer
            stock_ll=rbstock_ll;  
        end
        gene=round(rand()*(stock_ul-stock_ll)+stock_ll);% for all cases supply/manu/dist/retail
        x(i,j)=gene; % assigns to corresponding gene
    end
end %  20 chromosomes generated in par_pop

xn=x;

 %chromo
   

tscc=zeros(1,N);%preallocation
    for i=1:N
        rbstock=xn(i,4);%base stock of retailer given to simulation
        dbstock=xn(i,3);
        mbstock=xn(i,2);
        sbstock=xn(i,1);
         fprintf('supplier= %f\t maufacturer= %f\tdistributor= %f\tretailer= %f\n',sbstock,mbstock,dbstock,rbstock)
        tscc(i)=bp2simu1(sbstock,mbstock,dbstock,rbstock);% calling simulation 
        ft(i)=tscc(i);% function for fitness evaluation
        fit_mem=ft; % fitness of memory positions
    end
     mem=x; % memory initialization
 %%%  mem
    
    %tscc
    
    
   

   
   tmax=600; % Maximum number of iterations
   
   
   for t=1:tmax
       
    num=ceil(N*rand(1,N));
    for i=1:N
        if rand>=AP
            xnew(i,:)=ceil(x(i,:)+fl*rand*(mem(num(i),:)-x(i,:))); % generation of new position for crow i (state 1)
        else
            
                for j=1:pd % generation of new position for crow i (state 2)
                
        if j==1                   
            stock_ul=sbstock_ul; 
            stock_ll=sbstock_ll; 
        elseif j==2
            stock_ul=mbstock_ul;
            stock_ll=mbstock_ll;
        elseif j==3
            stock_ul=dbstock_ul;
            stock_ll=dbstock_ll; 
        elseif j==4
            stock_ul=rbstock_ul;  %retailer
            stock_ll=rbstock_ll;  
        end
        gene=round(rand()*(stock_ul-stock_ll)+stock_ll);% for all cases supply/manu/dist/retail
        xnew(i,j)=gene;
                end
          
        end
        
           
        
    end
    
    xn=xnew;
    
    for i=1:N
        rbstock=xn(i,4);%base stock of retailer given to simulation
        dbstock=xn(i,3);
        mbstock=xn(i,2);
        sbstock=xn(i,1);
        tscc(i)=bp2simu1(sbstock,mbstock,dbstock,rbstock);% calling simulation
        ft(i)=tscc(i);
    end
    
    
    for i=1:N 
      
        if (xnew(i,1)>=sbstock_ll) && (xnew(i,1)<=sbstock_ul) && (xnew(i,2)>=mbstock_ll) && (xnew(i,2)<=mbstock_ul) && (xnew(i,3)>=dbstock_ll) && (xnew(i,3)<=dbstock_ul) && (xnew(i,4)>=rbstock_ll) && (xnew(i,4)<=rbstock_ul)
        x(i,:)=xnew(i,:);
        if ft(i)<fit_mem(i)
            mem(i,:)=xnew(i,:);
            fit_mem(i)=ft(i);
        end
        else
            xnew(i,:)=x(i,:);
    end
   
    end
    
    fprintf('\nFOR ITERATION =%3d\n',t);
    
   mem
       [best, best_X]=min(fit_mem);
       i=best_X;
       Q=mem(i,:);
        fprintf('Best base stock levels\n');
   Q
    fprintf('Best TSCC\n');
       best
       

   
  
 %%%  Z=mean(fit_mem);
 %%%  fprintf('Mean total supply chain cost\n');
 %%%  Z
   
   end
   time=toc;
    
    diary(sprintf('CSA600-4_%s_%d.txt',datestr(now,'yyyy_mm_dd_HH_MM_SS'),randi([1,10000],1)));
    
    
    
    
    
    