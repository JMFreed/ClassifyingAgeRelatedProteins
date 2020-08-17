import os
import pandas as pd
import matplotlib.pyplot as plt


'''
NHS statistics downloaded from NHS England
used SQL Server to calculate increase in number of annual diagnoses
saved .csv files imported as Pandas dataframes
demonstrates increase in annual diagnoses every year with ageing
'''


FILE_PATH = 'DATA\\Preprocessed data\\NHS Hospital Admissions By Disease\\'
alzheimer_df = pd.read_csv(FILE_PATH + 'Alzheimer disease.csv')
heart_failure_df = pd.read_csv(FILE_PATH + 'Heart failure.csv')
maglignant_neoplasm_df = pd.read_csv(FILE_PATH + 'Malignant neoplasms.csv')
parkinson_df = pd.read_csv(FILE_PATH + 'Parkinson disease.csv')

dfs = {"Alzheimer's disease": alzheimer_df,
       "Heart failure": heart_failure_df,
       "Malignant neoplasms": maglignant_neoplasm_df,
       "Parkinson's disease": parkinson_df}

DIR = '../FIGURES/NHS_diagnosis_stats/'
if not os.path.exists(DIR):
    os.mkdir(DIR)

for key in dfs:
    df_to_plot = dfs[key]
    plt.plot(df_to_plot.iloc[:, 0], df_to_plot.iloc[:, 2], color='y', label='ages 15-59')
    plt.plot(df_to_plot.iloc[:, 0], df_to_plot.iloc[:, 3], color='b', label='ages 60-74')
    plt.plot(df_to_plot.iloc[:, 0], df_to_plot.iloc[:, 4], color='r', label='ages 75+')
    plt.xticks([x for x in range (1998, 2018, 3)], rotation=90)
    plt.ylim(0, max(df_to_plot.iloc[:, :].max(axis=1) * 1.5))
    plt.legend()
    plt.grid()
    plt.ylabel('Number of diagnoses')
    plt.title(str(key))
    plt.savefig(DIR + str(key) + '.png')
    plt.show()
