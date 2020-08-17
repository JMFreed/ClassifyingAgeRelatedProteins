import pandas as pd
from imblearn.over_sampling import SMOTE


'''
separate_instances
splits dataframe into two class-specific datasets
one dataset contains all age-related proteins, other contains all non-age-related proteins
'''


def separate_instances(dataframe, y):
    df1 = dataframe[dataframe[y.name] != 0]  # age-related
    df2 = dataframe[dataframe[y.name] != 1]  # not age-related
    return df1, df2


'''
create_undersampled_dataset
randomly selects non-age-related proteins without replacement to match number of minority class instances
returns dataframe with equal number of age-related and non-age-related proteins
'''


def create_undersampled_dataset(df_minority, df_majority):
    undersampled_df_majority = df_majority.sample(n=len(df_minority))
    concat_df = pd.concat([df_minority, undersampled_df_majority])
    return concat_df


'''
create_oversampled_dataset
randomly replicates age-related proteins with replacement to match number of majority class instances
returns dataframe with equal number of age-related and non-age-related proteins 
'''


def create_oversampled_dataset(df_minority, df_majority):
    oversampled_df_minority = df_minority.sample(n=len(df_majority), replace=True)
    concat_df = pd.concat([oversampled_df_minority, df_majority])
    return concat_df


'''
apply_smote
uses sklearn.SMOTE function
k-nearest neighbours used to create synthetic minority class instances
returns training set (split into X attributes and y class labels) with equal number of
age-related and non-age-related class instances
'''


def apply_smote(train_set_X, train_set_y):
    sm = SMOTE(k_neighbors=5)
    train_set_X, train_set_y = sm.fit_resample(train_set_X, train_set_y)
    return train_set_X, train_set_y