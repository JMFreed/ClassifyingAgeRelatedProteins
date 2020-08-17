from imblearn.ensemble import BalancedRandomForestClassifier
from sklearn.model_selection import cross_val_score
from sklearn.tree import DecisionTreeClassifier

from sklearn.utils import compute_class_weight

from src.data_import_export import import_csv
from src.optimize_models import evaluate_model_hyperparameters
from src.plot_figures import plot_xgboost_results, save_tree_figure
from src.predict_probabilities import predict_probabilities
from src.train_evaluate import train_balanced_test_unbalanced


def import_merge_datasets():

    print('Importing datasets...')
    df_GO_terms = import_csv('tblBinaryProteinsXGOTerms\\tblBinaryProteinsXGOTermsThreshold=7')
    df_age_related_partners = import_csv('tblBinaryProteinsXBPIs\\tblProteinXNumberAgeRelatedPartners')
    df_age_related_BPIs_T20 = import_csv('tblBinaryProteinsXBPIs\\tblProteinsXAgeRelatedBPIsThreshold=20')

    print('Merging databsets...')
    df = df_GO_terms.merge(df_age_related_partners, on='UniprotID')
    df = df.merge(df_age_related_BPIs_T20, on=['UniprotID', 'AgeRelatedFlag (GenAge)'])

    print('Removing aging and senescence GO terms...')
    # omit 'aging' and 'senescence' related GO terms
    redundant_GO_terms = ['GO:0001302', 'GO:0007568', 'GO:0007569', 'GO:0010259',
                          'GO:0090342', 'GO:0090343', 'GO:0090344', 'GO:0090398',
                          'GO:0090399', 'GO:0090400', 'GO:2000772']

    for column in df.columns:
        if column in redundant_GO_terms:
            df = df.drop(columns=column)
    return df


def main():

    #######################################################################################
    # GO TERM HIERARCHY EXPERIMENT
    #######################################################################################

    print('Importing datasets...')

    df_no_hierarchy = import_csv('tblBinaryProteinsXGOTerms\\tblBinaryProteinsXGOTermsNoHierarchyThrehsold=3')

    df_hierarchy = import_csv('tblBinaryProteinsXGOTerms\\tblBinaryProteinsXGOTermsThreshold=3')

    dataframes = [df_no_hierarchy, df_hierarchy]

    print('Removing aging and senescence GO terms...')
    # omit 'aging' and 'senescence' related GO terms
    redundant_GO_terms = ['GO:0001302', 'GO:0007568', 'GO:0007569', 'GO:0010259',
                          'GO:0090342', 'GO:0090343', 'GO:0090344', 'GO:0090398',
                          'GO:0090399', 'GO:0090400', 'GO:2000772']

    dt = DecisionTreeClassifier()

    for dataframe in dataframes:
        for column in dataframe.columns:
            if column in redundant_GO_terms:
                dataframe = dataframe.drop(columns=column)
        print(dataframe.shape)

        train_balanced_test_unbalanced(dt, dataframe, cv=10, sampling=None, n_iter=100,
                                       apply_xgboost=False, reduce_features=False)

    #######################################################################################
    # GO TERM THRESHOLD EXPERIMENT
    #######################################################################################

    print('Importing datasets...')

    df_GO_3 = import_csv('tblBinaryProteinsXGOTerms\\tblBinaryProteinsXGOTermsThreshold=3')

    df_GO_5 = import_csv('tblBinaryProteinsXGOTerms\\tblBinaryProteinsXGOTermsThreshold=5')

    df_GO_7 = import_csv('tblBinaryProteinsXGOTerms\\tblBinaryProteinsXGOTermsThreshold=7')

    df_GO_9 = import_csv('tblBinaryProteinsXGOTerms\\tblBinaryProteinsXGOTermsThreshold=9')

    df_GO_11 = import_csv('tblBinaryProteinsXGOTerms\\tblBinaryProteinsXGOTermsThreshold=11')

    dataframes = [df_GO_3, df_GO_5, df_GO_7, df_GO_9, df_GO_11]

    print('Removing aging and senescence GO terms...')
    # omit 'aging' and 'senescence' related GO terms
    redundant_GO_terms = ['GO:0001302', 'GO:0007568', 'GO:0007569', 'GO:0010259',
                          'GO:0090342', 'GO:0090343', 'GO:0090344', 'GO:0090398',
                          'GO:0090399', 'GO:0090400', 'GO:2000772']

    dt = DecisionTreeClassifier()

    for dataframe in dataframes:
        for column in dataframe.columns:
            if column in redundant_GO_terms:
                dataframe = dataframe.drop(columns=column)
        print(dataframe.shape)

        train_balanced_test_unbalanced(dt, dataframe, cv=10, sampling=None, n_iter=100,
                                       apply_xgboost=False, reduce_features=False)

    #######################################################################################
    # GO TERM + NUMBER OF PPI PARTNERS EXPERIMENT
    #######################################################################################

    print('Importing datasets...')

    df_GO_terms_only = import_csv('tblBinaryProteinsXGOTerms\\tblBinaryProteinsXGOTermsThreshold=7')

    total_partners = import_csv('tblBinaryProteinsXBPIs\\tblProteinXTotalNumberPartners')

    age_related_partners = import_csv('tblBinaryProteinsXBPIs\\tblProteinXNumberAgeRelatedPartners')

    BPIs_T10 = import_csv('tblBinaryProteinsXBPIs\\tblProteinsXBPIsThreshold=10')

    BPIs_T20 = import_csv('tblBinaryProteinsXBPIs\\tblProteinsXBPIsThreshold=20')

    BPIs_T30 = import_csv('tblBinaryProteinsXBPIs\\tblProteinsXBPIsThreshold=30')

    print('Merging datasets...')

    df_GO_terms_total_PPIs = df_GO_terms_only.merge(total_partners, on='UniprotID')

    df_GO_terms_age_related_PPIs = df_GO_terms_only.merge(age_related_partners, on='UniprotID')

    total_and_age_related_PPIs = total_partners.merge(age_related_partners, on='UniprotID')

    df_GO_terms_total_and_age_related_PPIs = df_GO_terms_only.merge(total_and_age_related_PPIs, on='UniprotID')

    df_GO_terms_BPIs_T10 = df_GO_terms_only.merge(BPIs_T10, on=['UniprotID', 'AgeRelatedFlag (GenAge)'])

    df_GO_terms_BPIs_T20 = df_GO_terms_only.merge(BPIs_T20, on=['UniprotID', 'AgeRelatedFlag (GenAge)'])

    df_GO_terms_BPIs_T30 = df_GO_terms_only.merge(BPIs_T30, on=['UniprotID', 'AgeRelatedFlag (GenAge)'])

    dataframes = [df_GO_terms_only, df_GO_terms_total_PPIs, df_GO_terms_age_related_PPIs,
                  df_GO_terms_total_and_age_related_PPIs, df_GO_terms_BPIs_T10,
                  df_GO_terms_BPIs_T20, df_GO_terms_BPIs_T30]

    print('Removing aging and senescence GO terms...')
    # omit 'aging' and 'senescence' related GO terms
    redundant_GO_terms = ['GO:0001302', 'GO:0007568', 'GO:0007569', 'GO:0010259',
                          'GO:0090342', 'GO:0090343', 'GO:0090344', 'GO:0090398',
                          'GO:0090399', 'GO:0090400', 'GO:2000772']

    dt = DecisionTreeClassifier()

    for dataframe in dataframes:
        for column in dataframe.columns:
            if column in redundant_GO_terms:
                dataframe = dataframe.drop(columns=column)
        print(dataframe.shape)

        train_balanced_test_unbalanced(dt, dataframe, cv=10, sampling=None, n_iter=100,
                                       apply_xgboost=False, reduce_features=False)

    #######################################################################################
    # AGE-RELATED BPI PARTNERS THRESHOLD EXPERIMENT
    #######################################################################################

    print('Importing datasets...')

    df_GO_terms_only = import_csv('tblBinaryProteinsXGOTerms\\tblBinaryProteinsXGOTermsThreshold=7')

    df_age_related_BPIs_T10 = import_csv('tblBinaryProteinsXBPIs\\tblProteinsXAgeRelatedBPIsThreshold=10')

    df_age_related_BPIs_T20 = import_csv('tblBinaryProteinsXBPIs\\tblProteinsXAgeRelatedBPIsThreshold=20')

    df_age_related_BPIs_T30 = import_csv('tblBinaryProteinsXBPIs\\tblProteinsXAgeRelatedBPIsThreshold=30')

    df_GO_terms_age_related_BPIs_T10 = df_GO_terms_only.merge(df_age_related_BPIs_T10,
                                                              on=['UniprotID', 'AgeRelatedFlag (GenAge)'])

    df_GO_terms_age_related_BPIs_T20 = df_GO_terms_only.merge(df_age_related_BPIs_T20,
                                                              on=['UniprotID', 'AgeRelatedFlag (GenAge)'])

    df_GO_terms_age_related_BPIs_T30 = df_GO_terms_only.merge(df_age_related_BPIs_T30,
                                                              on=['UniprotID', 'AgeRelatedFlag (GenAge)'])

    dataframes = [df_GO_terms_only, df_GO_terms_age_related_BPIs_T10,
                  df_GO_terms_age_related_BPIs_T20, df_GO_terms_age_related_BPIs_T30]

    print('Removing aging and senescence GO terms...')
    # omit 'aging' and 'senescence' related GO terms
    redundant_GO_terms = ['GO:0001302', 'GO:0007568', 'GO:0007569', 'GO:0010259',
                          'GO:0090342', 'GO:0090343', 'GO:0090344', 'GO:0090398',
                          'GO:0090399', 'GO:0090400', 'GO:2000772']

    dt = DecisionTreeClassifier()

    for dataframe in dataframes:
        for column in dataframe.columns:
            if column in redundant_GO_terms:
                dataframe = dataframe.drop(columns=column)
        print(dataframe.shape)

        train_balanced_test_unbalanced(dt, dataframe, cv=10, sampling=None, n_iter=100,
                                       apply_xgboost=False, reduce_features=False)

    #######################################################################################
    # FEATURE REDUCTION USING SelectPercentile EVALUATING DECISION TREE MODEL
    #######################################################################################

    # df = import_merge_datasets()
    #
    # dt = DecisionTreeClassifier()
    #
    # percentages = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    #
    # for x in percentages:
    #     train_balanced_test_unbalanced(dt, df, cv=10, sampling=None, n_iter=100,
    #                                    apply_xgboost=False, reduce_features=True, feature_pct=x)

    #######################################################################################
    # FEATURE REDUCTION USING XGBoost EVALUATING DECISION TREE MODEL
    #######################################################################################

    plot_xgboost_results()

    df = import_merge_datasets()

    dt = DecisionTreeClassifier()

    train_balanced_test_unbalanced(dt, df, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=False, reduce_features=False)

    train_balanced_test_unbalanced(dt, df, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=True, reduce_features=False)

    #######################################################################################
    # APPLYING SAMPLING TECHNIQUES TO DATASET
    #######################################################################################

    df = import_merge_datasets()

    dt = DecisionTreeClassifier()

    sampling_techniques = [None, 'undersample', 'oversample', 'smote']
    for technique in sampling_techniques:
        train_balanced_test_unbalanced(dt, df, cv=10, sampling=technique, n_iter=100,
                                       apply_xgboost=False, reduce_features=False)

    #######################################################################################
    # USING GridSearchCV TO FIND OPTIMAL DECISION TREE HYPERPARAMETERS
    #######################################################################################

    df = import_merge_datasets()

    default_dt = DecisionTreeClassifier()

    evaluate_model_hyperparameters(default_dt, df, cv=10, n_iter=100)

    #######################################################################################
    # EVALUATING BASE VS OPTIMIZED DECISION TREE CLASSIFIER
    #######################################################################################

    df = import_merge_datasets()

    default_dt = DecisionTreeClassifier()

    # hyperparameters ascertained from nested 5-fold internal cross-validation
    optimized_dt = DecisionTreeClassifier(max_depth=5, min_samples_split=5, min_samples_leaf=2, ccp_alpha=0.0001)

    train_balanced_test_unbalanced(default_dt, df, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=False, reduce_features=False)

    train_balanced_test_unbalanced(default_dt, df, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=True, reduce_features=False)

    train_balanced_test_unbalanced(optimized_dt, df, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=False, reduce_features=False)

    train_balanced_test_unbalanced(optimized_dt, df, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=True, reduce_features=False)

    #######################################################################################
    # DRAW DECISION TREE
    #######################################################################################

    df = import_merge_datasets()
    print(df.head())
    df = df.drop(columns=['UniprotID'])
    y = df['AgeRelatedFlag (GenAge)']
    df = df.drop(columns=['AgeRelatedFlag (GenAge)'])
    X = df.iloc[:, :]

    optimized_dt = DecisionTreeClassifier(max_depth=5, min_samples_split=5, min_samples_leaf=2, ccp_alpha=0.0001)

    save_tree_figure(optimized_dt, X, y, 'decision_tree')

    #######################################################################################
    # USING GridSearchCV TO FIND OPTIMAL BALANCED RANDOM FOREST HYPERPARAMETERS
    #######################################################################################

    df = import_merge_datasets()

    default_brf = BalancedRandomForestClassifier()

    evaluate_model_hyperparameters(default_brf, df, cv=10, n_iter=100)

    #######################################################################################
    # USING GridSearchCV TO OPTIMIZE BALANCED RANDOM FOREST HYPERPARAMETERS
    #######################################################################################

    df = import_merge_datasets()

    default_brf = BalancedRandomForestClassifier()
    optimized_brf = BalancedRandomForestClassifier(n_estimators=1000, max_features='log2', class_weight='balanced')

    train_balanced_test_unbalanced(default_brf, df, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=False, reduce_features=False)

    train_balanced_test_unbalanced(default_brf, df, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=True, reduce_features=False)

    train_balanced_test_unbalanced(optimized_brf, df, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=False, reduce_features=False)

    train_balanced_test_unbalanced(optimized_brf, df, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=True, reduce_features=False)

    #######################################################################################
    # BALANCED RANDOM FOREST PREDICTIONS
    #######################################################################################

    df = import_merge_datasets()

    y = df['AgeRelatedFlag (GenAge)']
    X = df.iloc[:, 2:]

    brf = BalancedRandomForestClassifier(n_estimators=1000, max_features='log2')

    for i in range(1, 21):
        predict_probabilities(brf, X, y, i)

    #######################################################################################
    # ADDING MGI PROTEINS TO AGE-RELATED CLASS, USING BRF + XGBOOST FOR ANALYSIS
    #######################################################################################

    print('Importing datasets...')

    df_GenAge_GO_terms = import_csv('tblBinaryProteinsXGOTerms\\tblBinaryProteinsXGOTermsThreshold=7')
    df_GenAge_age_related_partners = import_csv('tblBinaryProteinsXBPIs\\tblProteinXNumberAgeRelatedPartners')
    df_GenAge_age_related_BPIs_T20 = import_csv('tblBinaryProteinsXBPIs\\tblProteinsXAgeRelatedBPIsThreshold=20')

    df_GenAge_MGI_GO_terms = import_csv('GenAge_MGI_datasets\\tblProteinsXGOTermsThreshold=7')
    df_GenAge_MGI_age_related_partners = import_csv('GenAge_MGI_datasets\\tblProteinXNumberAgeRelatedPartners')
    df_GenAge_MGI_age_related_BPIs_T20 = import_csv('GenAge_MGI_datasets\\tblProteinsXAgeRelatedBPIsThreshold=20')

    print('Merging databsets...')

    df_GenAge = df_GenAge_GO_terms.merge(df_GenAge_age_related_partners, on='UniprotID')
    df_GenAge = df_GenAge.merge(df_GenAge_age_related_BPIs_T20, on=['UniprotID', 'AgeRelatedFlag (GenAge)'])

    df_GenAge_MGI = df_GenAge_MGI_GO_terms.merge(df_GenAge_MGI_age_related_partners, on='UniprotID')
    df_GenAge_MGI = df_GenAge_MGI.merge(df_GenAge_MGI_age_related_BPIs_T20, on=['UniprotID', 'AgeRelatedFlag (GenAge)'])

    datasets = [df_GenAge, df_GenAge_MGI]

    print('Removing aging and senescence GO terms...')
    # omit 'aging' and 'senescence' related GO terms
    redundant_GO_terms = ['GO:0001302', 'GO:0007568', 'GO:0007569', 'GO:0010259',
                          'GO:0090342', 'GO:0090343', 'GO:0090344', 'GO:0090398',
                          'GO:0090399', 'GO:0090400', 'GO:2000772']

    for dataset in datasets:
        for column in dataset.columns:
            if column in redundant_GO_terms:
                dataset = dataset.drop(columns=column)

    optimized_brf = BalancedRandomForestClassifier(n_estimators=1000, max_features='log2', class_weight='balanced')

    train_balanced_test_unbalanced(optimized_brf, df_GenAge, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=False, reduce_features=False)

    train_balanced_test_unbalanced(optimized_brf, df_GenAge, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=True, reduce_features=False)

    train_balanced_test_unbalanced(optimized_brf, df_GenAge_MGI, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=False, reduce_features=False)

    train_balanced_test_unbalanced(optimized_brf, df_GenAge_MGI, cv=10, sampling=None, n_iter=100,
                                   apply_xgboost=True, reduce_features=False)


if __name__ == '__main__':
    main()
