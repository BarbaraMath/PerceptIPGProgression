%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

codedir = 'T:\Dokumente\PROJECTS\BATTERY_LIFE\PerceptBatteryLife'; addpath(string(codedir));
drive_dir =  'C:\Users\mathiopv\OneDrive - Charité - Universitätsmedizin Berlin\BATTERY_LIFE';
addpath('T:\Dokumente\CORE_CODE')
%% 

mat = readtable('TEED.xlsx');

%% Telemetry difference between electrodes

telmat = [mat.TelDurSecWard_u12mfu(mat.SenSight == 0)/60 mat.TelDurSecWard_u12mfu(mat.SenSight == 1)/60]

boxplot(telmat); hold on

for i = 1:numel(telmat)
    plot(1:2,telmat,'o','color','blue')
end
[p, observeddifference, effectsize] = permutationTest(mat.TelDurSecWard_u12mfu(mat.SenSight == 0), mat.TelDurSecWard_u12mfu(mat.SenSight == 1), 10000)

set(gca,'box','off')
xticklabels({'3389','SenSight'}); xtickangle(45);
ylabel('Total Ward Telemetry Duration [min]')
set(gca,'FontSize',15)

title('perm test p = 0.014')

saveas(gca,'WardTelemetryElectrodes.fig')
saveas(gca,'WardTelemetryElectrodes.jpg')

%%

[p, observeddifference, effectsize] = permutationTest(mat.TEED(mat.SenSight == 1), mat.TEED(mat.SenSight == 0), 10000)


mat.TelDur_scaled = mat.TelDurSecAll_u12mfu/200;


scatter(mat.TEED, mat.Battery, mat.TelDur_scaled, mat.SenSight,'filled');
colormap winter
ylabel('IPG Battery [%]')
xlabel('TEED [mJ/s]')
lsline
[rho,p] = corr(mat.TEED, mat.Battery, 'type','Spearman', 'rows','complete')
title('Spearman rho = -0.84, p < 0.001')
set(gca,'FontSize',15)

saveas(gca,'TEED_Batt.fig')
saveas(gca,'TEED_Batt.jpg')


%%
% tbl = table;
% tbl.var1 = sum(MetaTable_allTP.Chronic_mins);
% tbl.var2 = sum(MetaTable_allTP.OverallSensingDurSec);
% tbl.var3 = nansum(MetaTable_allTP.Tel_durSec);
mat.ChronicDays_u12mfu = (mat.ChronicMins_u12mfu/60)/24;
scatter(mat.TEED, mat.Battery, mat.TelDur_scaled, mat.ChronicDays_u12mfu,'filled');
a = colorbar; ylabel(a, 'Chronic Sensing [days]');
ylabel('IPG Battery [%]')
xlabel('TEED [mJ/s]')
lsline

sgtitle('TEED x IPG Battery at 12mfu')
set(gca,'FontSize',15)

saveas(gca,'TEED_Batt1.fig')
saveas(gca,'TEED_Batt1.jpg')

%% LME battery ¬ teed * telemetry * chronic
x = [mat.TEED mat.TelDurSecAll_u12mfu/60 mat.TelDurSecWard_u12mfu/60 mat.ChronicDays_u12mfu]
[d,p,stats] = manova1(x,mat.Battery)

gplotmatrix(x, mat.Battery,mat.SenSight)

ylabel('IPG Battery [%]')
xlabel('TEED [mJ/s]')
xlabel('Total Telemetry [min]')
xlabel('Ward Telemetry [min]')
xlabel('Chronic Sensing [min]')

set(gca,'FontSize',10)
sgtitle('Batter ¬ TEED-Telemetry-Chronic')

saveas(gca,'BatteryInteractions.fig')
saveas(gca,'BatteryInteractions.jpg')


