import pandas as pd
import numpy as np
import tensorflow as tf
from tensorflow.python import debug as tf_debug


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
                  'scheme_name': transform_scheme_name, 'permit': transform_permit,
                  'construction_year': transform_construction_year, 'extraction_type': transform_extraction_type,
                  'extraction_type_group': transform_extraction_type_group, 'management': transform_management,
                  'management_group': transform_management_group, 'payment': transform_payment,
                  'water_quality': transform_water_quality, 'quality_group': transform_quality_group,
                  'quantity': transform_quantity, 'source': transform_source,
                  'source_class': transform_source_class, 'waterpoint_type': transform_waterpoint_type}

    drop_cols = ['wpt_name', 'num_private', 'subvillage', 'region_code', 'district_code', 'extraction_type_class',
                 'payment_type', 'quantity_group', 'source_type', 'date_recorded']

    df = df.drop(drop_cols, axis=1)
    for col in df.columns:
        if col not in dispatcher:
            continue
        df[col] = dispatcher[col](df, col)

    #Create an 'age' categorical column 2018 - construction_year. If construtction = 0 mark as '>52'
    # df['age'] = df.construction_year.apply(lambda x: 'unknown' if x == 0 else 2018 - x).astype('category')

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
    return df[col]


def transform_region(df, col):
    return df[col]


def transform_lga(df, col):
    return df[col].fillna('Unknown')

def transform_ward(df, col):
    return df[col].fillna('Unknown')


def transform_population(df, col):
    return fill_na_with_mean(df, col)


def transform_public_meeting(df, col):
    return df[col].fillna(False)


def transform_recorded_by(df, col):
    return df[col].fillna('Other')

def transform_scheme_management(df, col):
    return df[col].fillna('Other')


def transform_scheme_name(df, col):
    return df[col].fillna('Unknown')


def transform_permit(df, col):
    return df[col].fillna(False)


def transform_construction_year(df, col):
    # Passing on this one as we'll transform this into an 'age' column later.
    return df[col]


def transform_extraction_type(df, col):
    return df[col].fillna('Other')


def transform_extraction_type_group(df, col):
    return df[col].fillna('Other')


def transform_management(df, col):
    return df[col].fillna('Other')


def transform_management_group(df, col):
    return df[col].fillna('Other')


def transform_payment(df, col):
    return df[col].fillna('other')


def transform_water_quality(df, col):
    return df[col].fillna('unknown')


def transform_quality_group(df, col):
    return df[col].fillna('unknown')


def transform_quantity(df, col):
    return df[col].fillna('unknown')


def transform_source(df, col):
    return df[col].fillna('unknown')


def transform_source_class(df, col):
    return df[col].fillna('unknown')


def transform_waterpoint_type(df, col):
    return df[col].fillna('other')



current_dir = '/home/tine/PycharmProjects/pred498/MSDS_Capstone/Water_Table/'
#load training data
train_data = do_transformations(pd.read_csv(current_dir + 'tanzania-X-train.csv', header=0))
train_target = pd.read_csv(current_dir + 'tanzania-y-train.csv', header=0)
# status_dict = {'functional': 0,
#                'non functional': 1,
#                'functional needs repair': 2}
# train_target.status_group = train_target.status_group.apply(lambda x: status_dict[x])
# train_target.status_group = train_target.status_group.astype('int')

#load testing data
test_data = do_transformations(pd.read_csv(current_dir + 'tanzania-x-test.csv', header=0))

# Create a list to hold tensorflow feature columns
feature_columns = list()

# Create numeric feature columns
for key in ['amount_tsh', 'gps_height', 'longitude', 'latitude', 'population', 'construction_year']:
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

# Create bucket column for construction_year
feature_columns.append(tf.feature_column.indicator_column(tf.feature_column.bucketized_column(
    tf.feature_column.numeric_column('construction_year'), list(range(1960, 2011, 10)))))

# Create Crossed Columns
feature_columns.append(tf.feature_column.embedding_column(tf.feature_column.crossed_column(
    [tf.feature_column.bucketized_column(tf.feature_column.numeric_column('latitude'),
                                         list(np.arange(-11.0,-1.0, .001))),
     tf.feature_column.bucketized_column(tf.feature_column.numeric_column('longitude'),
                                         list(np.arange(29.0,41, .001)))],
    5000), dimension=9))

# Create input dataset
hooks = [tf_debug.LocalCLIDebugHook()]


# Generate list of column names actually used
feature_names = list()
for key in feature_columns:
    if 'categorical_column' in dir(key):
        if 'bucket' in key.categorical_column.name:
            continue
        feature_names.append(key.categorical_column.key)
        continue
    else:
        feature_names.append(key.key)

result_list = list()
for x in range(10,31,5):
    for x2 in range(15,26):
        for x3 in range(6,10):
            local_results = [x, x2, x3]
            hidden_layers = [x, x2, x3]
            pdinput = tf.estimator.inputs.pandas_input_fn(train_data[feature_names],
                                                          train_target.status_group,
                                                          batch_size=100,
                                                          shuffle=False
                                                          )

            classifier = tf.estimator.DNNClassifier(feature_columns=feature_columns,
                                                    hidden_units=hidden_layers,
                                                    n_classes=3,
                                                    label_vocabulary=list(train_target.status_group.unique())
                                                    )

            classifier.train(input_fn=pdinput)
            local_results.append(classifier.evaluate(input_fn=pdinput))
            result_list.append(local_results)


test_input = tf.estimator.inputs.pandas_input_fn(x=test_data[feature_names], shuffle=False, batch_size=100)
ypreds = list(classifier.predict(input_fn=test_input))

namepreds = [pred['classes'][0].decode('UTF-8') for pred in ypreds]

pred_list_with_id = list(zip(test_data.id.values, namepreds))

with open(current_dir + 'tf1.csv', 'w') as f:
    f.write('id,status_group\n')
    for row in pred_list_with_id:
        f.write('{},{}\n'.format(row[0],row[1]))


