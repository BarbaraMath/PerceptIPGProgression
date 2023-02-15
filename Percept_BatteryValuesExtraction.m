%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('T:\Dokumente\PROJECTS\BATTERY_LIFE\PerceptBatteryLife');
%% Import one json file
%modalities = {'LfpMontageTimeDomain', 'IndefiniteStreaming', 'BrainSenseLfp'};
jsonname = 'Report_Json_Session_Report_20200610T093026.json';
datajson = fileread(jsonname);
data = jsondecode(datajson);

%%

myjsonfiles = dir('Report*.json');

%myjson = 'Report_Json_Session_Report_20220328T145106.json';
subID = 'Percept_Sub005';

prompt = 'Insert Time Point (1,2,3,4,5):'; 
time_point = input(prompt);
%1 = postop, 2 = 3mfu, 3 = 12mfu, 4 = beelitz, 5 = ambulant visit;

MetaTable = table;

MetaTable = val_extract(myjsonfiles, subID, time_point, MetaTable)


%% Fix Telemetry Duration
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

%% Quick Chronic Sensing Check
(sum(MetaTable.Chronic_mins)/60)/24

%% Fix Order of rows
MetaTable = sortrows(MetaTable,'SessionStartDate','ascend');
%%
metatable_name = [subID, '_FollowUp_Beelitz_MetaTable.mat']
save(metatable_name, 'MetaTable')

%% Concatenate tables

tableA = load('Percept_Sub015_FollowUp_PostOp_MetaTable.mat');
tableB = load('Percept_Sub015_FollowUp_3mfu_MetaTable.mat');
tableC = load('Percept_Sub015_FollowUp_12mfu_MetaTable.mat');


tableab = outerjoin(tableA.MetaTable,tableB.MetaTable, 'MergeKeys',true);
Percept015_MetaAll = outerjoin(tableab,tableC.MetaTable, 'MergeKeys',true);

save('Percept015_MetaAll.mat','Percept015_MetaAll')


%% Concatenate Patients Tables

% tableab = outerjoin(Percept017_MetaAll, Percept019_MetaAll,'MergeKeys',true)
% table_all = outerjoin(tableab, Percept021_MetaAll, 'MergeKeys',true)
% 
% save('Table_all.mat','table_all')

files = dir('Percept*.mat');
N = length(files);
T = cell(N,1);

for i = 1:N
    thisfile = files(i).name;
    temp = struct2cell(load(thisfile));
    T{i} = temp{1};
end

table_all = vertcat(T{:});

save('Table_all_Beelitz.mat','table_all')

%% Calculate total duration of chronic sensing in Beelitz

[val, ia, ib] = unique(table_all.SubID, 'stable');

table_all.SubCode = ib;
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


















