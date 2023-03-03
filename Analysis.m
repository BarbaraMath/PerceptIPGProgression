%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

codedir = 'T:\Dokumente\PROJECTS\BATTERY_LIFE\PerceptBatteryLife'; addpath(string(codedir));
drive_dir =  'C:\Users\mathiopv\OneDrive - Charité - Universitätsmedizin Berlin\BATTERY_LIFE';

%% 

mat = readtable('TEED.xlsx');

[h,p] = ttest2(mat.TEED(mat.SenSight == 1), mat.TEED(mat.SenSight == 0))


mat.TelSur_scaled = mat.TelSurSec_u12mfu/200;


scatter(mat.TEED, mat.Battery, mat.TelSur_scaled, mat.SenSight,'filled');
colormap winter
ylabel('IPG Battery [%]')
xlabel('TEED [mJ/s]')
lsline
[rho,p] = corr(mat.TEED, mat.Battery, 'type','Spearman', 'rows','complete')
title('Spearman rho = -0.86, p < 0.001')
sigtitle('TEED x IPG Battery at 12mfu')

saveas(gca,'TEED_Batt1.fig')
saveas(gca,'TEED_Batt1.jpg')

%%
tbl = table;
tbl.var1 = sum(MetaTable_allTP.Chronic_mins);
tbl.var2 = sum(MetaTable_allTP.OverallSensingDurSec);
tbl.var3 = nansum(MetaTable_allTP.Tel_durSec);



