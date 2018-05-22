import pandas as pd
import xgboost as xgb
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_selection import SelectKBest
from sklearn.pipeline import Pipeline, FeatureUnion
from sklearn.preprocessing import FunctionTransformer, Imputer, MaxAbsScaler
from sklearn.linear_model import LogisticRegression
from sklearn.multiclass import OneVsRestClassifier
from sklearn.ensemble import RandomForestClassifier
"""
from https://github.com/drivendataorg/box-plots-sklearn/blob/master/src/features/SparseInteractions.py
"""
from itertools import combinations

import numpy as np
from scipy import sparse
from sklearn.base import BaseEstimator, TransformerMixin


class SparseInteractions(BaseEstimator, TransformerMixin):
    def __init__(self, degree=2, feature_name_separator="_"):
        self.degree = degree
        self.feature_name_separator = feature_name_separator

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        if not sparse.isspmatrix_csc(X):
            X = sparse.csc_matrix(X)

        if hasattr(X, "columns"):
            self.orig_col_names = X.columns
        else:
            self.orig_col_names = np.array([str(i) for i in range(X.shape[1])])

        spi = self._create_sparse_interactions(X)
        return spi

    def get_feature_names(self):
        return self.feature_names

    def _create_sparse_interactions(self, X):
        out_mat = []
        self.feature_names = self.orig_col_names.tolist()

        for sub_degree in range(2, self.degree + 1):
            for col_ixs in combinations(range(X.shape[1]), sub_degree):
                # add name for new column
                name = self.feature_name_separator.join(self.orig_col_names[list(col_ixs)])
                self.feature_names.append(name)

                # get column multiplications value
                out = X[:, col_ixs[0]]
                for j in col_ixs[1:]:
                    out = out.multiply(X[:, j])

                out_mat.append(out)

        return sparse.hstack([X] + out_mat)

#Loading the training data
current_dir = '/home/tine/PycharmProjects/pred498/MSDS_Capstone/Water_Table/'
train_data = pd.read_csv(current_dir + 'tanzania-X-train-v3.csv', header=0)
train_target = pd.read_csv(current_dir + 'tanzania-y-train.csv', header=0)

#Load the test data:
test_data = pd.read_csv(current_dir + 'tanzania-X-test-v3.csv', header=0)

# Fill scheme_name nulls with 'unknown' drop all the other NAs.
train_data.scheme_name.fillna('unknown', inplace=True)
#train_data.dropna(axis=0, inplace=True)

TOKENS_ALPHANUMERIC = '[A-Za-z0-9]+(?=\\s+)'

continuous_columns = ['amount_tsh', 'gps_height', 'longitude', 'latitude', 'population',
                      'construction_year', 'age', 'monthRecorded', 'logpop', 'elevation',
                      'age_imp', 'elevation2', 'logpop_imp', 'longitude_imp', 'latitude_imp']
boolean_columns = ['public_meeting', 'permit', 'has_population', 'has_amount_tsh',
                   'has_construction_year', 'has_gps_height', 'has_cpg_missing_data',
                   'has_cpg_some_data', 'has_bad_latOrLong', 'missing_elevation']
text_columns = ['funder', 'installer', 'wpt_name', 'basin', 'subvillage', 'region', 'lga',
                'ward', 'recorded_by', 'scheme_management', 'scheme_name', 'extraction_type',
                'extraction_type_group', 'extraction_type_class', 'management', 'management_group',
                'payment', 'payment_type', 'water_quality', 'quality_group', 'quantity',
                'quantity_group', 'source', 'source_type', 'source_class', 'waterpoint_type',
                'waterpoint_type_group', 'funder_cat', 'region_new']

for col in boolean_columns:
    train_data[col] = train_data[col].astype('bool')
    test_data[col] = test_data[col].astype('bool')

def combine_text_columns(df):
    keep_cols = text_columns
    to_drop = [x for x in df.columns if x not in keep_cols]
    text_data = df.drop(to_drop, axis=1)

    # Replace nans with blanks
    text_data.fillna('', inplace=True)

    # Join all text items in a row that have a space in between
    return text_data.apply(lambda x: " ".join(x), axis=1)

def return_numerics(df):
    return df[continuous_columns + boolean_columns]

# Perform preprocessing
get_text_data = FunctionTransformer(combine_text_columns, validate=False)
get_numeric_data = FunctionTransformer(return_numerics, validate=False)



pl3 = Pipeline([('union',
                 FeatureUnion(
                     transformer_list = [
                         ('numeric_features', Pipeline([
                             ('selector', get_numeric_data),
                             ('imputer', Imputer()),
                             ('scale', MaxAbsScaler())
                         ])),
                         ('text_features', Pipeline([
                             ('selector', get_text_data),
                             ('vectorizer', CountVectorizer(token_pattern=TOKENS_ALPHANUMERIC,
                                                            ngram_range=(1, 2))),
                             ('dim_red', SelectKBest(k=128)),
                             ('int', SparseInteractions(degree=2))
                         ]))
                     ]
                 )),
                ('clf', xgb.XGBClassifier())
                ])


results_map = {'functional':0, 'non functional': 1, 'functional needs repair':2}
train_target_num = train_target.status_group.apply(lambda x: results_map[x])

#cv3.fit(train_data, train_target_num)
pl3.fit(train_data, train_target_num)

inverse_results_map = {0:'functional', 1:'non functional', 2:'functional needs repair'}
y_pred3 = pl3.predict(test_data)
y_pred3 = [inverse_results_map[x] for x in list(y_pred3)]

pred_list_with_id3 = list(zip(test_data.id.values, y_pred3))

with open(current_dir + 'XGB_with_text_grid_search_and interactions1.csv', 'w') as f:
    f.write('id,status_group\n')
    for row in pred_list_with_id3:
        f.write('{},{}\n'.format(row[0],row[1]))
