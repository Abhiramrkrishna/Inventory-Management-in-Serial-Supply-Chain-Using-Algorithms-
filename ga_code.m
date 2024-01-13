clear;
clc;
tic
rng('default')

sumfit=0;
cumprobability=0;
x=0.2;
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
length=4; % number of genes in a chromosome TO CHANGE J LOOP (GIVEN BELOW) ACCORDINGLY
chromo=zeros(40,4);%preallocation for saving memory





for i=1:20
    for j=1:length
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
        chromo(i,j)=gene; % assigns to corresponding gene
    end
end %  20 chromosomes generated in par_pop

 %chromo

tscc=zeros(1,40);%preallocation
    for i=1:20
        rbstock=chromo(i,4);%base stock of retailer given to simulation
        dbstock=chromo(i,3);
        mbstock=chromo(i,2);
        sbstock=chromo(i,1);
         fprintf('supplier= %f\t maufacturer= %f\tdistributor= %f\tretailer= %f\n',sbstock,mbstock,dbstock,rbstock)
        tscc(i)=bp2simu1(sbstock,mbstock,dbstock,rbstock);% calling simulation 
    end
    
    %tscc
for generation=1:600 %600 %loop start for 500 generations
    generation; %to print generation no
    cumprobability=0;sumfit=0;
    fitness=zeros(1,20);%preallocation
    for i=1:20
        fitness(i)=1/(1+tscc(i));
        sumfit=sumfit+fitness(i);
    end
    probability=zeros(1,20);%preallocation
    cumprobab=zeros(1,20);%preallocation
    for i=1:20
        probability(i)=fitness(i)/sumfit;
        cumprobability=cumprobability+probability(i);
        cumprobab(i)=cumprobability;
    end
%   tscc%   fitness%   probability%   cumprobab
    chromo2=zeros(20,4);%preallocation
    for pair=1:10 % loop to select 10 pairs to mating pool
        r1=2*(pair-1)+1; % to select the row1 of the pair
        r2=2*(pair-1)+2;% to select the row2 of the pair
        rn1=rand();
        for i=1:19
                if (rn1<cumprobab(1))
                    chrom1=1;
                    break; % stop further checking
                elseif ((rn1>cumprobab(i)&& rn1<=cumprobab(i+1)) ) 
                    chrom1=i+1;break;% stop further checking
                end
        end
%            chrom1 
        lup = true;
        while (lup==true) % to avoid same values for adjacent chromosomes
                % loop will continue until loop becomes false 
                % ie values are dissimilar
                rn2=rand();
                for i=1:19
                    if (rn2<cumprobab(1))
                        chrom2=1;break;
                    elseif (rn2>cumprobab(i))&& (rn2<=cumprobab(i+1)) 
                        chrom2=i+1;break;
                    end
                end
%                fprintf('%d   %d   %d  %d \n',r1,r2,chrom1,chrom2);
                if (chrom2~=chrom1)
                    lup=false;
                end 
        end % end of while loop
       fprintf('%d   %d \n----------------------\n',chrom1,chrom2);
        chromo2(r1,:)=chromo(chrom1,:) ; % mating pool
        chromo2(r2,:)=chromo(chrom2,:); % mating pool 
    end % end of pair loop
 	%chromo2
   fprintf('--above is mating pool--------------------\n');
    CR=0.7;
    MR=0.10;
    chromo3=zeros(20,4);%preallocation
    for pair= 1:10 %pair loop2
        r1=2*(pair-1)+1;
        r2=2*(pair-1)+2;
        rn3=rand();
        if rn3>CR
            chromo3(r1,:)=chromo2(r1,:);  % intermediate population
            chromo3(r2,:)=chromo2(r2,:); % intermediate population
  %         chromo3
   %        fprintf('--no cross over--------------------\n');
        else
            crosspoint=round(rand()*((length-1)-1)+1);% +1 for starting location for cross over
            for geannum=crosspoint+1:length
                temp=chromo2(r1,geannum);
                chromo2(r1,geannum)=chromo2(r2,geannum);
                chromo2(r2,geannum)=temp;
            end
            chromo3(r1,:)=chromo2(r1,:);
            chromo3(r2,:)=chromo2(r2,:);
            %chromo3
            %fprintf('=======cross over======================\n');
         end % end of rn3 >CR if loop
    end% end of pair loop2
    chromo3
    fprintf('======above value is after cross over======================\n');
    for i=1:20
        for geannum=1:length
             %geannum
            rn4=rand();
            if rn4<=MR
                % fprintf('--before mutation ----%d %d %d %d \n',chromo3(i,1),chromo3(i,2),chromo3(i,3),chromo3(i,4))
                chromo3(i,geannum)=round(chromo3(i,geannum)*(1-x)+chromo3(i,geannum)*2*x*rand());                       %doubt(is it rand()or rn4)
                if geannum==1 %supplier
                    if chromo3(i,geannum)>sbstock_ul;
                        chromo3(i,geannum)=sbstock_ul;
                    elseif chromo3(i,geannum)<sbstock_ll;
                        chromo3(i,geannum)=sbstock_ll;
                    end
                elseif geannum==2 %manufaturer
                    if chromo3(i,geannum)>mbstock_ul;
                        chromo3(i,geannum)=mbstock_ul;
                    elseif chromo3(i,geannum)<mbstock_ll;
                        chromo3(i,geannum)=mbstock_ll;
                    end
                elseif geannum==3 %distributor
                    if chromo3(i,geannum)>dbstock_ul;
                        chromo3(i,geannum)=dbstock_ul;
                    elseif chromo3(i,geannum)<dbstock_ll;
                        chromo3(i,geannum)=dbstock_ll;
                    end
                elseif geannum==4 %retailer
                    if chromo3(i,geannum)>rbstock_ul;
                        chromo3(i,geannum)=rbstock_ul;
                    elseif chromo3(i,geannum)<rbstock_ll;
                        chromo3(i,geannum)=rbstock_ll;
                    end
                end % end of if geannum loop
                
                % fprintf('--mutatuon done----%d %d %d %d \n',chromo3(i,1),chromo3(i,2),chromo3(i,3),chromo3(i,4))
            end % end of if rn<=MR
       end %end of for geannum
    end %end of for i loop
   chromo3
    fprintf('======above value is after mutation======================\n');
       
    for i=1:20
        rbstock=chromo3(i,4);%new base stock of retailer given to simulation
        dbstock=chromo3(i,3);
        mbstock=chromo3(i,2);
        sbstock=chromo3(i,1);
       
        chromo(i+20,4)=chromo3(i,4);chromo(i+20,3)=chromo3(i,3);chromo(i+20,2)=chromo3(i,2);chromo(i+20,1)=chromo3(i,1);                   
        tscc(i+20)=bp2simu1(sbstock,mbstock,dbstock,rbstock);% calling simulation with new base stock
    end
    fprintf('======before sorting is given below======================\n');
    for i=1:40
        fprintf('%4d ',tscc(i));
         if rem(i,5)==0 
          fprintf('\n ');
         end
    end

%fprintf('**********for distinct chromosomes******\n')
 %    [b,m] = unique(chromo, 'rows')%for eliminating duplicate rows
 %    chromo=b;
 %    ak=tscc(m);
 %    tscc=ak;
 %    [y,j]=sort(tscc);%for sorting according to tscc
 %    ch=chromo(j,:); 
 %    chromo=ch;
 %    tscc=y;
%***********bubble sort**********just sorting
   fprintf('\n ');
%------Included later-----------%------------------------------------------
  for i=1:40
       for j=1:40
           if tscc(i)<tscc(j)
               temp=tscc(i);
               tscc(i)=tscc(j);
               tscc(j)=temp;
               tempchrom=chromo(i,:);
               chromo(i,:)=chromo(j,:);
               chromo(j,:)=tempchrom;
           end
       end
  end
  tscc;
   chromo
 fprintf('\n=======================Sorted Chromosomes======================\n');
   %---------included later--------------%------------------------------------  
   %for i=1:39 %sorting loop outer
     %  for j=1:39 %sorting loop inner
      %     if tscc(j)>tscc(j+1)%compares adjacent elements of tscc and arrange in ascending order
       %        temp=tscc(j);% store J th value in temporary location
        %       tscc(j)=tscc(j+1);% %interchange tscc in ascending order
         %      tscc(j+1)=temp;% %replace temporay value in J+1 th position
          %     tempchrom=chromo(j,:);%store J th value in temporary location
           %    chromo(j,:)=chromo(j+1,:);%interchange chromo in ascending order
            %   chromo(j+1,:)=tempchrom;%replace temporay value J+1 th position
           %end
       %end % end of sorting loop inner
   %end % end of sorting loop outer
   
        %for i=1:40 %printing tscc , just 10 nos in a line
         %    fprintf('%4d ',tscc(i));
          %   if rem(i,5)==0 
           %  fprintf('\n ');
           %  end
        %end
% code below is for eliminating some duplicate chromosomes in next
% generation(to be used with bubble sorting)
        chromotep=zeros(40,4);%preallocation
        chromotep(1,:) =chromo(1,:);
       j=1;
       
      for i=2:40
            if ((chromo(i,:)-chromo(i-1,:))~=0)
                j=j+1;
                chromotep(j,:)=chromo(i,:);
            end
      
      end
%        chromotep;
for j=1:40
   
if (chromotep(j,1)>=sbstock_ll) && (chromotep(j,1)<=sbstock_ul) && (chromotep(j,2)>=mbstock_ll) && (chromotep(j,2)<=mbstock_ul) && (chromotep(j,3)>=dbstock_ll) && (chromotep(j,3)<=dbstock_ul) && (chromotep(j,4)>=rbstock_ll) && (chromotep(j,4)<=rbstock_ul)
    chromo=chromotep; 


else
    
    for geannum=1:length
        if geannum==1                   %supplier
            stock_ul=sbstock_ul; 
            stock_ll=sbstock_ll; 
        elseif geannum==2
            stock_ul=mbstock_ul;
            stock_ll=mbstock_ll;
        elseif geannum==3
            stock_ul=dbstock_ul;
            stock_ll=dbstock_ll; 
        elseif geannum==4
            stock_ul=rbstock_ul;  %retailer
            stock_ll=rbstock_ll;  
        end
        gene=round(rand()*(stock_ul-stock_ll)+stock_ll);% for all cases supply/manu/dist/retail
        chromotep(j,geannum)=gene; % assigns to corresponding gene
        
        chromo=chromotep;
        
    end
    

end
end
for i=1:20
        rbstock=chromo(i,4);%base stock of retailer given to simulation
        dbstock=chromo(i,3);
        mbstock=chromo(i,2);
        sbstock=chromo(i,1);
         
        tscc(i)=bp2simu1(sbstock,mbstock,dbstock,rbstock);% calling simulation 
    end
      
  chromo%for printing (changed)
    %tscc
        fprintf('GEN=%3d======after sorting is given above======================\n',generation);
chromo(1,:)
fprintf('Best supply chain cost %f \n',tscc(1));
end% end of generation loop
 t=toc;
 w=t/60;
 diary(sprintf('GA600_4_%s_%d.txt',datestr(now,'yyyy_mm_dd_HH_MM_SS'),randi([1,10000],1)));
 %chromo(1,:)
 %tscc(1)
% fprintf('Besy supply chain cost %f \n',tscc(1));
