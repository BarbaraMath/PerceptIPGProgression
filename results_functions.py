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
from scipy import stats

'''
This contains the following functions:
1. get_descriptives
2. get_battery_corrs

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

def get_battery_corrs(directory_Feat, directory_TEED, directory_corrs, saving):

# 1. Get Table with all sums until 12mfu
    all_sums_dfs = pd.DataFrame()

    for filename in os.listdir(directory_Feat):
        if filename.endswith("AvgFeatures.csv"):
            file_path = os.path.join(directory_Feat, filename)
            df = pd.read_csv(file_path, index_col=None)
            df = df.drop('Unnamed: 0', axis = 1)

            Sub_id = filename[0:6]

            fu12m_index = df[df['TimePoint'] == 'FU12M'].index[0]
            mask = df.index < fu12m_index
            sums_until_fu12m = df[mask].sum()

            this_sums = sums_until_fu12m.to_frame().transpose()
            this_sums = this_sums.drop(['FirstBatVal','LastBatVal'], axis = 1)
            this_sums.insert(0, 'SubID', Sub_id)
            this_sums['Battery_12mfu'] = df.loc[fu12m_index,'FirstBatVal']

            all_sums_dfs = pd.concat([all_sums_dfs, this_sums])

# 2. Get Table with Sum TEED
    all_teeds_dfs = pd.DataFrame()

    for filename in os.listdir(directory_TEED):
        if filename.endswith("TEDD.csv"):
            file_path = os.path.join(directory_TEED, filename)
            stim_teed = pd.read_csv(file_path, index_col=None)

            Total_teed = sum(stim_teed['TEDD'])

            this_teed = pd.DataFrame()
            this_teed['SubID'] = stim_teed['SubID'].unique()
            this_teed['TEED'] = Total_teed

            all_teeds_dfs = pd.concat([all_teeds_dfs, this_teed])

# 3. Combine these two and convert to minutes

    corr_df = all_sums_dfs.merge(all_teeds_dfs, on = 'SubID')
    columns_to_divide = ['Telemetry_AllSec', 'TelemDurSumSecRes', 
                         'TelemDurSumSecWard', 'SensDurSumSec']

    for column in columns_to_divide:
        corr_df[f'{column}_div'] = corr_df[column] / 60


# 4. Make plots
    cols_to_corr = ['Telemetry_AllSec_div', 'TelemDurSumSecRes_div',
        'TelemDurSumSecWard_div', 'SensDurSumSec_div',
        'TEED']
    fig, axs = plt.subplots(2, 3, figsize=(15, 10))  # Adjusted the figure size

    correlation_stats = {}

    axs = axs.flatten()

    for i, col in enumerate(cols_to_corr):
        x = pd.to_numeric(corr_df[col], errors='coerce')  # Convert to numeric, handle errors by setting them to NaN
        y = pd.to_numeric(corr_df['Battery_12mfu'], errors='coerce')

        # Scatter plot
        axs[i].scatter(x, y, label='Data')
        stat_res = stats.spearmanr(x,y)
        correlation_stats[col] = {'R': stat_res.correlation, 'p-value': stat_res.pvalue}

        # Fit a polynomial of degree 1 (linear fit)
        coeffs = np.polyfit(x, y, 1)
        line = np.polyval(coeffs, x)

        # Plot least squares line
        axs[i].plot(x, line, color='red', label=f'Fit: R={stat_res[0]:.2f}, p={stat_res[1]:.5f}')

        axs[i].set_title(f'Correlation with {col}')
        axs[i].set_xlabel(col)
        axs[i].set_ylabel('Battery_12mfu')

        axs[i].legend()
        
    plt.tight_layout()  # Adjust layout for better spacing
    plt.show()

# 5. Conditional Savings
    if saving == 1:
        corr_df.to_csv(os.path.join(
            directory_corrs, 'Corr_df.csv' 
        ), index = None)

        plt.savefig(os.path.join(
              directory_corrs, 'Scatters_corrs'
         ), dpi = 300)
        
        with open(os.path.join(
                directory_corrs,
                f'Stat_results.pkl'
            ), "wb") as file:
                pickle.dump(correlation_stats, file)


    return corr_df, correlation_stats