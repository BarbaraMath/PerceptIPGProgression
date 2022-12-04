

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
SubID = 'Percept_Sub021';

myFiles = dir('sub*.mat');
MetaTable = table();

for i = 1:numel(myFiles)
    
    load(myFiles(i).name);
    
    BatPerc = data.hdr.BatteryInformation.BatteryPercentage;
    BatEstDur = data.hdr.BatteryInformation.EstimatedBatteryLifeMonths;

    ImplantDate = data.hdr.DeviceInformation.Initial.ImplantDate;
    AccumulatedTherapyOnTimeSinceImplant = data.hdr.DeviceInformation.Initial.AccumulatedTherapyOnTimeSinceImplant;
    AccumulatedTherapyOnTimeSinceFollowup = data.hdr.DeviceInformation.Initial.AccumulatedTherapyOnTimeSinceFollowup;
    FinalAccumulatedTherapyOnTimeSinceImplant = data.hdr.DeviceInformation.Final.AccumulatedTherapyOnTimeSinceImplant;
    FinalAccumulatedTherapyOnTimeSinceFollowup = data.hdr.DeviceInformation.Final.AccumulatedTherapyOnTimeSinceFollowup;

    SessionStartDate = data.hdr.EventSummary.SessionStartDate;
    SessionEndDate = data.hdr.EventSummary.SessionEndDate;

    time = data.time{1, 1} - data.time{1, 1}(1);
    RecDurSec = time(end);
        
    MetaTable{i,1} = {SubID};
    MetaTable{i,2} = {ImplantDate};
    MetaTable{i,3} = {SessionStartDate};
    MetaTable{i,4} = {SessionEndDate};
    MetaTable{i,5} = {data.datatype};
    MetaTable{i,6} = RecDurSec;
    MetaTable{i,7} = BatPerc;
    MetaTable{i,8} = BatEstDur;
    MetaTable{i,9} = FinalAccumulatedTherapyOnTimeSinceImplant;
    MetaTable{i,10} = FinalAccumulatedTherapyOnTimeSinceFollowup;
end

MetaTable.Properties.VariableNames = {'SubID','ImplantDate','SessionStartDate','SessionEndDate','Modality','RecDur',...
    'BatPerc','BatEstDur','FinAccTherapySinceImp','FinAccTherapySinceFollowUp'};


%% Do the same in json file

myjson = 'Report_Json_Session_Report_20220829T115527.json';
datajson = fileread(myjson);
data = jsondecode(datajson);

MetaTable = table;

MetaTable.SubID = 'Percept_Sub021';
MetaTable.BatPerc = data.BatteryInformation.BatteryPercentage;
MetaTable.BatEstDur = data.BatteryInformation.EstimatedBatteryLifeMonths;

MetaTable.ImplantDate = data.DeviceInformation.Initial.ImplantDate;
MetaTable.AccumulatedTherapyOnTimeSinceImplant = data.DeviceInformation.Initial.AccumulatedTherapyOnTimeSinceImplant;
MetaTable.AccumulatedTherapyOnTimeSinceFollowup = data.DeviceInformation.Initial.AccumulatedTherapyOnTimeSinceFollowup;
MetaTable.FinalAccumulatedTherapyOnTimeSinceImplant = data.DeviceInformation.Final.AccumulatedTherapyOnTimeSinceImplant;
MetaTable.FinalAccumulatedTherapyOnTimeSinceFollowup = data.DeviceInformation.Final.AccumulatedTherapyOnTimeSinceFollowup;

MetaTable.SessionStartDate = data.EventSummary.SessionStartDate;
MetaTable.SessionEndDate = data.EventSummary.SessionEndDate;

durationsBSTD = []; 
for k = 1:size(data.BrainSenseLfp,1)
    durrec = size(data.BrainSenseLfp(k).LfpData,1)/data.BrainSenseLfp(k).SampleRateInHz; %in seconds
    
    durationsBSTD(k) = durrec;
end

MetaTable.n_BSTD = size(data.BrainSenseLfp,1);
MetaTable.totaljsontimesec = sum(durationsBSTD); %in seconds

toplotBattery = [MetaTable.BatPerc MetaTable.BatEstDur]
bar(toplotBattery)








