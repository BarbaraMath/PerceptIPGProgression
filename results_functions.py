import pandas as pd
from matplotlib import pyplot as plt
import glob
from importlib import reload
import extract_features
import os
import numpy as np
import json
import seaborn as sns
import pickle

'''
This contains the following functions:
1. get_descriptives

'''

def get_descriptives(directory, saving):

#1. GET DATAFRAMES FOR ALL
    df_fu0m = pd.DataFrame()
    df_fu3m = pd.DataFrame()
    df_fu12m = pd.DataFrame()

    for filename in os.listdir(directory):
        if filename.endswith("AvgFeatures.csv"):
            file_path = os.path.join(directory, filename)
            df = pd.read_csv(file_path, index_col=None)
            df = df.drop('Unnamed: 0', axis = 1)
            
            subID = filename[0:6]

            # Filter the data for 'FU0M', 'FU3M', and 'FU12M'
            fu0m_data = df[df['TimePoint'] == 'FU0M']
            fu3m_data = df[df['TimePoint'] == 'FU3M']
            fu12m_data = df[df['TimePoint'] == 'FU12M']
            
            fu0m_data.insert(0, 'SubID', subID)
            fu3m_data.insert(0, 'SubID', subID)
            fu12m_data.insert(0, 'SubID', subID)

            df_fu0m = pd.concat([df_fu0m, fu0m_data])
            df_fu3m = pd.concat([df_fu3m, fu3m_data])
            df_fu12m = pd.concat([df_fu12m, fu12m_data])


#2. CALCULATE MEANS AND STDS FOR ALL
    dfs_list = [df_fu0m, df_fu3m, df_fu12m]

    names = ['FU0M','FU3M','FU12M']

    for k in range(len(dfs_list)):
        this_df = dfs_list[k]

        # Calculate the means for all columns
        means = this_df.mean()
        stds = this_df.std()
        '''
        # Divide 'Telemetry_AllSec' and 'TelemDurSecRes' by 60*2 and round to 2 decimal places
        means['Telemetry_AllSec'] = (means['Telemetry_AllSec'] /  3600)
        means['TelemDurSumSecRes'] = (means['TelemDurSumSecRes'] /  3600)
        means['TelemDurSumSecWard'] = (means['TelemDurSumSecWard'] /  3600)
        means['SensDurSumSec'] = (means['SensDurSumSec'] / 3600)

        # Divide 'Telemetry_AllSec' and 'TelemDurSecRes' by 60*2 and round to 2 decimal places
        stds['Telemetry_AllSec'] = (stds['Telemetry_AllSec'] /  3600)
        stds['TelemDurSumSecRes'] = (stds['TelemDurSumSecRes'] /  3600)
        stds['TelemDurSumSecWard'] = (stds['TelemDurSumSecWard'] /  3600)
        stds['SensDurSumSec'] = (stds['SensDurSumSec'] / 3600)
        
        print(f'Means/STDS of values in {names[k]}')
        print(means.round(2))
        print('//')
        print(stds.round(2))
        '''
        means_dict = means.to_dict()
        stds_dict = stds.to_dict()

    if saving == 1:
        with open(os.path.join(
                directory,
                f'Means_{names[k]}.pkl'
            ), "wb") as file:
                pickle.dump(means_dict, file)
                
        with open(os.path.join(
                directory,
                f'STDs_{names[k]}.pkl'
            ), "wb") as file:
                pickle.dump(stds_dict, file)

#3. CREATE BOXPLOTS
    all_dfs = pd.concat([df_fu0m, df_fu3m, df_fu12m])

    def assign_electrodes(SubID):
        if SubID in ['Sub005', 'Sub007', 'Sub011','Sub012','Sub014','Sub015']:
            return '3389'
        else:
            return 'SenSight'

    all_dfs['Electrode'] = all_dfs['SubID'].apply(assign_electrodes)
    all_dfs['Telemetry_AllMin'] = all_dfs['Telemetry_AllSec']/60
    all_dfs['TelemDurSumSMinRes'] = all_dfs['TelemDurSumSecRes']/60
    all_dfs['TelemDurSumMinWard'] = all_dfs['TelemDurSumSecWard']/60
    all_dfs['SensDurSumMin'] = all_dfs['SensDurSumSec']/60

    if saving == 1:
         all_dfs.to_csv(os.path.join(directory, 'All_FollowUp_dfs.csv'), index= None)


    fig, axs = plt.subplots(2, 2, figsize=(10, 10))
    values_of_int = ['Telemetry_AllMin', 'TelemDurSumSMinRes', 'TelemDurSumMinWard', 'SensDurSumMin']
    for i, ax in enumerate(axs.flatten()):
        sns.boxplot(data=all_dfs, x="TimePoint", y=values_of_int[i], ax=ax)
        sns.stripplot(data=all_dfs, x="TimePoint", y=values_of_int[i], hue='Electrode', size=8,
                        jitter=False, ax=ax)
        for sub in all_dfs['SubID'].unique():
            part_data = all_dfs[all_dfs['SubID'] == sub]
            ax.plot(part_data['TimePoint'], part_data[values_of_int[i]], linestyle=':',
                    color='grey')
    plt.show()

    if saving == 1:
         plt.savefig(os.path.join(
              directory,'Overview_all'
         ), dpi = 300)

    return df_fu0m, df_fu3m, df_fu12m