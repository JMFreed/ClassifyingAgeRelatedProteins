import pandas as pd

'''
data_import_export module
imports .csv files as Pandas dataframe
exports Pandas dataframes as .csv files
'''


def import_csv(filename):
    FILE_PATH = 'C:\\Users\\james.freed\\Documents\\Computer Science MSc\\DISSERTATION\DATA\\Preprocessed data\\'
    dataframe = pd.read_csv(FILE_PATH + filename + '.csv')
    return dataframe


def export_csv(dataframe, filename):
    FILE_PATH = 'C:\\Users\\james.freed\\Documents\\Computer Science MSc\\DISSERTATION\DATA\\Preprocessed data\\'
    dataframe.to_csv(FILE_PATH + filename + '.csv', index=False)
