import io
import matplotlib.pyplot as plt
import numpy as np
import pydotplus
from numpy import interp
from sklearn.metrics import roc_curve
from sklearn.model_selection import validation_curve, cross_val_score

from sklearn.tree import export_graphviz
from data_import_export import import_csv
from src.train_evaluate import train_test_split_data

# suppress warnings
import warnings
import matplotlib.cbook

warnings.filterwarnings("ignore", category=matplotlib.cbook.mplDeprecation)
warnings.filterwarnings("ignore", category=FutureWarning)


'''
*** WARNING ***
takes a long time to run
plot_repeat_standard_error
Determines best number of repeats to perform on a dataset
@params
-------
estimator: model to fit data
X: attributes
y: class labels
cv: number of segments for cross-validation (e.g. cv=10 for 10-fold cross-validation)
n_iter: number of iterations
'''


def plot_repeat_standard_error(estimator, X, y, cv=10, n_iter=100):
    accuracy_scores = []
    precision_scores = []
    recall_scores = []
    f1_scores = []
    auroc_scores = []

    plt.figure()

    for i in range(n_iter):
        print('Iteration %d' % i)
        accuracy_scores.append(cross_val_score(estimator, X, y, scoring='accuracy', cv=cv, n_jobs=1))
        precision_scores.append(cross_val_score(estimator, X, y, scoring='precision', cv=cv, n_jobs=1))
        recall_scores.append(cross_val_score(estimator, X, y, scoring='recall', cv=cv, n_jobs=1))
        f1_scores.append(cross_val_score(estimator, X, y, scoring='f1', cv=cv, n_jobs=1))
        auroc_scores.append(cross_val_score(estimator, X, y, scoring='roc_auc', cv=cv, n_jobs=1))

        plt.plot(i, np.std(accuracy_scores) / np.sqrt(i), label='accuracy')
        plt.plot(i, np.std(precision_scores) / np.sqrt(i), label='precision')
        plt.plot(i, np.std(recall_scores) / np.sqrt(i), label='recall')
        plt.plot(i, np.std(f1_scores) / np.sqrt(i), label='F1 score')
        plt.plot(i, np.std(auroc_scores) / np.sqrt(i), label='AUROC score')

    plt.legend()
    plt.show()


'''
save_tree_figure
Saves image of the DecisionTree as .png file
@params
--------
estimator: model to fit to data
X: attributes
y: class labels
file_name: file to save image to
'''


def save_tree_figure(estimator, X, y, file_name):
    GO_terms = import_csv('tblGOTerms')
    dict_GO_terms = dict(zip(GO_terms.GOTermID, GO_terms.GOTermName))
    features = X.columns
    feature_names = []
    for x in X.columns:
        if x in dict_GO_terms.keys():
            feature_names.append(dict_GO_terms[x])
        else:
            feature_names.append(x)
    estimator = estimator.fit(X, y)
    f = io.StringIO()
    export_graphviz(estimator, out_file=f,
                    feature_names=feature_names,
                    class_names=['negative', 'positive'], filled=True)
    pydotplus.graph_from_dot_data(f.getvalue()).write_png(file_name + '.png')


'''
plot_validation_curve
Plots validation curve to test individual hyperparameter values on dataset
uses 10-fold cross validation
@params
--------
X: attributes
y: class labels
model: algorithm to train and evaluate
param_name: hyperparameter to investigate
param_range: range of hyperparameter values to test
cv: number of cross-validation segments
scoring: performance metric to evaluate
plot_xlabel: title of the x-axis
plot_ylabel: title of the y-axis
leg_loc: location of the legend in the figure
plot_xscale: linear (1,2,3,4,5) or logarithmic (10^0, 10^1, 10^2, 10^3)
plot_title: title to give the figure
plot_filename: filename to save the figure to 
'''


def plot_validation_curve(X, y, model=None, param_name='', param_range=None, cv=10,
                          scoring='f1', plot_xlabel='', plot_ylabel='', leg_loc='upper right',
                          plot_xscale=None, plot_title='', filename=None):

    train_scores, test_scores = validation_curve(
        model, X, y, param_name, param_range=param_range, cv=cv, scoring=scoring)
    train_mean = np.mean(train_scores, axis=1)
    train_std = np.std(train_scores, axis=1)
    test_mean = np.mean(test_scores, axis=1)
    test_std = np.std(test_scores, axis=1)

    plt.plot(param_range, train_mean, color='blue', marker='o', markersize=5, label='training set')
    plt.fill_between(param_range, train_mean + train_std, train_mean - train_std, alpha=0.15, color='blue')
    plt.plot(param_range, test_mean, color='green', linestyle='--', marker='s', markersize=5, label='validation set')
    plt.fill_between(param_range, test_mean + test_std, test_mean - test_std, alpha=0.15, color='green')

    plt.grid()
    plt.xscale(plot_xscale)
    plt.legend(loc=leg_loc)
    plt.xlabel(plot_xlabel)
    plt.ylabel(plot_ylabel)
    plt.title(plot_title)
    plt.ylim([0.0, 1.03])
    plt.savefig(filename)
    plt.show()


'''
plot ROC curve of model
x_axis = false positive rate
y_axis = true positive rate
@params
-------
estimator: model to be fitted
X: attributes
y: class label
fname: file to save figure to
cv: number of cross validation segments
'''


def plot_ROC_cross_validation(estimator, dataframe, X, y, fname, cv=10):
    tprs = []
    base_fpr = np.linspace(0, 1, 101)
    plt.figure(figsize=(5, 5))

    for x in range(cv):
        X_train, y_train, X_test, y_test = train_test_split_data(dataframe, X, y, 0.2)
        model = estimator.fit(X_train, y_train)
        y_score = model.predict_proba(X_test)
        fpr, tpr, _ = roc_curve(y_test, y_score[:, 1])

        plt.plot(fpr, tpr, 'b', alpha=0.15)
        tpr = interp(base_fpr, fpr, tpr)
        tpr[0] = 0.0
        tprs.append(tpr)

    tprs = np.array(tprs)
    mean_tprs = tprs.mean(axis=0)
    std = tprs.std(axis=0)

    tprs_upper = np.minimum(mean_tprs + std, 1)
    tprs_lower = mean_tprs - std

    plt.plot(base_fpr, mean_tprs, 'b')
    plt.fill_between(base_fpr, tprs_lower, tprs_upper, color='grey', alpha=0.3)

    plt.plot([0, 1], [0, 1], 'r--')
    plt.xlim([-0.01, 1.01])
    plt.ylim([-0.01, 1.01])
    plt.ylabel('True Positive Rate')
    plt.xlabel('False Positive Rate')
    plt.axes().set_aspect('equal', 'datalim')
    plt.savefig(fname + '.png')
    plt.show()


# XGBoost classiifer used to reduce number of feature in dataset
# plot performance metrics against number of features selected
def plot_xgboost_results():
    xgb_df = import_csv('XGBoostResults\\XGBoost_DT_results\\xgboost_threshold_scores')
    plt.plot(xgb_df['N_features'], xgb_df['Accuracy'], label='Accuracy')
    plt.plot(xgb_df['N_features'], xgb_df['Precision'], label='Precision')
    plt.plot(xgb_df['N_features'], xgb_df['Recall'], label='Recall')
    plt.plot(xgb_df['N_features'], xgb_df['F1_score'], label='F1')
    plt.plot(xgb_df['N_features'], xgb_df['AUROC_score'], label='AUROC')
    plt.ylim(0, 1.03, 0.1)
    plt.yticks(np.arange(0.0, 1.1, 0.1))
    plt.xlabel('Number of selected features')
    plt.xscale('log')
    plt.ylabel('Performance score')
    plt.legend()
    plt.show()