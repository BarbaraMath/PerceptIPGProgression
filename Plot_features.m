%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
postop = Percept019_MetaAll(Percept019_MetaAll.TimePoint == 1,:);
fu3m = Percept019_MetaAll(Percept019_MetaAll.TimePoint == 2,:);
fu12m = Percept019_MetaAll(Percept019_MetaAll.TimePoint == 3,:);

sensingdur_postop = sum(postop.OverallSensingDuration)/60;
sensingdur_3mfu = sum(fu3m.OverallSensingDuration)/60;
sensingdur_12mfu = sum(fu12m.OverallSensingDuration)/60;
%%
f = figure;
f.Position = [680 770 790 210];

subplot(1,3,1)
bar([postop.BatPerc(end) fu3m.BatPerc(end) fu12m.BatPerc(end)])
set(gca,'XTickLabel',{'PostOp','3mfu','12mfu'});
ylabel('IPG Battery Left [%]');

subplot(1,3,2)
bar([sensingdur_postop/60, sensingdur_3mfu/60, sensingdur_12mfu/60])
set(gca,'XTickLabel',{'PostOp','3mfu','12mfu'});
ylabel('Sensing Duration [h]');

subplot(1,3,3)
bar([(postop.BatPerc(1)-postop.BatPerc(end)) (fu3m.BatPerc(1)-fu3m.BatPerc(end))  (fu12m.BatPerc(1)-fu12m.BatPerc(end))])
set(gca,'XTickLabel',{'PostOp','3mfu','12mfu'});
ylabel({'Battery Reduction' ; 'due to Recording [%]'});
%%
saveas(gca,'Percept019_MetaAll.fig')
saveas(gca,'Percept019_MetaAll.pdf')

%%
for pt = 1:3
    subplot(1,3,pt)
    indstreamdur = (sum(Percept017_MetaAll.IndefiniteStreamingDur(Percept017_MetaAll.TimePoint == pt),'omitnan'))/60^2;
    lfpmontstreamdur = (sum(Percept017_MetaAll.LfpMontageTimeDomainDur(Percept017_MetaAll.TimePoint == pt),'omitnan'))/60^2;
    bstreamdur = (sum(Percept017_MetaAll.BrainSenseLfpDur(Percept017_MetaAll.TimePoint == pt),'omitnan'))/60^2;
    
    bar([indstreamdur, lfpmontstreamdur, bstreamdur])
end



