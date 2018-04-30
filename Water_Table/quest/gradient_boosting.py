import logging
import shelve
import pandas as pd
from datetime import datetime
from sklearn import preprocessing
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.model_selection import cross_val_score

base_dir = '../'

# create logger
logger = logging.getLogger('gradient_boosting')
logger.setLevel(logging.DEBUG)
# create file handler which logs even debug messages
fh = logging.FileHandler('./logs/gradient_boosting.log')
fh.setLevel(logging.DEBUG)
# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
# create formatter and add it to the handlers
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
fh.setFormatter(formatter)
ch.setFormatter(formatter)
# add the handlers to the logger
logger.addHandler(fh)
logger.addHandler(ch)

start_global = datetime.now()

logger.info('Start time: ' + str(start_global))

# import data
x_train_df = pd.read_csv(base_dir + 'tanzania-X-train.csv', index_col='id')
y_train_df = pd.read_csv(base_dir + 'tanzania-y-train.csv', index_col='id')
x_test_df = pd.read_csv(base_dir + 'tanzania-x-test.csv', index_col='id')

# set data types
cols_category = ['funder', 'installer', 'wpt_name', 'basin', 'subvillage', 'region', 'region_code',
                 'district_code', 'lga', 'ward', 'recorded_by', 'scheme_management', 'scheme_name',
                 'extraction_type', 'extraction_type_group', 'extraction_type_class', 'management',
                 'management_group', 'payment', 'payment_type', 'water_quality', 'quality_group',
                 'quantity', 'quantity_group', 'source', 'source_type', 'source_class',
                 'waterpoint_type', 'waterpoint_type_group']

cols_bool = ['public_meeting', 'permit']

cols_numeric = ['num_private', 'latitude', 'longitude', 'amount_tsh', 'gps_height', 'population',
                'construction_year']

cols_date = ['date_recorded']

# apply data types
x_train_df[cols_category] = x_train_df[cols_category].apply(lambda x: x.astype('category'))
x_train_df[cols_bool] = x_train_df[cols_bool].apply(lambda x: x.astype('bool'))
x_train_df[cols_numeric] = x_train_df[cols_numeric].apply(pd.to_numeric)
x_train_df[cols_date] = x_train_df[cols_date].apply(pd.to_datetime)

y_train_df.status_group = y_train_df.status_group.astype('category')

train_df = x_train_df.join(y_train_df)

# copy Dan's construction year
max_year = 2013
train_df['age'] = 0
train_df.loc[train_df.construction_year > 0, 'age'] = max_year - train_df.loc[
    train_df.construction_year > 0, 'construction_year']

# Modeling
logger.info('#### Gradient Boosting ####')
gb_train_df = train_df.copy()

# variables to drops
cols_drop = ['extraction_type', 'funder', 'construction_year', 'installer', 'wpt_name',
             'subvillage', 'ward', 'lga', 'scheme_name', 'scheme_management']

column_labels = list(gb_train_df.columns.values)
[column_labels.remove(x) for x in cols_drop]
column_labels.remove('status_group')
status_group = ["functional", "non functional", "functional needs repair"]
gb_train_df = gb_train_df[column_labels]

# need to use LabelEncoder for categorical variables
gb_train_df = gb_train_df.apply(preprocessing.LabelEncoder().fit_transform)

params = {'n_estimators': 1500, 'max_depth': 3, 'subsample': 0.5,
          'learning_rate': 0.01, 'min_samples_leaf': 1, 'random_state': 3}
clf_gb = GradientBoostingClassifier(**params)

logger.info('Gradient Boosting training started')
clf_gb.fit(gb_train_df, train_df["status_group"])

logger.info('Gradient Boosting cross validation started')
scores_gb = cross_val_score(clf_gb, gb_train_df, train_df["status_group"], n_jobs=-1)
logger.info('Random Forest mean score: ' + str(scores_gb.mean()))

# Load shelved data
# with shelve.open('shelf_gb') as db:
#     clf_gb = db['clf_gb']

# Save shelved data
with shelve.open('shelf_gb') as db:
    db['clf_gb'] = clf_gb

logger.info('Run duration: ' + str(datetime.now() - start_global))
logger.info('###### END ####')
