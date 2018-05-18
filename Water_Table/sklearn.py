import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_selection import SelectKBest
from sklearn.pipeline import Pipeline, FeatureUnion
import Water_Table.SparseInteractions as SparseInteractions
from sklearn.preprocessing import FunctionTransformer, Imputer
from sklearn.model_selection import GridSearchCV

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

pl = Pipeline([('union', FeatureUnion(
            transformer_list = [
                ('numeric_features', Pipeline([
                    ('selector', get_numeric_data),
                    ('imputer', Imputer())
                ])),
                ('text_features', Pipeline([
                    ('selector', get_text_data),
                    ('vectorizer', CountVectorizer(token_pattern=TOKENS_ALPHANUMERIC,
                                                   ngram_range=(1,2)))
                ]))
            ]
        )),
    ('dim_red', SelectKBest(k=100)),
    ('clf', RandomForestClassifier())
])

results_map = {'functional':0, 'non functional': 1, 'functional needs repair':2}

parameters = dict(dim_red__k=[50, 75, 100, 125],
              clf__n_estimators=[50, 100, 200],
              clf__min_samples_split=[2, 3, 4, 5, 10])

cv = GridSearchCV(pl, param_grid=parameters, n_jobs=9)

train_target_num = train_target.status_group.apply(lambda x: results_map[x])

cv.fit(train_data, train_target_num)

pl.score(train_data, train_target.status_group.apply(lambda x: results_map[x]))

inverse_results_map = {0:'functional', 1:'non functional', 2:'functional needs repair'}
y_pred = pl.predict(test_data)
y_pred = [inverse_results_map[x] for x in list(y_pred)]

pred_list_with_id = list(zip(test_data.id.values, y_pred))

with open(current_dir + 'RF_with_text_2.csv', 'w') as f:
    f.write('id,status_group\n')
    for row in pred_list_with_id:
        f.write('{},{}\n'.format(row[0],row[1]))
