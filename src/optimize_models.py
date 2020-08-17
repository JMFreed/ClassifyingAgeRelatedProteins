from imblearn.ensemble import BalancedRandomForestClassifier
from sklearn.model_selection import GridSearchCV
import random
import numpy as np
import pandas as pd
from sklearn.tree import DecisionTreeClassifier

from src.sampling import separate_instances

'''
evaluate_model_hyperparameters
randomly splits dataset into segments for 10-fold cross validation
apply GridSearchCV to the training set ONLY using 5-fold internal cross validation
best_estimator_ returned by GridSearchCV evaluated on test set
repeat for all 10-folds of cross validation
repeat n number of times
@params
---------
estimator: model to be optimized using GridSearchCV (DecisionTreeClassifier / BalancedRandomForestClassifier)
dataframe: dataframe to be split into training and test set
cv: number for cross validation (default 10)
n_iter: number of repeats of GridSearchCV
'''


def evaluate_model_hyperparameters(estimator, dataframe, cv=10, n_iter=100):
    # hyperparameter values of DecisionTree classifier to test
    param_grid_dt = [{'max_depth': [5,   10, 20],
                      'min_samples_split': [5, 10, 20, 50],
                      'min_samples_leaf': [2, 5, 10, 20],
                      'ccp_alp      ha': [0.00001, 0.0001]
                      }]

    # hyperparameter values of BalancedRandomForest classifier to test
    param_grid_brf = [{'n_estimators': [100, 200, 500, 1000],
                       'max_features': ['sqrt', 'log2']
                       }]

    # if exists, remove UniprotID column from dataframe
    if 'UniprotID' in dataframe.columns:
        dataframe = dataframe.drop(columns='UniprotID')
    print('Number instances: %d' % dataframe.shape[0])
    # split instances into age-related and not-age-related
    age_related, not_age_related = separate_instances(dataframe, dataframe['AgeRelatedFlag (GenAge)'])
    print('Age-related: %d' % age_related.shape[0])
    print('Non-age-related: %d' % not_age_related.shape[0])

    for iteration in range(n_iter):

        print('Iteration number: %d' % iteration)
        # shuffle instances
        shuffle_a, shuffle_b = age_related.sample(frac=1), not_age_related.sample(frac=1)
        # split dataframes into segments
        subsets_a, subsets_b = np.array_split(shuffle_a, cv), np.array_split(shuffle_b, cv)

        df_a = []
        df_b = []

        # convert numpy arrays back into dataframes
        for i in range(cv):
            df_a.append(pd.DataFrame(subsets_a[i]))
            df_b.append(pd.DataFrame(subsets_b[i]))

        # shuffle datasets in the list
        random.shuffle(df_a)
        random.shuffle(df_b)

        for i in range(cv):
            # create copies of age-related and not age-related dataset segments
            copy_df_a, copy_df_b = df_a.copy(), df_b.copy()
            # create test set by combining one age-related segment and one not-age-related segment
            test_set = pd.concat([copy_df_a[i], copy_df_b[i]])
            # remove segment used as test set from list of subsets
            del (copy_df_a[i])
            del (copy_df_b[i])
            test_set_y = test_set['AgeRelatedFlag (GenAge)']
            test_set = test_set.drop(columns='AgeRelatedFlag (GenAge)')
            test_set_X = test_set.iloc[:, :]
            # merge age-related and non-age-related datasets to form training set
            concat_a, concat_b = pd.concat(copy_df_a), pd.concat(copy_df_b)
            train_set = pd.concat([concat_a, concat_b])
            train_set_y = train_set['AgeRelatedFlag (GenAge)']
            train_set = train_set.drop(columns='AgeRelatedFlag (GenAge)')
            train_set_X = train_set.iloc[:, :]
            # perform 5-fold internal cross validation on training set
            if isinstance(estimator, DecisionTreeClassifier):
                gs = GridSearchCV(estimator=estimator, param_grid=param_grid_dt, scoring='f1', cv=5)
            elif isinstance(estimator, BalancedRandomForestClassifier):
                gs = GridSearchCV(estimator=estimator, param_grid=param_grid_brf, scoring='f1', cv=5)
            gs = gs.fit(train_set_X, train_set_y)
            # write best hyperparameters to file
            if isinstance(estimator, DecisionTreeClassifier):
                with open('../GridSearchCVResults/GridSearchCV_best_params_DT.txt', 'a') as file:
                    file.write('\nIteration: %d\nCV number: %d\nBest parameters: %s' % (iteration, i, gs.best_params_))
            elif isinstance(estimator, BalancedRandomForestClassifier):
                with open('../GridSearchCVResults/GridSearchCV_best_params_BRF.txt', 'a') as file:
                    file.write('\nIteration: %d\nCV number: %d\nBest parameters: %s' % (iteration, i, gs.best_params_))