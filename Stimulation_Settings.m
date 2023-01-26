%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Import one json file
%modalities = {'LfpMontageTimeDomain', 'IndefiniteStreaming', 'BrainSenseLfp'};
jsonname = 'Report_Json_Session_Report_20220318T124233.json';
datajson = fileread(jsonname);
data = jsondecode(datajson);

%% Catch stimulation settings

table_prog = struct2table(data.Groups.Initial,'AsArray',1); %make table with groups and program settings
this_activegroup = find(table_prog.ActiveGroup,1,'first'); %find index in the table with the active group, e.g. 3 (GROUP C)

disp(this_activegroup)
disp(table_prog.GroupId(this_activegroup))
%extract stimulation parameters for active group

%% LEFT: Extract stimulation applied to segments:
segments_tableL = table; %pre-allocate table

%until second-to-last, last one is the case
if isfield(data.Groups.Initial(this_activegroup).ProgramSettings,'LeftHemisphere') == 1
    for m = 1:(size(data.Groups.Initial(this_activegroup).ProgramSettings.LeftHemisphere.Programs.ElectrodeState,1)-1)
        
        segment_name = data.Groups.Initial(this_activegroup).ProgramSettings.LeftHemisphere.Programs.ElectrodeState{m,1}.Electrode;
        segment_amp = data.Groups.Initial(this_activegroup).ProgramSettings.LeftHemisphere.Programs.ElectrodeState{m,1}.ElectrodeAmplitudeInMilliAmps;
        
        freqL = data.Groups.Initial(this_activegroup).ProgramSettings.LeftHemisphere.Programs.RateInHertz;
        plswidthL = data.Groups.Initial(this_activegroup).ProgramSettings.LeftHemisphere.Programs.PulseWidthInMicroSecond;

        segments_tableL.Segment_Name{m} = segment_name;
        segments_tableL.Segment_Amp{m} = segment_amp;
    end
    
else
    for m = 1:(size(data.Groups.Initial.ProgramSettings(this_activegroup).SensingChannel(1).ElectrodeState,1)-1)
        segment_name = data.Groups.Initial.ProgramSettings(this_activegroup).SensingChannel(1).ElectrodeState{m,1}.Electrode;
        segment_amp = data.Groups.Initial.ProgramSettings(this_activegroup).SensingChannel(1).ElectrodeState{m,1}.ElectrodeAmplitudeInMilliAmps;
        
        freqL = data.Groups.Initial.ProgramSettings(this_activegroup).SensingChannel.RateInHertz;
        plswidthL = data.Groups.Initial.ProgramSettings(this_activegroup).SensingChannel.PulseWidthInMicroSecond;
        
        segments_tableL.Segment_Name{m} = segment_name;
        segments_tableL.Segment_Amp{m} = segment_amp;
        
    end
end

%Impedances
segments_tableL.Segment_Amp = cell2mat(segments_tableL.Segment_Amp);%convert amplitudes to normal numbers because whatever
segments_tableL.Hemisphere = repmat('L',1, size(segments_tableL,1))';
segments_tableL = movevars(segments_tableL, 'Hemisphere', 'Before', 'Segment_Name');
disp(segments_tableL)
impedancesL = struct2table(data.Impedance.Hemisphere(1).SessionImpedance.Monopolar) %impedances in new table for convenience
[C, ia, ib] = intersect(impedancesL.Electrode2,segments_tableL.Segment_Name); %select impedances of active contacts only
disp(ia)
segments_tableL.Segments_impds = impedancesL.ResultValue(sort(ia)) %add impedances to table

%Frequency-Pulsewidth
segments_tableL.Frequency = repelem(freqL,size(segments_tableL,1))';
segments_tableL.PulseWidth = repelem(plswidthL,size(segments_tableL,1))';

%Transform ampere to voltage
segments_tableL.Voltage = (segments_tableL.Segment_Amp./1000).*segments_tableL.Segments_impds

%Calculate energy delivered per second (in micro-Joules)
segments_tableL.ED_segment = ((segments_tableL.Voltage.^2).*segments_tableL.PulseWidth.*segments_tableL.Frequency)./segments_tableL.Segments_impds

%sum(segments_tableL.ED_segment)

%% RIGHT Hemisphere

segments_tableR = table;
if isfield(data.Groups.Initial(this_activegroup).ProgramSettings,'RightHemisphere') == 1
    for m = 1:(size(data.Groups.Initial(this_activegroup).ProgramSettings.RightHemisphere.Programs.ElectrodeState,1)-1)
        
        segment_name = data.Groups.Initial(this_activegroup).ProgramSettings.RightHemisphere.Programs.ElectrodeState{m,1}.Electrode;
        segment_amp = data.Groups.Initial(this_activegroup).ProgramSettings.RightHemisphere.Programs.ElectrodeState{m,1}.ElectrodeAmplitudeInMilliAmps;
        
        freqR = data.Groups.Initial(this_activegroup).ProgramSettings.RightHemisphere.Programs.RateInHertz;
        plswidthR = data.Groups.Initial(this_activegroup).ProgramSettings.RightHemisphere.Programs.PulseWidthInMicroSecond;

        segments_tableR.Segment_Name{m} = segment_name;
        segments_tableR.Segment_Amp{m} = segment_amp;
    end
    
else
    for m = 1:(size(data.Groups.Initial.ProgramSettings.SensingChannel(2).ElectrodeState,1)-1)
        segment_name = data.Groups.Initial.ProgramSettings(this_activegroup).SensingChannel(2).ElectrodeState{m,1}.Electrode;
        segment_amp = data.Groups.Initial.ProgramSettings(this_activegroup).SensingChannel(2).ElectrodeState{m,1}.ElectrodeAmplitudeInMilliAmps;
        
        freqR = data.Groups.Initial.ProgramSettings(this_activegroup).SensingChannel.RateInHertz;
        plswidthR = data.Groups.Initial.ProgramSettings(this_activegroup).SensingChannel.PulseWidthInMicroSecond;
        
        segments_tableR.Segment_Name{m} = segment_name;
        segments_tableR.Segment_Amp{m} = segment_amp;
        
    end
end

segments_tableR.Segment_Amp = cell2mat(segments_tableR.Segment_Amp);
segments_tableR.Hemisphere = repmat('R',1, size(segments_tableR,1))';
segments_tableR = movevars(segments_tableR, 'Hemisphere', 'Before', 'Segment_Name');
disp(segments_tableR)

impedancesR = struct2table(data.Impedance.Hemisphere(2).SessionImpedance.Monopolar)
[C, ia, ib] = intersect(impedancesR.Electrode2,segments_tableR.Segment_Name);
disp(ia)
segments_tableR.Segments_impds = impedancesR.ResultValue(sort(ia))

segments_tableR.Frequency = repelem(freqR,size(segments_tableR,1))';
segments_tableR.PulseWidth = repelem(plswidthR,size(segments_tableR,1))';

segments_tableR.Voltage = (segments_tableR.Segment_Amp./1000).*segments_tableR.Segments_impds

segments_tableR.ED_segment = ((segments_tableR.Voltage.^2).*segments_tableR.PulseWidth.*segments_tableR.Frequency)./segments_tableR.Segments_impds

%%

tbl_stim = outerjoin(segments_tableL,segments_tableR,'MergeKeys',1)

save('Sub025_tblStim.mat', 'tbl_stim')

%%

sum(tbl_stim.Segment_Amp(tbl_stim.Hemisphere == 'L'))
sum(tbl_stim.Segment_Amp(tbl_stim.Hemisphere == 'R'))

