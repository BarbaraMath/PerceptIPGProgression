function MetaTable = val_extract(myjsonfiles, subID, time_point, MetaTable)
    for jk = 1:numel(myjsonfiles)

    %Load json file
    datajson = fileread(myjsonfiles(jk).name);
    data = jsondecode(datajson);

    %Add basic info to new table
    MetaTable.SubID(jk,:) = {subID};
    MetaTable.JsonName(jk,:) = myjsonfiles(jk).name;
    MetaTable.TimePoint(jk,:) = time_point;
    
    if time_point == 0
        MetaTable.Wardcare(jk,:) = 1;


    MetaTable.BatPerc(jk,:) = data.BatteryInformation.BatteryPercentage;
    if sum(strcmp(fieldnames(data.BatteryInformation), 'EstimatedBatteryLifeMonths')) == 1
        MetaTable.BatEstDur(jk,:) = data.BatteryInformation.EstimatedBatteryLifeMonths;
    else
        MetaTable.BatEstDur(jk,:) = NaN;
    end

    MetaTable.ImplantDate(jk,:) = data.DeviceInformation.Initial.ImplantDate; %'2021-06-30T06:50:33Z'; %
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
        MetaTable.n_LMTD(jk,:) = counter;
        MetaTable.LMTD_DurSec(jk,:) = sum(durationslfpmont);
    else
        MetaTable.n_LMTD(jk,:) = 0;
        MetaTable.LMTD_DurSec(jk,:) = NaN;

    end

    %Extract Indefinite Streaming duration in seconds
    if isfield(data, 'IndefiniteStreaming') == 1
        durationsIndStr = [];
        [Ci, iai ici] = unique({data.IndefiniteStreaming.FirstPacketDateTime});
        for lk = 1:length(iai)
            this_ind_str_dur = size(data.IndefiniteStreaming(iai(lk)).TimeDomainData,1)/data.IndefiniteStreaming(iai(lk)).SampleRateInHz;
            durationsIndStr(lk) = this_ind_str_dur;
        end
        MetaTable.n_IS(jk,:) = length(iai);
        MetaTable.IS_DurSec(jk,:) = sum(durationsIndStr);
    else
        MetaTable.n_IS(jk,:) = 0;
        MetaTable.IS_DurSec(jk,:) = NaN;
    end

    %Extract BrainSense Streaming duration in seconds
    if isfield(data, 'BrainSenseLfp') == 1
        durationsBSTD = []; 
        for k = 1:size(data.BrainSenseLfp,1)
            durrec = size(data.BrainSenseLfp(k).LfpData,1)/data.BrainSenseLfp(k).SampleRateInHz; %in seconds

            durationsBSTD(k) = durrec;
        end

        MetaTable.n_BStr(jk,:) = size(data.BrainSenseLfp,1);
        MetaTable.BStr_DurSec(jk,:) = sum(durationsBSTD);
    else
        MetaTable.n_BStr(jk,:) = 0;
        MetaTable.BStr_DurSec(jk,:) = NaN;
    end

    %Extract Chronic Data in minutes
    if isfield(data,'DiagnosticData') == 1
        if sum(strcmp(fieldnames(data.DiagnosticData),'LFPTrendLogs')) == 1
            if sum(strcmp(fieldnames(data.DiagnosticData.LFPTrendLogs), 'HemisphereLocationDef_Right')) == 1
                ls_chronic_mins = [];
                for l = 1:length(fieldnames(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Right))
                    fnames = char(fieldnames(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Right));
                    fname = fnames(l,:);
                    n_logs = length(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Right.(fname));
                    ls_chronic_mins(l) = n_logs*10;
                end
            end
        else
            ls_chronic_mins = 0;
        end
    else
        ls_chronic_mins = 0;
    end

    MetaTable.Chronic_mins(jk,:) = sum(ls_chronic_mins); %in minutes

    DurList = [MetaTable.LMTD_DurSec(jk,:) MetaTable.IS_DurSec(jk,:) MetaTable.BStr_DurSec(jk,:)];
    MetaTable.OverallSensingDurSec(jk,:) = sum(DurList, 'omitnan');
    
%     t1 = extractBetween(MetaTable.SessionStartDate,'T','Z');
%     t2 = extractBetween(MetaTable.SessionEndDate,'T','Z');
%     tel_dur = diff(datetime([t1;t2]));
%     [Y, M, D, H, MN, S] = datevec(tel_dur);
%     tel_durSec = H*3600+MN*60+S;
%     
%     MetaTable.Tel_dur(jk,:) = tel_dur;
%     MetaTable.Tel_durSec(jk,:) = tel_durSec;
    end

end

