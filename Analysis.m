%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

codedir = 'T:\Dokumente\PROJECTS\BATTERY_LIFE\PerceptBatteryLife'; addpath(string(codedir));
drive_dir =  'C:\Users\mathiopv\OneDrive - Charité - Universitätsmedizin Berlin\BATTERY_LIFE';
addpath('T:\Dokumente\CORE_CODE')
%% 

mat = readtable('TEED.xlsx');

[p, observeddifference, effectsize] = permutationTest(mat.TEED(mat.SenSight == 1), mat.TEED(mat.SenSight == 0), 10000)


mat.TelSur_scaled = mat.TelSurSec_u12mfu/200;


scatter(mat.TEED, mat.Battery, mat.TelSur_scaled, mat.SenSight,'filled');
colormap winter
ylabel('IPG Battery [%]')
xlabel('TEED [mJ/s]')
lsline
[rho,p] = corr(mat.TEED, mat.Battery, 'type','Spearman', 'rows','complete')
title('Spearman rho = -0.86, p < 0.001')
sigtitle('TEED x IPG Battery at 12mfu')
set(gca,'FontSize',15)

saveas(gca,'TEED_Batt.fig')
saveas(gca,'TEED_Batt.pdf')
saveas(gca,'TEED_Batt.jpg')


%%
% tbl = table;
% tbl.var1 = sum(MetaTable_allTP.Chronic_mins);
% tbl.var2 = sum(MetaTable_allTP.OverallSensingDurSec);
% tbl.var3 = nansum(MetaTable_allTP.Tel_durSec);
mat.ChronicDays_u12mfu = (mat.ChronicMins_u12mfu/60)/24;
scatter(mat.TEED, mat.Battery, mat.TelSur_scaled, mat.ChronicDays_u12mfu,'filled');
a = colorbar; ylabel(a, 'Chronic Sensing [days]');
ylabel('IPG Battery [%]')
xlabel('TEED [mJ/s]')
lsline

sgtitle('TEED x IPG Battery at 12mfu')
set(gca,'FontSize',15)

saveas(gca,'TEED_Batt1.fig')
saveas(gca,'TEED_Batt1.jpg')

%% LME battery ¬ teed * telemetry * chronic
x = [mat.TEED mat.TelDurSec_u12mfu/60 mat.ChronicDays_u12mfu]
[d,p,stats] = manova1(x,mat.Battery)

gplotmatrix(x, mat.Battery,mat.SenSight)

ylabel('IPG Battery [%]')
xlabel('TEED [mJ/s]')
xlabel('Telemetry [min]')

xlabel('Chronic Sensing [min]')
set(gca,'FontSize',10)
sgtitle('Batter ¬ TEED-Telemetry-Chronic')

saveas(gca,'BatteryInteractions.fig')
saveas(gca,'BatteryInteractions.jpg')








