clear all
clc
format shortG

%% Determine Incident Data Size
run_time = 2;
cutoff_time = 0.08;
incident_time = run_time - cutoff_time; %incident run time in nanosecond
timestep_size = 2; %fs
dump_interval = 20; %dump every this interval
run_timestep = incident_time/(timestep_size*10^-6);
data_cutoff = round(run_timestep/dump_interval)+2;

liqslab= 75;
total_length = 300;
box_length = liqslab+(total_length-liqslab)/2;
box_width = 200;

%%
dir = 'Downloads\';
myfilename = 'tester.txt';
path = strcat(dir,myfilename);
opts = detectImportOptions(path,'FileType','text','Range',"A:B");
mydata = readtable(path,opts);
mydatanew(:,1)=mydata(:,1);
mydatanew(:,2)=mydata(:,2);
mymat = table2array(mydatanew);

clearvars mydata mydatanew

%%
cutoff_index=find(isnan(mymat(:,2)));
cut_line=cutoff_index(data_cutoff,1);
incidenttmat = mymat(1:cut_line,:);

mymat(find(isnan(mymat(:,2))),:) = [];
incidenttmat(find(isnan(incidenttmat(:,2))),:) = [];
ID = incidenttmat(:,1);
x_inc = incidenttmat(:,2);
x_acc = mymat(:,2);
% clearvars mymat

%%

xlgRight = 70.91 ; 
xplaneRight = xlgRight + 20 ;
xlgLeft = -4.06 ; 
xplaneLeft = xlgLeft - 20 ;

IDvapor = unique(ID,'rows'); %remove ID duplicates
accL = 0;
accR = 0;
incL = 0;
incR = 0;
incacc_data=zeros(length(IDvapor),5);
%%
testerid=find(IDvapor==412);
for i = 1:length(IDvapor)
    xpath_inc = x_inc(find(ID==IDvapor(i)));
    xpath_acc = x_acc(find(ID==IDvapor(i)));

    inc_numberL=0; inc_numberR=0;
    acc_numberL=0; acc_numberR=0;
    xpathlength_inc=length(xpath_inc);
    xpathlength_acc=length(xpath_acc);
    xcrossL=zeros(xpathlength_acc,1);
    xcrossR=xcrossL;
    
    % Right Incident
    for j=1:xpathlength_inc-1
        if xpath_inc(j)>xplaneRight && xpath_inc(j+1)<xplaneRight
           if abs(xpath_inc(j)-xpath_inc(j+1))<290 
                incR = incR + 1
                inc_numberR = inc_numberR+1;
                xcrossR(j)=1;
           end
        end

        % Left Incidence
        if xpath_inc(j)<xplaneLeft && xpath_inc(j+1)>xplaneLeft
           if abs(xpath_inc(j+1)-xpath_inc(j))<290
                incL = incL + 1
                inc_numberL=inc_numberL+1;
                xcrossL(j)=1;
           end
        end
    % Right Accommodation Path
        if xpath_acc(j)>xlgRight && xpath_acc(j+1)<xlgRight
           if abs(xpath_acc(j)-xpath_acc(j+1))<20 
                xcrossR(j)=2;
           end
        end
    
    % Left Accommodation Path
        if xpath_acc(j)<xlgLeft && xpath_acc(j+1)>xlgLeft
           if abs(xpath_acc(j+1)-xpath_acc(j))<290
                xcrossL(j)=2;
           end
        end
    end
        xcrossR(find(xcrossR==0))=[];
        xcrossL(find(xcrossL==0))=[];
    % Right Accommodation
        for k=1:length(xcrossR)-1
            if xcrossR(k)==1 && xcrossR(k+1)==2
                accR = accR + 1
                acc_numberR = acc_numberR + 1;
            end
        end
     % Left Accommodation
        for k=1:length(xcrossL)-1
            if xcrossL(k)==1 && xcrossL(k+1)==2
                    accL = accL +1
                    acc_numberL = acc_numberL + 1;
            end
        end
        
   
    incacc_data(i,1)=IDvapor(i,1);
    incacc_data(i,2)=inc_numberL;
    incacc_data(i,3)=inc_numberR;
    incacc_data(i,4)=acc_numberL;
    incacc_data(i,5)=acc_numberR;
end

inc = incL + incR ;
acc = accL + accR ;
%%
save("C:\Users\wtd54\OneDrive - University of Missouri\Current Simulations\MAC\MAC.400k.0atm.mat");
