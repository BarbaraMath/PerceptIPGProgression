%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Figure with Battery Life at each time point
%f = figure;
%f.Position = [680 770 790 210];
T = readtable('Avg_Features.xlsx','Sheet','Sheet1');

[val, ia, ib] = unique(T.SubID, 'stable');

T.SubCode = ib;

save('Avg_Features.mat','T')

for k = 1:length(unique(T.SubCode))
    subplot(4,4,k)
    bar(T.Battery(T.SubCode == k));
    xticklabels({'PostOp','3MFU','12MFU','Beelitz','Ambulant'});
    t = title(string(unique(T.SubID(T.SubCode == k))));
    xtickangle(30);
    ylabel('Battery %');
    set(gca,'FontSize',15)
end

sgtitle('Battery Percentage at Recording Time Points')

saveas(gca, 'Battery_all.fig')
saveas(gca, 'Battery_all.jpg')

%% Figure with total Recording Duration at each time point

for k = 1:length(unique(T.SubCode))
    subplot(4,4,k)
    bar(T.AllSensingDurSec(T.SubCode == k)/60);
    xticklabels({'PostOp','3MFU','12MFU','Beelitz','Ambulant'});
    t = title(string(unique(T.SubID(T.SubCode == k))));
    xtickangle(30);
    ylabel('Sense Dur [min]');
    set(gca,'FontSize',15)
end


sgtitle('Total Sensing Duration at each Time Point')

saveas(gca, 'SensingDur_all.fig')
saveas(gca, 'SensingDur_all.jpg')

%% Figure with total Telemetry Duration in all time points

for k = 1:length(unique(T.SubCode))
    subplot(4,4,k)
    bar(T.AllTelSec(T.SubCode == k)/60/60);
    xticklabels({'PostOp','3MFU','12MFU','Beelitz','Ambulant'});
    t = title(string(unique(T.SubID(T.SubCode == k))));
    xtickangle(30);
    ylabel('Telemetry Duration [h]');
    set(gca,'FontSize',15)
end


sgtitle('Total Telemetry Duration at each Time Point')

saveas(gca, 'TelemetryDur_all.fig')
saveas(gca, 'TelemetryDur_all.jpg')

%% Figure with Telemetry and Sensing Duration for all subjects

T.TelemOhneSens = T.AllTelSec-T.AllSensingDurSec;

for k = 1:length(unique(T.SubCode))
    subplot(4,4,k)
    bar([T.TelemOhneSens(T.SubCode == k)/60^2, T.AllSensingDurSec(T.SubCode == k)/60/60],'stacked');
    xticklabels({'PostOp','3MFU','12MFU','Beelitz','Ambulant'});
    t = title(string(unique(T.SubID(T.SubCode == k))));
    xtickangle(30);
    ylabel('Tel Dur[h]');
    set(gca,'FontSize',15)
end

legend({'Programming','Sensing'})

sgtitle('Relative Telemetry/Sensing at each Time Point')

saveas(gca, 'Telemetry_x_Sensing_all.fig')
saveas(gca, 'Telemetry_x_Sensing_all.jpg')

%% Figure with Chronic Duration at each time point
for k = 1:length(unique(T.SubCode))
    subplot(4,4,k)
    bar(T.AllChronicMins(T.SubCode == k)/60/24);
    xticklabels({'PostOp','3MFU','12MFU','Beelitz','Ambulant'});
    t = title(string(unique(T.SubID(T.SubCode == k))));
    xtickangle(30);
    ylabel('Chronic Sensing [days]');
    set(gca,'FontSize',15)
end

sgtitle('Total Chronic Sensing Duration at each Time Point')

saveas(gca, 'ChronicDur_all.fig')
saveas(gca, 'ChronicDur_all.jpg')

%% Figure with Accumulated time on therapy x Battery life
T.TimesinceImplantDays = (T.TimesinceImplantSec./60^2)/24; %in days

entries = [];
for subid = 1:length(unique(T.SubCode))
    %plot_name = ['h',num2str(subid)];
    scatter(T.TimesinceImplantDays(T.SubCode == subid), T.Battery(T.SubCode == subid), 100, 'filled'); 
    hold on;
    %subid) = extractAfter(unique(table_all.SubID(table_all.SubCode == subid)),'_');
end
xlabel('Time On Therapy since IPG Implantation (days)');
ylabel('IPG Battery [%]')
%legend(entries, 'Interpreter','none');
set(gca,'FontSize',15)

saveas(gca,'AccumTherapy.fig')
saveas(gca,'AccumTherapy.jpg')


%% Plot Beelitz Total Chronic Sensing and Impact
for i = 1:11
    chronic_beelitz.ExtrStr(i,:) = extractAfter(chronic_beelitz.SubID(i,:), '_');
end

subplot(2,1,1)
bar(chronic_beelitz.TotalChronicDurDays,'FaceColor',[0 0.4470 0.7410])
xticklabels(chronic_beelitz.ExtrStr)
xtickangle(20)
set(gca,'TickLabelInterpreter','none')
title('Total Chronic Sensing Duration PostOp & Beelitz')
ylabel('Days')
set(gca,'FontSize',15)

subplot(2,1,2)
bar(chronic_beelitz.BatteryDrainage,'FaceColor', [0.6350 0.0780 0.1840])
xticklabels(chronic_beelitz.ExtrStr)
xtickangle(20)
ylim([0 0.5])
set(gca,'TickLabelInterpreter','none')
title('Impact of Chronic Sensing Duration Postop & Beelitz on IPG Battery')
ylabel('Battery Drainage [%]')
set(gca,'FontSize',15)

saveas(gca,'BeelitzChronic.fig')
saveas(gca,'BeelitzChronic.jpg')

