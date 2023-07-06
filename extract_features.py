import os
import glob
import json
from datetime import datetime 
import numpy as np
import math

def extract_MetaTable(json_path_Subject, json_path, subID, filtered_files):

    MetaTable_All = [] #pre-allocate meta_table for all

    for this_json_file in filtered_files:
        with open(this_json_file) as file:
            # Load the JSON data
            data = json.load(file)

        json_fileName = os.path.basename(this_json_file)
        # Access the data
        '''for key in data:
            print(key)'''
        ### OVERALL INFORMATION
        ImplantDate = data['DeviceInformation']['Initial']['ImplantDate']
        SessionDate = data['SessionDate']
        SessionEndDate = data['SessionEndDate']

        BatteryPercentage = data['BatteryInformation']['BatteryPercentage']

        if 'EstimatedBatteryLifeMonths' in data and data['EstimatedBatteryLifeMonths']:
            EstimatedBatteryLifeMonths = data['BatteryInformation']['EstimatedBatteryLifeMonths']
        else:
            EstimatedBatteryLifeMonths = float("nan")

        AccumulatedTherapyOnTimeSinceImplant_Initial = data['DeviceInformation']['Initial']['AccumulatedTherapyOnTimeSinceImplant']
        AccumulatedTherapyOnTimeSinceFollowup_Initial = data['DeviceInformation']['Initial']['AccumulatedTherapyOnTimeSinceFollowup']

        AccumulatedTherapyOnTimeSinceImplant_Final =  data['DeviceInformation']['Final']['AccumulatedTherapyOnTimeSinceImplant']
        AccumulatedTherapyOnTimeSinceFollowup_Final = data['DeviceInformation']['Final']['AccumulatedTherapyOnTimeSinceFollowup']

        ### LFP MONTAGE TIME DOMAIN (BRAINSENSE SURVEY)
        'LfpMontageTimeDomain' in data == True
        if 'LfpMontageTimeDomain' in data:
            LFPMontTimeStamps = []

            for ch in range(len(data['LfpMontageTimeDomain'])):
                this_lfpmont_tst = data['LfpMontageTimeDomain'][ch]['FirstPacketDateTime']
                LFPMontTimeStamps.append(this_lfpmont_tst)

            lfpmon_n = len(set(LFPMontTimeStamps))
            dur_lfpmon = (5288/250)*lfpmon_n
        else:
            lfpmon_n = 0
            dur_lfpmon = 0

        ### INDEFINITE STREAMING (IS)
        if 'IndefiniteStreaming' in data and data['IndefiniteStreaming'] and len(data['IndefiniteStreaming']) > 0:
            durationsIndStr = []
            unique_dates = set([item['FirstPacketDateTime'] for item in data['IndefiniteStreaming']])
            
            for date in unique_dates:
                filtered_data = [item for item in data['IndefiniteStreaming'] if item['FirstPacketDateTime'] == date]
                this_ind_str_dur = len(filtered_data[0]['TimeDomainData']) / filtered_data[0]['SampleRateInHz']
                durationsIndStr.append(this_ind_str_dur)

            IS_n = len(unique_dates)
            dur_IS = sum(durationsIndStr)
        else:
            IS_n = 0
            dur_IS = 0

        ### BRAINSENSE STREAMING (BStr)
        if 'BrainSenseLfp' in data and data['BrainSenseLfp'] and len(data['BrainSenseLfp']) > 0:
            durationsBSTD = []
            
            for k in range(len(data['BrainSenseLfp'])):
                durrec = len(data['BrainSenseLfp'][k]['LfpData']) / data['BrainSenseLfp'][k]['SampleRateInHz']  # in seconds
                durationsBSTD.append(durrec)

            BStr_n = len(data['BrainSenseLfp'])
            dur_Bstr = sum(durationsBSTD)
        else:
            BStr_n = 0
            dur_Bstr = 0
        
        overallSensingDurSec = dur_lfpmon + dur_IS + dur_Bstr ##Overall Sensing Duration
        
        ##################################################################################
        ##################################################################################
        ##################################################################################
        
        # Convert the strings to datetime objects
        datetime1 = datetime.strptime(SessionDate, "%Y-%m-%dT%H:%M:%SZ")
        
        if 'SessionEndDate' in data and data['SessionEndDate']:
            datetime2 = datetime.strptime(SessionEndDate, "%Y-%m-%dT%H:%M:%SZ")
        else:
            datetime2 = None

        if datetime1.strftime('%H:%M:%S') == '23:00:00':
            if overallSensingDurSec == 0:
                telemetry_durationSec = np.nan
            else: 
                telemetry_durationSec = overallSensingDurSec
        elif datetime2 is None:
                telemetry_durationSec = overallSensingDurSec
        else:
            telemetry_durationSec = (datetime2 - datetime1).total_seconds()        

        if telemetry_durationSec < 0:
            telemetry_durationSec = overallSensingDurSec
        
        if telemetry_durationSec == 0:
            telemetry_durationSec = np.nan

        ##################################################################################
        ##################################################################################
        ##################################################################################

        this_json_MetaTable = {
        'SubID': subID,
        'json_fileName': json_fileName,
        'Con_Reason': os.path.basename(json_path_Subject),

        'ImplantDate': ImplantDate,
        'SessionDate': SessionDate,
        'SessionEndDate': SessionEndDate,

        'BatteryPercentage': BatteryPercentage,
        'EstimatedBatteryLifeMonths': EstimatedBatteryLifeMonths,

        'AccumulatedTherapyOnTimeSinceImplant_Initial': AccumulatedTherapyOnTimeSinceImplant_Initial,
        'AccumulatedTherapyOnTimeSinceFollowup_Initial': AccumulatedTherapyOnTimeSinceFollowup_Initial,

        'AccumulatedTherapyOnTimeSinceImplant_Final':  AccumulatedTherapyOnTimeSinceImplant_Final,
        'AccumulatedTherapyOnTimeSinceFollowup_Final': AccumulatedTherapyOnTimeSinceFollowup_Final,

        'lfpmon_n': lfpmon_n,
        'dur_lfpmon': dur_lfpmon,

        'IS_n': IS_n,
        'dur_IS': dur_IS,

        'BStr_n': BStr_n,
        'dur_Bstr': dur_Bstr,

        'overallSensingDurSec': overallSensingDurSec,
        'telemetry_durationSec': telemetry_durationSec
        
        }

        MetaTable_All.append(this_json_MetaTable)
        

    MetaTable_All_FineName = f'{subID}_MetaTable_{os.path.basename(json_path)}.json'

    with open(os.path.join(
    os.path.dirname(json_path), MetaTable_All_FineName
    ), 'w') as file:
        json.dump(MetaTable_All, file)
    
