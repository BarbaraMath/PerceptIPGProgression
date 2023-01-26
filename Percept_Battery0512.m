%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Do the same in json file
%modalities = {'LfpMontageTimeDomain', 'IndefiniteStreaming', 'BrainSenseLfp'};
jsonname = 'Report_Json_Session_Report_20210701T153957.json';
datajson = fileread(jsonname);
data = jsondecode(datajson);


%%
myjsonfiles = dir('Report*.json');

%myjson = 'Report_Json_Session_Report_20220328T145106.json';
subID = 'Percept_Sub021';
%time_point = 3; %1: postop, 2:3mfu, 3:12mfu

prompt = 'Insert Time Point (1,2 or 3):';
time_point = input(prompt);

MetaTable = table;

for jk = 1:numel(myjsonfiles)
    
datajson = fileread(myjsonfiles(jk).name);
data = jsondecode(datajson);

MetaTable.SubID(jk,:) = {subID};
MetaTable.JsonName(jk,:) = myjsonfiles(jk).name;
MetaTable.TimePoint(jk,:) = time_point;

MetaTable.BatPerc(jk,:) = data.BatteryInformation.BatteryPercentage;
%MetaTable.BatEstDur(jk,:) = data.BatteryInformation.EstimatedBatteryLifeMonths;

MetaTable.ImplantDate(jk,:) = data.DeviceInformation.Initial.ImplantDate;
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

DurList = [MetaTable.LfpMontageTimeDomainDur(jk,:) MetaTable.IndefiniteStreamingDur(jk,:) MetaTable.BrainSenseLfpDur(jk,:)];
    
MetaTable.OverallSensingDuration(jk,:) = sum(DurList, 'omitnan');
    
end

%%
metatable_name = [subID, '_FollowUp_12mfu_MetaTable.mat']
save(metatable_name, 'MetaTable')

%% Concatenate tables

tableA = load('Percept_Sub021_FollowUp_PostOp_MetaTable.mat');
tableB = load('Percept_Sub021_FollowUp_3mfu_MetaTable.mat');
tableC = load('Percept_Sub021_FollowUp_12mfu_MetaTable.mat');


tableab = outerjoin(tableA.MetaTable,tableB.MetaTable, 'MergeKeys',true);
Percept021_MetaAll = outerjoin(tableab,tableC.MetaTable, 'MergeKeys',true);

save('Percept021_MetaAll.mat','Percept021_MetaAll')

%this is a trial comment












