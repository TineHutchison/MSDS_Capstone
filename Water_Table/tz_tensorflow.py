import pandas as pd
import numpy as np
import tensorflow as tf


def do_transformations(df):
    """
    Set datatypes and fillna for fields in the dataset
    :param df: the dataset
    :return:
    """
    dispatcher = {'id': transform_id, 'amount_tsh': transform_amount_tsh,
                  'funder': transform_funder, 'gps_height': transform_gps_height, 'installer': transform_installer,
                  'longitude': transform_longitude, 'latitude': transform_latitude, 'basin': transform_basin,
                  'region': transform_region, 'lga': transform_lga, 'ward': transform_ward,
                  'population': transform_population, 'public_meeting': transform_public_meeting,
                  'recorded_by': transform_recorded_by, 'scheme_management': transform_scheme_management,
                  'permit': transform_permit, 'construction_year': transform_construction_year,
                  'extraction_type': transform_extraction_type, 'extraction_type_group': transform_extraction_type_group,
                  'management': transform_management, 'management_group': transform_management_group,
                  'payment': transform_payment, 'water_quality': transform_water_quality,
                  'quality_group': transform_quality_group, 'quantity': transform_quantity, 'source': transform_source,
                  'source_class': transform_source_class, 'waterpoint_type': transform_waterpoint_type}

    drop_cols = ['wpt_name', 'num_private', 'subvillage', 'region_code', 'district_code', 'extraction_type_class',
                 'payment_type', 'quantity_group', 'source_type', 'date_recorded']

    df = df.drop(drop_cols, axis=1)
    for col in df.columns:
        if col not in dispatcher:
            continue
        df[col] = dispatcher[col](df, col)

    #Create an 'age' categorical column 2018 - construction_year. If construtction = 0 mark as '>52'
    df['age'] = df.construction_year.apply(lambda x: 'unknown' if x == 0 else 2018 - x).astype('category')

    return df

def fill_na_with_mean(df, col):
    return df[col].fillna(df[col].mean())


def fill_na_with_median(df, col):
    return df[col].fillna(df[col].median())


def top_n_categories(n, df, var):
    top_n = list(df[var].value_counts()[:n].index.values)
    return df[var].apply(lambda x: 'Other' if x not in top_n else x).astype('category')


def transform_id(df, col):
    return df[col]


def transform_amount_tsh(df, col):
    return fill_na_with_mean(df, col)


def transform_date_recorded(df, col):
    return pd.to_datetime(df[col])


def transform_funder(df, col):
    return df[col].fillna('Unknown')


def transform_gps_height(df, col):
    return df[col]


def transform_installer(df, col):
    return df[col].fillna('Unknown')


def transform_longitude(df, col):
    return df.longitude.apply(lambda x: x if ((x < 41) and (x> 28)) else df.longitude.mean())


def transform_latitude(df, col):
    return df.latitude.apply(lambda x: x if ((x < -1) and (x> -12)) else df.latitude.mean())


def transform_basin(df, col):
    return df[col].astype('category')


def transform_region(df, col):
    return df[col].astype('category')


def transform_lga(df, col):
    return df[col].fillna('Unknown')

def transform_ward(df, col):
    return df[col].fillna('Unknown')


def transform_population(df, col):
    return fill_na_with_mean(df, col)


def transform_public_meeting(df, col):
    return df[col].fillna(False)


def transform_recorded_by(df, col):
    return df[col].fillna('Other').astype('category')

def transform_scheme_management(df, col):
    return df[col].fillna('Other').astype('category')


def transform_permit(df, col):
    return df[col].fillna(False)


def transform_construction_year(df, col):
    # Passing on this one as we'll transform this into an 'age' column later.
    return df[col]


def transform_extraction_type(df, col):
    return df[col].fillna('Other').astype('category')


def transform_extraction_type_group(df, col):
    return df[col].fillna('Other').astype('category')


def transform_management(df, col):
    return df[col].fillna('Other').astype('category')


def transform_management_group(df, col):
    return df[col].fillna('Other').astype('category')


def transform_payment(df, col):
    return df[col].fillna('other').astype('category')


def transform_water_quality(df, col):
    return df[col].fillna('unknown').astype('category')


def transform_quality_group(df, col):
    return df[col].fillna('unknown').astype('category')


def transform_quantity(df, col):
    return df[col].fillna('unknown').astype('category')


def transform_source(df, col):
    return df[col].fillna('unknown').astype('category')


def transform_source_class(df, col):
    return df[col].fillna('unknown').astype('category')


def transform_waterpoint_type(df, col):
    return df[col].fillna('other').astype('category')



current_dir = '/home/tine/PycharmProjects/pred498/MSDS_Capstone/Water_Table/'
#load training data
train_data = do_transformations(pd.read_csv(current_dir + 'tanzania-X-train.csv', header=0))
train_target = pd.read_csv(current_dir + 'tanzania-y-train.csv', header=0)
status_dict = {'functional': 0,
               'non functional': 1,
               'functional needs repair': 2}
train_target.status_group = train_target.status_group.apply(lambda x: status_dict[x])
train_target.status_group = train_target.status_group.astype('int')

#load testing data
test_data = do_transformations(pd.read_csv(current_dir + 'tanzania-x-test.csv', header=0))

# Create a list to hold tensorflow feature columns
feature_columns = list()

"""
['id', 'amount_tsh', 'date_recorded', 'funder', 'gps_height',
       'installer', 'longitude', 'latitude', 'wpt_name', 'num_private',
       'basin', 'subvillage', 'region', 'region_code', 'district_code', 'lga',
       'ward', 'population', 'public_meeting', 'recorded_by',
       'scheme_management', 'scheme_name', 'permit', 'construction_year',
       'extraction_type', 'extraction_type_group', 'extraction_type_class',
       'management', 'management_group', 'payment', 'payment_type',
       'water_quality', 'quality_group', 'quantity', 'quantity_group',
       'source', 'source_type', 'source_class', 'waterpoint_type',
       'waterpoint_type_group']
"""
# Create numeric feature columns
for key in  ['amount_tsh', 'gps_height','longitude','latitude']:
    feature_columns.append(tf.feature_column.numeric_column(key=key))

# Create categorical feature columns for categories with less than 30 possible values
object_vars = list(train_data.select_dtypes(['category', 'object']).columns)
for key in [x for x in object_vars if len(train_data[x].unique()) <= 30]:
    if key in ['public_meeting', 'region_code', 'district_code', 'permit']:
        train_data[key] = train_data[key].apply(lambda x: str(x))
    if key == 'date_recorded':
        continue
    feature_columns.append(tf.feature_column.indicator_column(
                            tf.feature_column.categorical_column_with_vocabulary_list(
                            key, vocabulary_list=list(train_data[key].unique())
    )))

# Create hashed feature columns for categories with more than 30 unique values
for key in [x for x in object_vars if len(train_data[x].unique()) > 30]:
    if key == 'date_recorded':
        continue
    feature_columns.append(tf.feature_column.indicator_column(
                            tf.feature_column.categorical_column_with_hash_bucket(key, hash_bucket_size=100)))

# Generate list of column names actually used
feature_names = list()
for key in feature_columns:
    if 'categorical_column' in dir(key):
        feature_names.append(key.categorical_column.key)
        continue
    else:
        feature_names.append(key.key)

# Create input dataset

input = tf.estimator.inputs.pandas_input_fn(train_data[feature_names],
                                            train_target.status_group, shuffle=False)

classifier = tf.estimator.DNNClassifier(feature_columns=feature_columns,
                                        hidden_units=[30,10],
                                        n_classes=3)

#train_target['new_status'] = train_target.status_group.apply(lambda x: 1 if x == 'functional' else 2 if x == 'functional needs repair')
classifier.train(input_fn=input)

eval_result = classifier.evaluate(input_fn=input)

test_data = do_transformations(test_data)
test_input = tf.estimator.inputs.pandas_input_fn(test_data[feature_names], shuffle=False)
classifier.predict()