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


%% Calculate total duration of chronic sensing in Beelitz

c
table_all = movevars(table_all, 'SubCode', 'Before', 'JsonName');

chronic_beelitz = table;
chronic_beelitz.SubID = char(unique(table_all.SubID));

for jk = 1:length(unique(table_all.SubCode))
    chronic_beelitz.SubCode{jk} = jk;
    
    chronic_beelitz.TotalChronicDurMins{jk} = sum(table_all.Chronic_mins(table_all.SubCode == jk));
    
end

chronic_beelitz.TotalChronicDurMins = cell2mat(chronic_beelitz.TotalChronicDurMins)

chronic_beelitz.TotalChronicDurHours = chronic_beelitz.TotalChronicDurMins./60;
chronic_beelitz.TotalChronicDurDays = chronic_beelitz.TotalChronicDurHours./24;

chronic_beelitz.BatteryDrainage = (chronic_beelitz.TotalChronicDurDays*3)./365 %(in percentage %)

save('Table_all_Beelitz.mat','table_all')
save('Chronic_Sensing_Beelitz.mat','chronic_beelitz')


















