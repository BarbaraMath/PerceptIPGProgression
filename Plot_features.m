%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Figure with Battery Life at each time point
%f = figure;
%f.Position = [680 770 790 210];

sgtitle('Battery Percentage at Recording Time Points')
%%
%saveas(gca, 'Battery_all.fig')
%saveas(gca, 'Battery_all.jpg')

%% Figure with total Recording Duration at each time point
tbl_recdur = table;

for subidx = 1:length(unique(table_all.SubCode))
    subplot(4,4,subidx)
    this_table = table_all(table_all.SubCode == subidx,:);
    
    time1 = this_table(this_table.TimePoint == 1,:);
    time2 = this_table(this_table.TimePoint == 2,:);
    time3 = this_table(this_table.TimePoint == 3,:);
    
    sensingdur_postop = sum(time1.OverallSensingDuration)/60^2;
    sensingdur_3mfu = sum(time2.OverallSensingDuration)/60^2;
    sensingdur_12mfu = sum(time3.OverallSensingDuration)/60^2;
    
    bar([sensingdur_postop, sensingdur_3mfu, sensingdur_12mfu])
    set(gca,'XTickLabel',{'PostOp','3mfu','12mfu'});
    ylabel('Sensing Duration [h]');
    t = title(this_table.SubID(1));
    set(t,'Interpreter','none')
    
    tbl_recdur{subidx,1} = subidx;
    tbl_recdur{subidx,2} = sensingdur_postop;
    tbl_recdur{subidx,3} = sensingdur_3mfu;
    tbl_recdur{subidx,4} = sensingdur_12mfu;    
end

sgtitle('Total Sensing Duration at each Time Point')

saveas(gca, 'RecordingTime_all.fig')
saveas(gca, 'RecordingTime_all.jpg')

%% Figure with Accumulated time on therapy x Battery life
table_all.AccumTherapyDays = (table_all.AccumulatedTherapyOnTimeSinceImplant./60^2)/24; %in days
entries = [];
for subid = 1:length(unique(table_all.SubCode))
    %plot_name = ['h',num2str(subid)];
    scatter(table_all.AccumTherapyDays(table_all.SubCode == subid), table_all.BatPerc(table_all.SubCode == subid), 100, 'filled'); 
    hold on;
    %subid) = extractAfter(unique(table_all.SubID(table_all.SubCode == subid)),'_');
end
xlabel('Time On Therapy since IPG Implantation (days)');
ylabel('IPG Battery [%]')
legend(entries, 'Interpreter','none');

saveas(gca,'AccumTherapy.fig')
saveas(gca,'AccumTherapy.jpg')


%%
for subidx = 1:length(unique(table_all.SubCode))
    subplot(2,4,subidx)
    this_table = table_all(table_all.SubCode == subidx,:);
    
    time1 = this_table(this_table.TimePoint == 1,:);
    time2 = this_table(this_table.TimePoint == 2,:);
    time3 = this_table(this_table.TimePoint == 3,:);
    
    values = [sum(time1.LfpMontageTimeDomainDur)/60^2 sum(time1.BrainSenseLfpDur)/60^2;...
        sum(time2.LfpMontageTimeDomainDur)/60^2 sum(time2.BrainSenseLfpDur)/60^2;...
        sum(time3.LfpMontageTimeDomainDur)/60^2 sum(time3.BrainSenseLfpDur)/60^2];
    
    bar(sum(time1.LfpMontageTimeDomainDur); ...
        sum(time2.LfpMontageTimeDomainDur);...
        sum(time1.LfpMontageTimeDomainDur))
end

%% Relative recording time i.e. (minutes of streaming / time on therapy) correlated with battery life

dat = readtable('RelRecTime.csv')

for subid = 1:length(unique(dat.SubCode))
    scatter(dat.RatioStreamingTherapy(dat.SubCode == subid), dat.BatPerc(dat.SubCode == subid),'filled')
    hold on
end
xlim([0 8])
xlabel('Sensing [min] / Time since Implantation [days]')
ylabel('Battery Percentage [%]')

f = fit(dat.RatioStreamingTherapy, dat.BatPerc, 'poly1')


saveas(gca,'RelativeStreaming.fig')
saveas(gca,'RelativeStreaming.jpg')

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

