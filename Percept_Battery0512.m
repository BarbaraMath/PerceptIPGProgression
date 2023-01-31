%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Import one json file
%modalities = {'LfpMontageTimeDomain', 'IndefiniteStreaming', 'BrainSenseLfp'};
jsonname = 'Report_Json_Session_Report_20200611T151925.json';
datajson = fileread(jsonname);
data = jsondecode(datajson);

%%
myjsonfiles = dir('Report*.json');

%myjson = 'Report_Json_Session_Report_20220328T145106.json';
subID = 'Percept_Sub005';

prompt = 'Insert Time Point (1,2,3,4):'; 
time_point = input(prompt);
%1 = postop, 2 = 3mfu, 3 = 12mfu, 4 = ambulant visit

MetaTable = table;

for jk = 1:numel(myjsonfiles)

%Load json file
datajson = fileread(myjsonfiles(jk).name);
data = jsondecode(datajson);

%Add basic info to new table
MetaTable.SubID(jk,:) = {subID};
MetaTable.JsonName(jk,:) = myjsonfiles(jk).name;
MetaTable.TimePoint(jk,:) = time_point;

MetaTable.BatPerc(jk,:) = data.BatteryInformation.BatteryPercentage;
if sum(strcmp(fieldnames(data.BatteryInformation), 'EstimatedBatteryLifeMonths')) == 1
    MetaTable.BatEstDur(jk,:) = data.BatteryInformation.EstimatedBatteryLifeMonths;
else
    MetaTable.BatEstDur(jk,:) = NaN;
end

MetaTable.ImplantDate(jk,:) = '2020-06-03T15:22:14Z';%data.DeviceInformation.Initial.ImplantDate; %'2020-06-03T15:22:14Z';
MetaTable.AccumulatedTherapyOnTimeSinceImplant(jk,:) = data.DeviceInformation.Initial.AccumulatedTherapyOnTimeSinceImplant;
MetaTable.AccumulatedTherapyOnTimeSinceFollowup(jk,:) = data.DeviceInformation.Initial.AccumulatedTherapyOnTimeSinceFollowup;
MetaTable.FinalAccumulatedTherapyOnTimeSinceImplant(jk,:) = data.DeviceInformation.Final.AccumulatedTherapyOnTimeSinceImplant;
MetaTable.FinalAccumulatedTherapyOnTimeSinceFollowup(jk,:) = data.DeviceInformation.Final.AccumulatedTherapyOnTimeSinceFollowup;

MetaTable.SessionStartDate(jk,:) = {data.SessionDate};
MetaTable.SessionEndDate(jk,:) = {data.SessionEndDate};

% %Extract LfpMontageTimeDomain duration in seconds
if isfield(data, 'LfpMontageTimeDomain') == 1
    durationslfpmont = [];
    counter = 0;
    [C, ia ic] = unique({data.LfpMontageTimeDomain.FirstPacketDateTime});
    
    for ik = 1:length(ia)   
        if size(data.LfpMontageTimeDomain(ia(ik)).TimeDomainData,1) == 5288
            this_lfpmont_dur = size(data.LfpMontageTimeDomain(ia(ik)).TimeDomainData,1)/data.LfpMontageTimeDomain(ia(ik)).SampleRateInHz;
            durationslfpmont(ik) = this_lfpmont_dur;
            counter = counter + 1;
        else
            durationslfpmont(ik) = 0;
            counter = counter + 0;
        end    
    end
    MetaTable.n_LfpMontageTimeDomain(jk,:) = counter;
    MetaTable.LfpMontageTimeDomainDur(jk,:) = sum(durationslfpmont);
else
    MetaTable.n_LfpMontageTimeDomain(jk,:) = 0;
    MetaTable.LfpMontageTimeDomainDur(jk,:) = NaN;
    
end

%Extract Indefinite Streaming duration in seconds
if isfield(data, 'IndefiniteStreaming') == 1
    durationsIndStr = [];
    [Ci, iai ici] = unique({data.IndefiniteStreaming.FirstPacketDateTime});
    for lk = 1:length(iai)
        this_ind_str_dur = size(data.IndefiniteStreaming(iai(lk)).TimeDomainData,1)/data.IndefiniteStreaming(iai(lk)).SampleRateInHz;
        durationsIndStr(lk) = this_ind_str_dur;
    end
    MetaTable.n_IndefiniteStreaming(jk,:) = length(iai);
    MetaTable.IndefiniteStreamingDur(jk,:) = sum(durationsIndStr);
else
    MetaTable.n_IndefiniteStreaming(jk,:) = 0;
    MetaTable.IndefiniteStreamingDur(jk,:) = NaN;
end

%Extract BrainSense Streaming duration in seconds
if isfield(data, 'BrainSenseLfp') == 1
    durationsBSTD = []; 
    for k = 1:size(data.BrainSenseLfp,1)
        durrec = size(data.BrainSenseLfp(k).LfpData,1)/data.BrainSenseLfp(k).SampleRateInHz; %in seconds

        durationsBSTD(k) = durrec;
    end

    MetaTable.n_BrainSenseLfp(jk,:) = size(data.BrainSenseLfp,1);
    MetaTable.BrainSenseLfpDur(jk,:) = sum(durationsBSTD);
else
    MetaTable.n_BrainSenseLfp(jk,:) = 0;
    MetaTable.BrainSenseLfpDur(jk,:) = NaN;
end

%Extract Chronic Data 
if isfield(data,'DiagnosticData') == 1
    if sum(strcmp(fieldnames(data.DiagnosticData),'LFPTrendLogs')) == 1
        if sum(strcmp(fieldnames(data.DiagnosticData.LFPTrendLogs), 'HemisphereLocationDef_Left')) == 1
            ls_chronic_mins = [];
            for l = 1:length(fieldnames(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Left))
                fnames = char(fieldnames(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Left));
                fname = fnames(l,:);
                n_logs = length(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Left.(fname));
                ls_chronic_mins(l) = n_logs*10;
            end
        end
    end
else
    ls_chronic_mins = 0;
end

MetaTable.Chronic_mins(jk,:) = sum(ls_chronic_mins);

DurList = [MetaTable.LfpMontageTimeDomainDur(jk,:) MetaTable.IndefiniteStreamingDur(jk,:) MetaTable.BrainSenseLfpDur(jk,:)];
MetaTable.OverallSensingDuration(jk,:) = sum(DurList, 'omitnan');
    
end

%%
MetaTable = sortrows(MetaTable,'SessionStartDate','ascend');
%%
metatable_name = [subID, '_FollowUp_12mfu_MetaTable.mat']
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

save('Table_all.mat','table_all')




