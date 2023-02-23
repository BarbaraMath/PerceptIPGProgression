function f = plot2check(MetaTable)
    f = figure;

    %Plotting Battery Percentage at the last session
    subplot(1,3,1)
    x = MetaTable.BatPerc(end);
    bar(x, 'FaceColor', "#A2142F");
    ylabel('Battery Percentage [%]');
    xticklabels(''); 
    set(gca,'box','off'); set(gca,'FontSize',15)

    %Plotting Total Telemetry & Sensing Duration
    subplot(1,3,2)
    y = [nansum(MetaTable.Tel_durSec)/60  sum(MetaTable.OverallSensingDurSec)/60];
    bar(y, 'FaceColor',"#77AC30")
    ylabel('Duration [min]')
    xticklabels({'Telemetry','Sensing'})
    xtickangle(30)
    set(gca,'box','off'); set(gca,'FontSize',15)

    subplot(1,3,3)
    %Plotting total chronic sensing until last session
    z = (sum(MetaTable.Chronic_mins)/60)/24;
    bar(z,'FaceColor',"#D95319")
    ylabel('Duration [days]')
    xticklabels('Chronic Sensing')
    set(gca,'box','off'); set(gca,'FontSize',15)

    set(f, 'Position',[100 100 1000 300])
end