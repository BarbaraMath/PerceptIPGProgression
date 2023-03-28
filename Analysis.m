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
[p, observeddifference, effectsize] = permutationTest(telmat(:,1), telmat(:,2), 10000)

set(gca,'box','off')
xticklabels({'3389','SenSight'}); xtickangle(45);
ylabel('Total Ward Telemetry Duration [min]')
set(gca,'FontSize',15)

title('perm test p = 0.148')

saveas(gca,'WardTelemetryElectrodes1.fig')
saveas(gca,'WardTelemetryElectrodes1.jpg')

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

saveas(gca,'TEED_Batt_chron.fig')
saveas(gca,'TEED_Batt_chron.jpg')

%% MANOVA battery ¬ teed * telemetry * chronic
x = [mat.TEED mat.TelDurSecAll_u12mfu/60 mat.TelDurSecWard_u12mfu_Initial/60 mat.OverallSenDurSec_u12mfu/60 mat.ChronicDays_u12mfu]
[d,p,stats] = manova1(x, mat.Battery)

gplotmatrix(x, mat.Battery, mat.SenSight, [], [], 30)

ylabel('IPG Battery [%]')
xlabel('TEED [mJ/s]')
xlabel('Total Telemetry [min]')
xlabel('Ward Telemetry [min]')
xlabel('Sensing Duration [min]')
xlabel('Chronic Sensing [min]')

set(gca,'FontSize',10)


saveas(gca,'BatteryInteractions.fig')
saveas(gca,'BatteryInteractions.jpg')

varnames = {'TEED';'TelDurAll';'TelDurWard';'Chronic'};
bat = mat.Battery;
teed = mat.TEED;
tel_all = mat.TelDurSecAll_u12mfu/60;
sens = mat.OverallSenDurSec_u12mfu/60;
telward = mat.TelDurSecWard_u12mfu_Initial/60;
chron = mat.ChronicMins_u12mfu

anovan(bat, [teed telward sens chron], 'model','interaction','varnames', {'TEED';'TelDurAll';'Sens';'Chronic'}, 'continuous', [1 2 3 4]);

mat.TelDurMinAll_u12mfuMin = mat.TelDurSecAll_u12mfu
mat.OverallSenDurMin_u12mfu = mat.OverallSenDurSec_u12mfu/60
fitlm(mat, 'Battery~TEED * TelDurMinAll_u12mfuMin')
fitlm(mat, 'Battery~OverallSenDurMin_u12mfu')


%% Ward (initial) Telemetry at different timepoints

T = readtable('Avg_Features.xlsx','Sheet','Sheet1');

telward3389 = [T.AllTelDurSecWard(T.TimePoint == 1 & T.SenSight == 0)/60 ...
    T.AllTelDurSecWard(T.TimePoint == 2 & T.SenSight == 0)/60 ...
    T.AllTelDurSecWard(T.TimePoint == 3 & T.SenSight == 0)/60]

telwardSens = [T.AllTelDurSecWard(T.TimePoint == 1 & T.SenSight == 1)/60 ...
    T.AllTelDurSecWard(T.TimePoint == 2 & T.SenSight == 1)/60 ...
    T.AllTelDurSecWard(T.TimePoint == 3 & T.SenSight == 1)/60]

subplot(1,2,1) 
boxplot(telward3389); hold on
for i = 1:numel(telward3389)
    plot(1:3,telward3389,':o', 'color','black')
end
ylim([-20 200])
xticklabels({'PostOp','3mfu','12mfu'})
ylabel('Ward Telemetry Time [min]')
title('Electrode: 3389, N = 7')
set(gca,'FontSize',15)

subplot(1,2,2)
boxplot(telwardSens); hold on
for i = 1:numel(telwardSens)
    plot(1:3,telwardSens,':o', 'color','black')
end
ylim([-20 200])
xticklabels({'PostOp','3mfu','12mfu'})
ylabel('Ward Telemetry Time [min]')
title('Electrode: SenSight, N = 7')
set(gca,'FontSize',15)

[p, observeddifference, effectsize] = permutationTest(telward3389(:,2), telwardSens(:,2), 10000)


saveas(gca,'WardTelemetryAllTP1.fig')
saveas(gca,'WardTelemetryAllTP1.jpg')

