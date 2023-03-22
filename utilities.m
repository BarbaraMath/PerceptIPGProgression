%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

[uniqueA i j] = unique(MetaTable_allTP.Chronic_mins,'first');
indexToDupes = find(not(ismember(1:numel(MetaTable_allTP.Chronic_mins),i)))

%% Concatenate Patients Tables
drive_dir =  'C:\Users\mathiopv\OneDrive - Charité - Universitätsmedizin Berlin\BATTERY_LIFE';

subs_dir = dir('C:\Users\mathiopv\OneDrive - Charité - Universitätsmedizin Berlin\BATTERY_LIFE\results')

for k = 3:length(subs_dir)
    currD = subs_dir(k).name;
    cd([drive_dir,'\results\',currD,'\overview']);
    
    files = dir('sub*ses*.mat');
    N = length(files);
    T = cell(N,1);

    for i = 1:N
        thisfile = files(i).name;
        temp = struct2cell(load(thisfile));
        T{i} = temp{1};
    end

    MetaTable_allTP = vertcat(T{:});
    MetaTable_allTP = sortrows(MetaTable_allTP, [3,11]);
    save('sub-'+string(MetaTable_allTP.SubID{1})+'_allTP.mat', 'MetaTable_allTP');
end


%% Get average features from allTP tables
new_tbl = table;

vec_tp = unique(MetaTable_allTP.TimePoint);

for jk = 1:length(vec_tp)
    
    this_tbl = MetaTable_allTP(MetaTable_allTP.TimePoint == vec_tp(jk),:);  
    
    new_tbl.TimePoint(jk,:) = this_tbl.TimePoint(end);
    new_tbl.Battery(jk,:) = this_tbl.BatPerc(end);
    new_tbl.AllSensDurSec(jk,:) = sum(this_tbl.OverallSensingDurSec,'omitnan');
    new_tbl.AllTelDurSec(jk,:) = sum(this_tbl.Tel_durSec,'omitnan');
    
    new_tbl.AllChronDurMin(jk,:) = sum(this_tbl.Chronic_mins,'omitnan');
    new_tbl.TimeSinceImplant(jk,:) = this_tbl.AccumulatedTherapyOnTimeSinceImplant(end)
    
    new_tbl.AllTelDurSecWard(jk,:) = sum(this_tbl.Tel_durSec(this_tbl.Wardcare == 1),'omitnan');

end

%% Find first 12mfu session: Battery life, time after surgery, chronic sensing, overall sensing, teldursec

tbl = table;
tbl.ChronicMins_u12mfu = sum(MetaTable_allTP.Chronic_mins, 'omitnan');
tbl.OverallSenDurSec_u12mfu = sum(MetaTable_allTP.OverallSensingDurSec, 'omitnan');
tbl.TelDurSecAll_u12mfu = sum(MetaTable_allTP.Tel_durSec, 'omitnan');
tbl.TelDurSecWard_u12mfu = sum(MetaTable_allTP.Tel_durSec(MetaTable_allTP.Wardcare == 1), 'omitnan')




















