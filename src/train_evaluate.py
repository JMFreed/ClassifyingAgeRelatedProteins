import random
from random import Random
import pandas as pd
import numpy as np
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
from sklearn.model_selection import cross_val_score, train_test_split
from collections import Counter

from sklearn.exceptions import UndefinedMetricWarning
import warnings

from src.apply_xgboost import apply_xgboost_train_test
from src.data_import_export import import_csv
from src.feature_reduction import reduce_featureset
from src.sampling import separate_instances, create_undersampled_dataset, create_oversampled_dataset, apply_smote

warnings.filterwarnings("ignore", category=UndefinedMetricWarning)
warnings.filterwarnings("ignore", category=UserWarning)
warnings.filterwarnings("ignore", category=RuntimeWarning)

'''
cross_validation_scores
applies cross validation to dataset using model
@params
---------
estimator: the model to be trained and evaluated
X: attribute columns in dataset
y: class label column in dataset
cv: number of segments data get split into for leave-one-out cross validation
n_iter: number of time to iterate through entire process
'''


def cross_validation_scores(estimator, X, y, cv=10, n_iter=20):
    print('%d-fold cross validation of %s' % (cv, type(estimator).__name__))
    accuracy_scores = []
    precision_scores = []
    recall_scores = []
    f1_scores = []
    auroc_scores = []

    for i in range(n_iter):
        accuracy_scores.append(cross_val_score(estimator, X, y, scoring='accuracy', cv=cv, n_jobs=1))
        precision_scores.append(cross_val_score(estimator, X, y, scoring='precision', cv=cv, n_jobs=1))
        recall_scores.append(cross_val_score(estimator, X, y, scoring='recall', cv=cv, n_jobs=1))
        f1_scores.append(cross_val_score(estimator, X, y, scoring='f1', cv=cv, n_jobs=1))
        auroc_scores.append(cross_val_score(estimator, X, y, scoring='roc_auc', cv=cv, n_jobs=1))

    get_performance_score_summary(accuracy_scores, precision_scores, recall_scores, f1_scores, auroc_scores)


'''
train_test_split_data
splits dataframe into training set and test set
@params
--------
dataframe: data to split into training and test sets
X: attributes
y: class labels
test_size: proportion of samples to be in test set (e.g. 0.2 = 20% of samples)
'''


def train_test_split_data(dataframe, X, y, test_size):
    train, test = train_test_split(dataframe, test_size=test_size,
                                   random_state=Random().randint(1, 1000), stratify=y)
    X_train = train[X.columns]
    y_train = train[y.name]
    X_test = test[X.columns]
    y_test = test[y.name]
    return X_train, y_train, X_test, y_test


'''
train_balanced_test_unbalanced
allows sampling technique to be applied to training set before testing
@params
--------
model: the model to be trained and tested
dataframe: the data for teh model to train on and test
cv: number of segments to split data into (10-fold cross validation default)
sampling: sampling technique to be applied (undersampling, oversampling, SMOTE) default None
n_iter: number of time to perform cross validation
reduce_features: use sklearn SelectPercentile to reduce number of feature in training and test sets
pct: percentage of features used to train and test the classifier
'''


def train_balanced_test_unbalanced(model, dataframe, cv=10, sampling=None, n_iter=20,
                                   apply_xgboost=False, reduce_features=False, feature_pct=50):
    # if exists, remove UniprotID column
    if 'UniprotID' in dataframe.columns:
        dataframe = dataframe.drop(columns='UniprotID')
    print('Number instances: %d' % dataframe.shape[0])
    # split instances into age-related and not-age-related
    age_related, not_age_related = separate_instances(dataframe, dataframe['AgeRelatedFlag (GenAge)'])
    print('Age-related: %d' % age_related.shape[0])
    print('Non-age-related: %d' % not_age_related.shape[0])

    if sampling is None:
        print('No sampling technique applied')
    elif sampling == 'undersample':
        print('Undersampling training set...')
    elif sampling == 'oversample':
        print('Oversampling training set...')
    elif sampling == 'smote':
        print('Applying SMOTE to training set...')

    if reduce_features:
        print('Reducing features by %d percent...' % (100 - feature_pct))

    accuracy_scores = []
    precision_scores = []
    recall_scores = []
    f1_scores = []
    auroc_scores = []

    select_percentile_features = []

    xgboost_selected_features = []

    for k in range(n_iter):
        print('Iteration number: %d' % k)
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
            train_set_a, train_set_b = separate_instances(train_set, train_set['AgeRelatedFlag (GenAge)'])
            # undersample/oversample the training dataset
            if sampling == 'undersample':
                train_set = create_undersampled_dataset(train_set_a, train_set_b)
            elif sampling == 'oversample':
                train_set = create_oversampled_dataset(train_set_a, train_set_b)
            train_set_y = train_set['AgeRelatedFlag (GenAge)']
            train_set = train_set.drop(columns='AgeRelatedFlag (GenAge)')
            train_set_X = train_set.iloc[:, :]
            # apply SMOTE to create synthetic minority samples
            if sampling == 'smote':
                train_set_X, train_set_y = apply_smote(train_set_X, train_set_y)

            # reduce features in dataset using sklearn SelectPercentile to include most important ones
            if reduce_features:
                train_set_X = reduce_featureset(train_set_X, train_set_y, feature_pct)
                select_percentile_features.append(list(train_set_X.columns.values))
                # features removed in training set must be removed from test set
                for column in test_set_X.columns:
                    if column not in train_set_X.columns:
                        test_set_X = test_set_X.drop(columns=column)

            # # find best threshold for XGBoost classifier to use
            # this only needs to be run ONCE
            # if apply_xgboost:
            #     xgboost_feature_selection(model, train_set_X, train_set_y, test_set_X, test_set_y,
            #                               'xgboost_thresholds_' + str(type(model).__name__))

            # comment this out and find best XGBoost threshold FIRST
            # # apply_xgboost_train_test to training and test sets
            if apply_xgboost:
                # apply XGBoost to dataset to reduce features
                train_set_X, test_set_X, feature_names = apply_xgboost_train_test(
                    train_set_X, train_set_y, test_set_X, 0.002)

                xgboost_selected_features.append(list(feature_names))

                # measure importance of each feature when model fitted to training data
                # if isinstance(model, BalancedRandomForestClassifier):
                #     get_RF_feature_importances(
                #         model, train_set_X, train_set_y, feature_names, 'xgboost_rf_feature_selection')

            model.fit(train_set_X, train_set_y)
            y_pred = model.predict(test_set_X)

            accuracy_scores.append(accuracy_score(test_set_y, y_pred))
            precision_scores.append(precision_score(test_set_y, y_pred))
            recall_scores.append(recall_score(test_set_y, y_pred))
            f1_scores.append(f1_score(test_set_y, y_pred))
            auroc_scores.append(roc_auc_score(test_set_y, y_pred))

    # count number of times each feature was selected during feature reduction
    if reduce_features:
        count_feature_occurrence(model, select_percentile_features, feature_pct)

    if apply_xgboost:
        count_feature_occurrence(model, xgboost_selected_features, 1)

    get_performance_score_summary(accuracy_scores, precision_scores, recall_scores, f1_scores, auroc_scores)


'''
count_feature_occurrence
count number of times each feature was selected as importance by the algorithm
if 10-fold cross validation repeated 20 times, and feature selected 200 times by model,
then feature is very likely to be of importance in classifying age-related proteins
'''


def count_feature_occurrence(model, list_reduced_features, percentage):
    # flatten list of lists into single list
    flat_list = [item for sublist in list_reduced_features for item in sublist]
    # count number of instances of each unique item in list
    count = Counter(flat_list)
    d = {}
    # create key: value pair of feature: n_occurrence
    for key, value in count.items():
        d[key] = value
    # create dictionary of GO terms with key: value pair GO term ID and name
    GO_terms = import_csv('tblGOterms')
    dict_GO_terms = dict(zip(GO_terms.GOTermID, GO_terms.GOTermName))
    for key, value in d.items():
        # if the feature was selected every time, must be important feature
        if key in dict_GO_terms.keys():
            with open('SelectPercentile_' + str(type(model).__name__) + '_' + str(percentage) + '.txt', 'a') as file:
                file.write("\n%s , %s" % (dict_GO_terms.get(key), value))
        else:
            with open('SelectPercentile_' + str(type(model).__name__) + '_' + str(percentage) + '.txt', 'a') as file:
                file.write("\n%s , %s" % (key, value))


'''
get_performance_score_summary
list of performance scores
numpy library used to find mean and standard deviation of each list
performance scores printed to terminal, copied and pasted into Microsoft Excel 
'''


def get_performance_score_summary(accuracy_scores, precision_scores, recall_scores, f1_scores, auroc_scores):
    print('%.3f +/- %.3f' % (np.mean(accuracy_scores), np.std(accuracy_scores)))
    print('%.3f +/- %.3f' % (np.mean(precision_scores), np.std(precision_scores)))
    print('%.3f +/- %.3f' % (np.mean(recall_scores), np.std(recall_scores)))
    print('%.3f +/- %.3f' % (np.mean(f1_scores), np.std(f1_scores)))
    print('%.3f +/- %.3f' % (np.mean(auroc_scores), np.std(auroc_scores)))
