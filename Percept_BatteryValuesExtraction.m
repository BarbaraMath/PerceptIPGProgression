%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

codedir = 'T:\Dokumente\PROJECTS\BATTERY_LIFE\PerceptBatteryLife'; addpath(string(codedir));
drive_dir =  'C:\Users\mathiopv\OneDrive - Charité - Universitätsmedizin Berlin\BATTERY_LIFE';

%% Run Function that extract main features

myjsonfiles = dir('Report*.json');

prompt1 = 'Insert SubID name in format of e.g. 005:';
subID = input(prompt1);

prompt2 = 'Insert Time Point (1,2,3,4,5):'; 
time_point = input(prompt2);
%0 = ward, 1 = postop, 2 = 3mfu, 3 = 12mfu, 4 = beelitz, 5 = ambulant visit;

MetaTable = table;
MetaTable = val_extract(myjsonfiles, subID, time_point, MetaTable)


%% Table Fixes

% Fix Telemetry Duration
MetaTable.t1 = extractBetween(MetaTable.SessionStartDate,'T','Z');
MetaTable.t2 = extractBetween(MetaTable.SessionEndDate,'T','Z');
for k = 1:size(MetaTable,1)
    tel_dur = diff(datetime([MetaTable.t1(k);MetaTable.t2(k)]));
    MetaTable.Tel_dur(k,:)= tel_dur;
    
    [Y, M, D, H, MN, S] = datevec(MetaTable.Tel_dur(k,:));
    tel_durSec = H*3600+MN*60+S;
    MetaTable.Tel_durSec(k,:) = tel_durSec;
end

MetaTable = removevars(MetaTable, {'t1','t2'});

% Fix Order of rows
MetaTable = sortrows(MetaTable,'SessionStartDate','ascend');

%% Plot
f = plot2check(MetaTable);

%% Saving in all different Directories
time_pointName = num2str(time_point);
SubIDName = num2str(subID);
out_folder = ['Sub',SubIDName];

metatable_name = ['sub-',SubIDName,'_ses-EphysFU',time_pointName];
t = sgtitle(metatable_name); set(t,'interpreter','none')

save([drive_dir , '\results\' , out_folder , '\overview\' , metatable_name, '.mat'],'MetaTable')
saveas(gca, [drive_dir , '\figures\' , out_folder , '\overview\' , metatable_name, '.fig'])
saveas(gca, [drive_dir , '\figures\' , out_folder , '\overview\' , metatable_name, '.jpg'])

%% Concatenate tables

tableA = load('Percept_Sub015_FollowUp_PostOp_MetaTable.mat');
tableB = load('Percept_Sub015_FollowUp_3mfu_MetaTable.mat');
tableC = load('Percept_Sub015_FollowUp_12mfu_MetaTable.mat');


tableab = outerjoin(tableA.MetaTable,tableB.MetaTable, 'MergeKeys',true);
Percept015_MetaAll = outerjoin(tableab,tableC.MetaTable, 'MergeKeys',true);

save('Percept015_MetaAll.mat','Percept015_MetaAll')

%% Concatenate one more table to the Overview (e.g. from the Ward FU0)

MetaTable_allTP.Wardcare = repelem(0, size(MetaTable_allTP,1))';
MetaTable_allTP = movevars(MetaTable_allTP, 'Wardcare', 'Before', 'BatPerc');

MetaTable_allTP.SubID = string(MetaTable_allTP.SubID);
MetaTable.SubID = string(MetaTable.SubID);
MetaTable_allTP = outerjoin(MetaTable_allTP,MetaTable, 'MergeKeys',true);

% Fix Order of rows
MetaTable_allTP = sortrows(MetaTable_allTP,'AccumulatedTherapyOnTimeSinceImplant','ascend');

%STEP 1. FIXING: MAKE SURE TO FIX TIMEPOINT OF WARD TO MATCH THE OTHERS
%STEP 2. FIXING: IF A SESSION HAS 0 SENSING TIME, IT IS CONSIDERED WARDCARE
%EVEN IF IT'S FROM DIFFERENT TABLET


MetaTable_allTP.WardCare1 = repelem(NaN, size(MetaTable_allTP,1))'

for i = 1:size(MetaTable_allTP,1)
    if MetaTable_allTP.OverallSensingDurSec(i) == 0 && MetaTable_allTP.Wardcare(i) == 0 && MetaTable_allTP.TimePoint(i) ~=4
        MetaTable_allTP.WardCare1(i) = 1;
    else
        MetaTable_allTP.WardCare1(i) = MetaTable_allTP.Wardcare(i);
    end
end
MetaTable_allTP = movevars(MetaTable_allTP, 'WardCare1', 'Before', 'BatPerc');

save('sub-30_allTP_new.mat','MetaTable_allTP')

%% Distinguish The tables from the MetaTable
sub = 'Sub-30';
tablePostOp = MetaTable_allTP(MetaTable_allTP.TimePoint == 1,:); save([sub,'_ses-EphysFU1.mat'],'tablePostOp')
tableBeel =  MetaTable_allTP(MetaTable_allTP.TimePoint == 4,:); save([sub,'_ses-EphysFU4.mat'],'tableBeel')
table3mfu =  MetaTable_allTP(MetaTable_allTP.TimePoint == 2,:); save([sub,'_ses-EphysFU2.mat'],'table3mfu')
table12mfu =  MetaTable_allTP(MetaTable_allTP.TimePoint == 3,:); save([sub,'_ses-EphysFU3.mat'],'table12mfu')



















