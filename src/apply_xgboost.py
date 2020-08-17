import pandas as pd
from sklearn.feature_selection import SelectFromModel
from xgboost import XGBClassifier


'''
apply_xgboost
applies XGBoost to reduce number of features in dataset
dataset must first be split into X and y
@ params
---------
threhsold: the threshold used to remove features below threshold
apply_xgboost_train_test fits model on training set, reduces features from training and test sets
apply_xgboost_df reduces X using threshold found previously using 10-fold CV
'''


def apply_xgboost_df(X, y, threshold):
    print('\nApplying XGBoost to dataset...')
    xgb = XGBClassifier()
    xgb.fit(X, y)
    selection = SelectFromModel(xgb, threshold=threshold, prefit=True)
    feature_idx = selection.get_support()
    feature_names = X.columns[feature_idx]
    X = selection.transform(X)
    X = pd.DataFrame(X)
    df = X.merge(y, left_index=True, right_index=True)
    return df


def apply_xgboost_train_test(train_set_X, train_set_y, test_set_X, threshold):
    # train XGBoost classiifer on training set
    xgb = XGBClassifier()
    xgb.fit(train_set_X, train_set_y)
    # transform train and test sets to include most important features above threshold
    selection = SelectFromModel(xgb, threshold=threshold, prefit=True)
    feature_idx = selection.get_support()
    feature_names = train_set_X.columns[feature_idx]
    train_set_X = selection.transform(train_set_X)
    test_set_X = selection.transform(test_set_X)
    return train_set_X, test_set_X, feature_names

