%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
for jk = 2
    this_tbl = MetaTable_allTP(MetaTable_allTP.TimePoint == jk,:);  
    new_tbl.Battery = this_tbl.BatPerc(end);
    new_tbl.AllSensDurSec = sum(this_tbl.OverallSensingDurSec);
    new_tbl.AllTelDurSec = sum(this_tbl.Tel_durSec);
    new_tbl.AllChronDurMin = sum(this_tbl.Chronic_mins);
    new_tbl.TimeSinceImplant = this_tbl.AccumulatedTherapyOnTimeSinceImplant(end)
end






