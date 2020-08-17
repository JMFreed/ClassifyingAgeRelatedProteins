import pandas as pd
import numpy as np
from numpy import sort
from imblearn.ensemble import BalancedRandomForestClassifier
from sklearn.feature_selection import f_classif, SelectPercentile, SelectFromModel
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
from xgboost import XGBClassifier


'''
reduce_featureset
uses sklearn SelectPercentile
f_classif computes the ANOVA F-value for each feature
returns X attributes with highest scores
@params
--------
X: attributes
y: class label
percentage: % best features to select
'''


def reduce_featureset(X, y, percentage):
    feat_selector = SelectPercentile(f_classif, percentile=percentage).fit(X, y)
    feature_names = list(X.columns.values)
    mask = feat_selector.get_support()
    new_features = []

    for bool_feat, feature in zip(mask, feature_names):
        if bool_feat:
            new_features.append(feature)

    X_new = pd.DataFrame(X, columns=new_features)
    return X_new


'''
xgboost_feature_selection
fit XGBoost classifier to training set
XGBoost classifier ranks features by how well each one individually splits the instances
measures Gini impurity
the higher the threshold, the more important the feature
systematically reduce features by using each threshold found, then evaluate model performance
@params
---------
model: algorithm to be fitted
train_set_X: training set attributes
train_set_y: training set class labels
test_set_X: test set attributes
test_set_y: test set class labels
file_name: file to save threshold score, number of features and performance scores to
'''


def xgboost_feature_selection(model, train_set_X, train_set_y, test_set_X, test_set_y, file_name):
    # fit XGBoost classifier to training set
    xgb = XGBClassifier()
    xgb.fit(train_set_X, train_set_y)

    thresholds = sort(xgb.feature_importances_)
    thresholds = np.unique(np.round(thresholds, decimals=4))
    for thresh in thresholds:
        # select features using threshold
        selection = SelectFromModel(xgb, threshold=thresh, prefit=True)
        feature_idx = selection.get_support()
        feature_names = train_set_X.columns[feature_idx]
        select_X_train = selection.transform(train_set_X)
        select_X_test = selection.transform(test_set_X)

        if select_X_train.shape[1] > 0:
            # train and evaluate model using selected features
            model.fit(select_X_train, train_set_y)
            predictions = model.predict(select_X_test)
            # write results to txt file for import into SQL for processing
            with open(file_name + '.txt', 'a') as file:
                file.write("\nThresh=%.4f, n=%d, Accuracy: %.3f" % (
                    thresh, select_X_train.shape[1], accuracy_score(test_set_y, predictions)))
                file.write("\nThresh=%.4f, n=%d, Precision: %.3f" % (
                    thresh, select_X_train.shape[1], precision_score(test_set_y, predictions)))
                file.write("\nThresh=%.4f, n=%d, Recall: %.3f" % (
                    thresh, select_X_train.shape[1], recall_score(test_set_y, predictions)))
                file.write("\nThresh=%.4f, n=%d, F1 score: %.3f" % (
                    thresh, select_X_train.shape[1], f1_score(test_set_y, predictions)))
                file.write("\nThresh=%.4f, n=%d, AUROC score: %.3f" % (
                    thresh, select_X_train.shape[1], roc_auc_score(test_set_y, predictions)))
                file.close()


'''
get_RF_feature_importances
BalancedRandomForestClassifier calculates importance of each individual feature
@params
--------
estimator: algorithm to fit the data to
X: attributes
y: class labels
feature_names: column names of each attribute
file_name: file to save the results to
'''


def get_RF_feature_importances(estimator, X, y, feature_names, file_name):
    if isinstance(estimator, BalancedRandomForestClassifier):
        estimator.fit(X, y)
        list_importances = estimator.feature_importances_
        for i in range(len(list_importances)):
            # if the feature has been deemed to have importance
            if list_importances[i] > 0:
                with open(file_name + '.txt', 'a') as file:
                    file.write("\n%s, %s" % (feature_names[i], list_importances[i]))
        # separate cross-validation results in text file
        with open(file_name + '.txt', 'a') as file:
            file.write("\n")