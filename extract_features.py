import os
import glob
import json
from datetime import datetime 
import numpy as np
import math
import re
import pickle

'''
This contains the following functions:
1. ectract_MetaTable
2. extract_StimPars
3. calculate_TEDD
4. extract_chronic_nonDups
'''

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
        print(f'{json_fileName}: Done!')

    MetaTable_All_FineName = f'{subID}_MetaTable_{os.path.basename(json_path)}.json'

    with open(os.path.join(
    os.path.dirname(json_path), MetaTable_All_FineName
    ), 'w') as file:
        json.dump(MetaTable_All, file)


def extract_StimPars(data, ElectrodeType):
    electrode_neg = 0
    stim_pars_dict = []

    for hemi in np.arange(2): #range(len(data['Groups']['Initial'][0]['ProgramSettings']['SensingChannel'])):

        for group in range(len(data['Groups']['Initial'])): #loop through the groups 
            if data['Groups']['Initial'][group]['ActiveGroup'] == True:
                activeGroupidx = group
                ActGroup_Id = data['Groups']['Initial'][activeGroupidx]['GroupId'] #Active Group Name
                print(f'Active Group Idx is: {activeGroupidx}')

#####################################################################################################################
###############################################  3389  ##############################################################
#####################################################################################################################
                if ElectrodeType == '3389':

                    if 'SensingChannel' in data['Groups']['Initial'][activeGroupidx]['ProgramSettings']:
                        this_Hemi = data['Groups']['Initial'][activeGroupidx]['ProgramSettings']['SensingChannel'][hemi]['HemisphereLocation'] #Which Hemisphere?
                        this_contact_Id = data['Groups']['Initial'][activeGroupidx]['ProgramSettings']['SensingChannel'][hemi]['ElectrodeState'][electrode_neg]['Electrode'] #Which contact?
                        this_contact_N = re.findall(r'\d+', data['Groups']['Initial'][activeGroupidx]['ProgramSettings']['SensingChannel'][hemi]['ElectrodeState'][electrode_neg]['Electrode'])[0]
                        this_amp = data['Groups']['Initial'][activeGroupidx]['ProgramSettings']['SensingChannel'][hemi]['ElectrodeState'][electrode_neg]['ElectrodeAmplitudeInMilliAmps'] #Amplitude
                        this_freq = data['Groups']['Initial'][activeGroupidx]['ProgramSettings']['SensingChannel'][hemi]['RateInHertz'] #Frequency
                        this_pw = data['Groups']['Initial'][activeGroupidx]['ProgramSettings']['SensingChannel'][hemi]['PulseWidthInMicroSecond'] #PulseWidth

                    else:
                        index = None
                        this_Hemi = list(data['Groups']['Initial'][activeGroupidx]['ProgramSettings'].keys())[hemi+1]
                        for i, dictionary in enumerate(data['Groups']['Initial'][activeGroupidx]['ProgramSettings'][this_Hemi]['Programs'][0]['ElectrodeState']):
                            if 'Negative' in dictionary['ElectrodeStateResult']:
                                index = i
                                break
                        this_contact_Id = data['Groups']['Initial'][activeGroupidx]['ProgramSettings'][this_Hemi]['Programs'][0]['ElectrodeState'][index]['Electrode'] #Which contact?
                        this_contact_N = this_contact_Id.split('.')[-1]
                        this_amp = data['Groups']['Initial'][activeGroupidx]['ProgramSettings'][this_Hemi]['Programs'][0]['ElectrodeState'][index]['ElectrodeAmplitudeInMilliAmps']
                        this_freq = data['Groups']['Initial'][activeGroupidx]['ProgramSettings'][this_Hemi]['Programs'][0]['RateInHertz']
                        this_pw = data['Groups']['Initial'][activeGroupidx]['ProgramSettings'][this_Hemi]['Programs'][0]['PulseWidthInMicroSecond']
                    print(f'Active Group in Hemi {this_Hemi} is: {ActGroup_Id}')
                    print(f'Contact {this_contact_N}: {this_amp}mA, {this_freq}Hz, {this_pw}mu')

#####################################################################################################################
#############################################  SENSIGHT  ############################################################
#####################################################################################################################

                if ElectrodeType == 'SenSight':

                    if 'SensingChannel' in data['Groups']['Initial'][activeGroupidx]['ProgramSettings']:
                        this_Hemi = data['Groups']['Initial'][activeGroupidx]['ProgramSettings']['SensingChannel'][hemi]['HemisphereLocation']
                        this_contact_Id = []
                        this_contact_N = []
                        this_amp = []
                        for i, dictionary in enumerate(data['Groups']['Initial'][0]['ProgramSettings']['SensingChannel'][hemi]['ElectrodeState'][:-1]):
                            this_segment = data['Groups']['Initial'][activeGroupidx]['ProgramSettings']['SensingChannel'][hemi]['ElectrodeState'][i]['Electrode']
                            this_seg = this_segment.split('_')[-1]
                            this_mA = data['Groups']['Initial'][activeGroupidx]['ProgramSettings']['SensingChannel'][hemi]['ElectrodeState'][i]['ElectrodeAmplitudeInMilliAmps']

                            this_contact_Id.append(this_segment)
                            this_contact_N.append(this_seg)
                            this_amp.append(this_mA)
                        this_freq = data['Groups']['Initial'][0]['ProgramSettings']['SensingChannel'][hemi]['RateInHertz']
                        this_pw = data['Groups']['Initial'][0]['ProgramSettings']['SensingChannel'][hemi]['PulseWidthInMicroSecond']

                    else:
                        this_Hemi = list(data['Groups']['Initial'][activeGroupidx]['ProgramSettings'].keys())[hemi+1]
                        this_contact_Id = []
                        this_contact_N = []
                        this_amp = []
            
                        for i, dictionary in enumerate(data['Groups']['Initial'][activeGroupidx]['ProgramSettings'][this_Hemi]['Programs'][0]['ElectrodeState'][:-1]):
                            this_segment = data['Groups']['Initial'][activeGroupidx]['ProgramSettings'][this_Hemi]['Programs'][0]['ElectrodeState'][i]['Electrode']
                            this_seg = this_segment.split('_')[-1]
                            this_mA = data['Groups']['Initial'][activeGroupidx]['ProgramSettings'][this_Hemi]['Programs'][0]['ElectrodeState'][i]['ElectrodeAmplitudeInMilliAmps']

                            this_contact_Id.append(this_segment)
                            this_contact_N.append(this_seg)
                            this_amp.append(this_mA)


    
                        this_freq = data['Groups']['Initial'][activeGroupidx]['ProgramSettings'][this_Hemi]['Programs'][0]['RateInHertz']
                        this_pw = data['Groups']['Initial'][activeGroupidx]['ProgramSettings'][this_Hemi]['Programs'][0]['PulseWidthInMicroSecond']

#####################################################################################################################
####################################### IMPEDANCE FOR ALL ###########################################################

                impdsCurrent = data['Impedance'][0]['TestCurrentMA']
                impedance = []
                for contact in range(len(data['Impedance'][0]['Hemisphere'][hemi]['SessionImpedance']['Monopolar'])):
                    
                    impedance_contact = data['Impedance'][0]['Hemisphere'][hemi]['SessionImpedance']['Monopolar'][contact]['Electrode2']
                    
                    if impedance_contact in this_contact_Id:
                        this_impd = data['Impedance'][0]['Hemisphere'][hemi]['SessionImpedance']['Monopolar'][contact]['ResultValue']
                        impedance.append(this_impd)

                        print(f'Impedance of Contact {impedance_contact} is {impedance}\n')

### MAKE DICTIONARY WITH PARAMETERS
        this_stim_pars_dict = {
        'Hemi': this_Hemi,
        'Group_ID': ActGroup_Id,
        'Contact': this_contact_N,
        'Amplitude': this_amp,
        'Frequency': this_freq,
        'Pulsewidth': this_pw,
        'ImpdsCurrent': impdsCurrent,
        'ImpdsValue': impedance
        
        }

        stim_pars_dict.append(this_stim_pars_dict)
        
    return stim_pars_dict


def calculate_TEDD(stim_dat, ElectrodeType):
    
    freq_L = stim_dat[0]['Frequency']
    pulsw_L = stim_dat[0]['Pulsewidth']
    freq_R = stim_dat[1]['Frequency']
    pulsw_R = stim_dat[1]['Pulsewidth']

    if ElectrodeType == '3389':

        #LEFT HEMISPHERE:
        current_A_L = stim_dat[0]['Amplitude'] / 1000
        impds_L = stim_dat[0]['ImpdsValue'][0]
        voltage_L = current_A_L*impds_L

        TEED_L = ((voltage_L**2)*freq_L*pulsw_L)/impds_L #in Joules per second

        #RIGHT HEMISPHERE:
        current_A_R = stim_dat[1]['Amplitude'] / 1000
        impds_R = stim_dat[1]['ImpdsValue'][0]
        voltage_R = current_A_R*impds_R

        TEED_R = ((voltage_R**2)*freq_R*pulsw_R)/impds_R #in Joules per second

    if ElectrodeType == 'SenSight':
        # LEFT HEMISPHERE:
        current_A_L = [x/1000 for x in stim_dat[0]['Amplitude']]
        impds_L = stim_dat[0]['ImpdsValue']
        voltage_L = [a * b for a, b in zip(current_A_L, impds_L)]

        all_TEEDs_L = []

        for seg in range(len(voltage_L)):
            TEED_seg_L = ((voltage_L[seg]**2) * freq_L * pulsw_L) / impds_L[seg]

            all_TEEDs_L.append(TEED_seg_L)
        TEED_L = sum(all_TEEDs_L)

        # RIGHT HEMISPHERE:
        current_A_R = [x/1000 for x in stim_dat[1]['Amplitude']]
        impds_R = stim_dat[1]['ImpdsValue']
        voltage_R = [a * b for a, b in zip(current_A_R, impds_R)]

        all_TEEDs_R = []

        for seg in range(len(voltage_R)):
            TEED_seg_R = ((voltage_R[seg]**2) * freq_R * pulsw_R) / impds_R[seg]

            all_TEEDs_R.append(TEED_seg_R)
        TEED_R = sum(all_TEEDs_R)

    
    return voltage_L, TEED_L, voltage_R, TEED_R

def extract_chronic_nonDups(SubID, directory_of_all):
    all_chronics = []

    for item in os.listdir(directory_of_all): #find all files in each patient directory in S drive
        item_path = os.path.join(directory_of_all, item) #define the directory e.g. the folder 'Beelitz'
        
        if os.path.isdir(item_path): #if this is a folder
            all_json_files = glob.glob(os.path.join(item_path, '*.json')) #find all json files within the folder
            
            for file in all_json_files: #loop through each json file
                with open(file) as file: #and load it
                    data = json.load(file)
                #check if there is chronic data in it    
                if 'DiagnosticData' in data and 'LFPTrendLogs' in data['DiagnosticData'] and 'HemisphereLocationDef.Right' in data['DiagnosticData']['LFPTrendLogs']:
                    for key, value in data['DiagnosticData']['LFPTrendLogs']['HemisphereLocationDef.Right'].items():
                        # key is date
                        chronic_dict = data['DiagnosticData']['LFPTrendLogs']['HemisphereLocationDef.Right'][key]
                        for i in range(len(chronic_dict)):
                            chronic_date = chronic_dict[i]['DateTime']
                            all_chronics.append(chronic_date)
                            
    non_dups_chronics = np.sort(np.unique(all_chronics))

    diff = len(all_chronics) - len(non_dups_chronics)
    perc_diff = (diff/len(all_chronics)) * 100

    print(f'Total N of chronic entries: {len(all_chronics)}')
    print(f'From those {diff} were duplicates, i.e. {np.around(perc_diff, decimals = 2)}%')
    print(f'Total N of correct entries: {len(non_dups_chronics)}')

    fName = f'{SubID}_NonDupsChronics.pkl'
    dups_dir = 'S:\\AG\\AG-Bewegungsstoerungen-II\\LFP\\PROJECTS\\BATTERY\\NonDups'
    with open(os.path.join(dups_dir, fName), 'wb') as file:
        pickle.dump(non_dups_chronics, file)
        
    return non_dups_chronics