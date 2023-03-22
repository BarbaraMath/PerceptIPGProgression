%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Script that catches duplicates in chronic data

myjsonfiles = dir('Report*.json');
chronic_dups = table;

prompt2 = 'Insert Time Point (1,2,3,4,5):'; 
time_point = input(prompt2);

for jk = 1:numel(myjsonfiles)

    %Load json file
    datajson = fileread(myjsonfiles(jk).name);
    data = jsondecode(datajson);
    
    chronic_dups.JsonName(jk,:) = myjsonfiles(jk).name;
    chronic_dups.TimePoint(jk,:) = time_point;
    %Extract Chronic Data in minutes
    if isfield(data,'DiagnosticData') == 1
        if sum(strcmp(fieldnames(data.DiagnosticData),'LFPTrendLogs')) == 1
            if sum(strcmp(fieldnames(data.DiagnosticData.LFPTrendLogs), 'HemisphereLocationDef_Right')) == 1
                ls_chronic_mins = [];
                for l = 1:length(fieldnames(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Right))
                    fnames = char(fieldnames(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Right));
                    fname = fnames(l,:);
                    %n_logs = length(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Left.(fname));
                    %ls_chronic_mins(l) = n_logs*10;
                end
            end
        else
            ls_chronic_mins = 0;
            fname = 'NoChronic';
        end
    else
        ls_chronic_mins = 0;
        fname = 'NoChronic';
    end

    chronic_dups.ChronName{jk} = fname; %in minutes
    
   
end

%%

save('ChronicDupsFU3.mat','chronic_dups')