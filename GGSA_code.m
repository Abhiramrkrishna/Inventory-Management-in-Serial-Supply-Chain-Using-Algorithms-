% Main function for using GGSA Algorithm


%V:    Velocity
%a:    acceleration
%M:    Mass Ma=Mp=Mi=M
%dim:  number of variables
%N:    number of agents
%X:    position of agrnts
%R:    distance between agents in search space



clear;
clc;
rng('default')
tic

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
dim=4; % number of genes in a agent TO CHANGE J LOOP (GIVEN BELOW) ACCORDINGLY
N=20;  % number of agents
Rnorm=2;
Rpower=1;

X=zeros(N,dim);%preallocation for saving memory


%%%%               Randomized initialization            %%%%



for i=1:N
    for j=1:dim
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
        X(i,j)=round(rand()*(stock_ul-stock_ll)+stock_ll);% for all cases supply/manu/dist/retail
        
    end
end %  N agents generated in par_pop

 %agent
 
xn=X;
 
 V=zeros(N,dim);

tscc=zeros(1,N);%preallocation


%%%%                   Fitness evaluation of agents              %%%%



fitness=zeros(1,N);
    for i=1:N
        rbstock=X(i,4);%base stock of retailer given to simulation
        dbstock=X(i,3);
        mbstock=X(i,2);
        sbstock=X(i,1);
         fprintf('supplier= %f\t manufacturer= %f\tdistributor= %f\tretailer= %f\n',sbstock,mbstock,dbstock,rbstock)
        tscc(i)=bp2simu1(sbstock,mbstock,dbstock,rbstock);% calling simulation 
        fitness(i)=tscc(i);
    end
    fprintf('======Total supply chain costs======================\n');
 %%%   fitness
    %fit
    Fbest=min(fitness);
    max_it=600;%1000 %loop start for 1000 iteration
for iteration=1:max_it %to print iteration no
    
    
    [best, best_X]=min(fitness);
    
    if iteration==1
        Fbest=best;Lbest=X(best_X,:);
    end
    if best<Fbest
        Fbest=best;Lbest=X(best_X,:);
    end
   
    
    %%%%%             Calculation of Mass         %%%%%
    
    
    Fmax=max(fitness);Fmin=min(fitness);Fmean=mean(fitness);
    for i=1:N
    if Fmax==Fmin
        m=ones(N,1);
    else
        best=Fmin;worst=Fmax;
    m(i)=(fitness(i)-worst)/(best-worst);
    end
    
    end
    for i=1:N
    M(i)=m(i)./sum(m);
    end
  %%%  M
    
    
    
    %%%%           Calculation of Gravitational constant    %%%%
    
    
    alfa=4; % Depends on maximum number of itertion
    G0=1000;
    G=G0*exp(-alfa*iteration/max_it);
    
    
    %%%%           Calculation of acceleration     %%%%
    
    
    
    [N,dim]=size(X);
    final_per=100/N; % In the last iteration, only 100/N percent of agents apply force to the others.
    
    
    %%%%              Total force calculation           %%%%
    
   
    kbest=final_per+(1-(iteration/max_it))*(100-final_per); %kbest
    kbest=round(N*kbest/100);
    
    [Ms ds]=sort(M,'descend');
    
    for i=1:N
        E(i,:)=zeros(1,dim);
        for ii=1:kbest
            j=ds(ii);
            if j~=i
                R=norm(X(i,:)-X(j,:),Rnorm); %Euclidian distance 
                for k=1:dim
                    E(i,k)=E(i,k)+rand*(M(j))*((X(j,k)-X(i,k))/(R^Rpower+2^-52));
                end
            end
        end
    end
    
    
   
    for i=1:N
    a(i,:)=E(i,:).*G;  %  acceleration
    end
    
    
    %%%%                   Agent movement           %%%%
    
    C1=(-1*(iteration^3)/(max_it^3))+1;
    C2=(1*(iteration^3)/(max_it^3));
    for i=1:N
        Gbest(i,:)=Lbest;
    end
    
    for i=1:N
    V(i,:)=rand*V(i,:)+C1*a(i,:)+C2*(Gbest(i,:)-X(i,:));
    
    xnew(i,:)=round(X(i,:)+V(i,:)); % New position
    end
    
    for i=1:N
    if (xnew(i,1)>=sbstock_ll) && (xnew(i,1)<=sbstock_ul) && (xnew(i,2)>=mbstock_ll) && (xnew(i,2)<=mbstock_ul) && (xnew(i,3)>=dbstock_ll) && (xnew(i,3)<=dbstock_ul) && (xnew(i,4)>=rbstock_ll) && (xnew(i,4)<=rbstock_ul)
        X(i,:)=xnew(i,:);
    else
        X(i,:)=xn(i,:);
%      for j=1:dim
 %       if j==1                   %supplier
 %           stock_ul=sbstock_ul; % A COMMON NAME FOR upper limits of stock for various stages
 %           stock_ll=sbstock_ll; % A COMMON NAME FOR lower limits of stock for various stages
 %       elseif j==2
 %           stock_ul=mbstock_ul;
  %          stock_ll=mbstock_ll;
  %      elseif j==3
   %         stock_ul=dbstock_ul;
    %        stock_ll=dbstock_ll; 
     %   elseif j==4
      %      stock_ul=rbstock_ul;  %retailer
       %     stock_ll=rbstock_ll;  
       % end
       % xnew(i,j)=round(rand()*(stock_ul-stock_ll)+stock_ll);% for all cases supply/manu/dist/retail
        
     % end
   % X(i,:)=xnew(i,:);
      
    end
       
    end
    for i=1:N
         rbstock=X(i,4);%base stock of retailer given to simulation
        dbstock=X(i,3);
        mbstock=X(i,2);
        sbstock=X(i,1);

        tscc(i)=bp2simu1(sbstock,mbstock,dbstock,rbstock);% calling simulation 
        fitness(i)=tscc(i);
    end
       
        
       fprintf('Iteration number = %3d  \n',iteration);
    disp('======Updated position of agents======================');
    X
    
    
    fprintf('\n ');
    fprintf('Best agent and its Position\n')
  
    Fbest
    Lbest
   
 
    
    
    
  
end
time=toc;
diary(sprintf('GGSA600-4_%s_%d.txt',datestr(now,'yyyy_mm_dd_HH_MM_SS'),randi([1,10000],1)));


