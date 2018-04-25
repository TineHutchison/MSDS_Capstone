import pandas as pd
import csv
import matplotlib.pyplot as plt
import json
from sklearn.linear_model import LogisticRegression

#from bokeh.io import push_notebook, output_notebook
from bokeh.plotting import figure, show
from bokeh.plotting import gmap
from bokeh.layouts import column, row
from bokeh.models import GMapOptions
from bokeh.palettes import brewer
from bokeh.models import CategoricalColorMapper
from bokeh.transform import factor_cmap
from bokeh.transform import linear_cmap
from bokeh.palettes import Spectral10


#Loading the training data
current_dir = '/Users/thutchison15/PycharmProjects/MSDS_Capstone/Water_Table/'
train_data = pd.read_csv(current_dir + 'tanzania-X-train.csv', header=0)
train_target = pd.read_csv(current_dir + 'tanzania-y-train.csv', header=0)
wards = pd.read_csv(current_dir + 'TZ_wards_regions.csv')

#Load the test data:
test_data = pd.read_csv(current_dir + 'tanzania-x-test.csv', header=0)

print(train_data.info())
print(train_data.describe())
print(train_data.describe(include=['object', 'category']))


# Just getting an idea on the distribution of results here.
train_target['status_group'] = train_target['status_group'].astype('category')
print((train_target['status_group'] == 'functional').sum()/59400)
print((train_target['status_group'] == 'functional needs repair').sum()/59400)
print((train_target['status_group'] == 'non functional').sum()/59400)
print(train_target.describe())


def do_transformations(df):
    """
    Set datatypes and fillna for fields in the dataset
    :param df: the dataset
    :return:
    """
    dispatcher = {'id': transform_id, 'amount_tsh': transform_amount_tsh, 'date_recorded': transform_date_recorded,
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
                 'payment_type', 'quantity_group', 'source_type']

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
    return top_n_categories(25, df, col)


def transform_gps_height(df, col):
    return df[col]


def transform_installer(df, col):
    return top_n_categories(25, df, col)


def transform_longitude(df, col):
    return df.longitude.apply(lambda x: x if ((x < 41) and (x> 28)) else df.longitude.mean())


def transform_latitude(df, col):
    return df.latitude.apply(lambda x: x if ((x < -1) and (x> -12)) else df.latitude.mean())


def transform_basin(df, col):
    return df[col].astype('category')


def transform_region(df, col):
    return df[col].astype('category')


def transform_lga(df, col):
    return top_n_categories(25, df, col)


def transform_ward(df, col):
    return top_n_categories(50, df, col)


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



new_train = do_transformations(train_data)
new_train['date_recorded'] = new_train.date_recorded.dt.year
train_w_dummies = pd.get_dummies(new_train)

#logr = LogisticRegression(solver='saga', multi_class='multinomial')
#logr.fit(train_w_dummies, train_target.status_group)

new_test = do_transformations(test_data)
new_test['date_recorded'] = new_test.date_recorded.dt.year
test_w_dummies = pd.get_dummies(new_test)

for col in [x for x in train_w_dummies.columns if x not in test_w_dummies.columns]:
    test_w_dummies[col] = 0

test_w_dummies.drop(columns=[x for x in test_w_dummies.columns if x not in train_w_dummies.columns], inplace=True)

#submission = pd.DataFrame()
#submission['id'] = test_w_dummies.id
#submission['status_group'] = logr.predict(test_w_dummies)

# p = figure()
# p.line(train_data[train_target['status_group'] == 'functional'].construction_year.unique(),
#        train_data[train_target['status_group'] == 'functional'].groupby('construction_year').sum())
# show(p)


#import tensorflow as tf

#tf_train_data = tf.estimator.inputs.pandas_input_fn(train_w_dummies, train_target.status_group, shuffle=True)

import googlemaps
gmaps = googlemaps.Client(key='AIzaSyDdmZU-YmmPrBVhMarTxPBbEv7N_vdrXjY')

latlon = [(x.latitude, x.longitude) for index, x in train_data.iterrows()]

with open(current_dir + 'elevation.csv', 'w') as f:
    f.write('lat,lon,elev\n')
    for key in results:
        for row in results[key]:
            f.write('{0:.5f},{1:.5f},{2:.5f}\n'.format(row['location']['lat'], row['location']['lng'], row['elevation']))

def read_elevs():
    with open(current_dir + 'elevation.csv', newline='') as csvfile:
        elev = list(csv.reader(csvfile, delimiter=','))

elv = {'{},{}'.format(x[0], x[1]): x[2] for x in elev[1:]}

i = 0
for ix, row in new_train[new_train.gps_height == 0].iterrows():
        key = '{0:.5f},{1:.5f}'.format(row.latitude, row.longitude)
        if key in elv.keys():
            new_train.gps_height = elv[key]

def map_numeric_var(df, var):
    print(var)
    cmap = linear_cmap(var, Spectral10, df[var].min(), df[var].max())
    p1 = gmap('AIzaSyDdmZU-YmmPrBVhMarTxPBbEv7N_vdrXjY',mapoptions, plot_width=300, plot_height=300,
             title='Functional Water Points')
    p1.circle(x='longitude', y='latitude', source=train_data[train_target['status_group'] == 'functional'],
              color=cmap)
    p2 = gmap('AIzaSyDdmZU-YmmPrBVhMarTxPBbEv7N_vdrXjY',mapoptions, plot_width=300, plot_height=300,
             title='Water Points Needing Repair')
    p2.circle(x='longitude', y='latitude', source=train_data[train_target['status_group'] == 'functional needs repair'],
              color=cmap)
    p3 = gmap('AIzaSyDdmZU-YmmPrBVhMarTxPBbEv7N_vdrXjY',mapoptions, plot_width=300, plot_height=300,
             title='Non-Functional Water Points')
    p3.circle(x='longitude', y='latitude', source=train_data[train_target['status_group'] == 'non functional'],
              color=cmap)
    #show(p1)
    show(row(p1,p2,p3))

map_numeric_var(new_train, 'gps_height')

latlon = [[x.latitude, x.longitude] for ix, x in new_test[new_test.gps_height == 0].iterrows()]
results = dict()
gmaps = googlemaps.Client(key='AIzaSyDdmZU-YmmPrBVhMarTxPBbEv7N_vdrXjY')
for x in range(0, len(latlon), 500):
    if x + 500 > len(latlon):
        results[x] = googlemaps.elevation.elevation(gmaps, latlon[x:-1])
        continue
    results[x] = googlemaps.elevation.elevation(gmaps, latlon[x:x+500])


with open(current_dir + 'test-elevation.csv', 'w') as f:
    f.write('lat,lon,elev\n')
    for key in results:
        for row in results[key]:
            f.write('{0:.5f},{1:.5f},{2:.5f}\n'.format(row['location']['lat'], row['location']['lng'], row['elevation']))

ward = list()
def read_wards():
    with open(current_dir + 'TZ_wards_regions.csv', newline='') as csvfile:
        ward = list(csv.reader(csvfile, delimiter=','))

wards = {row[1]: row[0] for row in ward[1:]}

ward_error = list()
for dd_ward in train_data.ward.unique():
    if dd_ward not in wards:
        ward_error.append(dd_ward)
i = 0
for dd_ward in test_data.ward.unique():
    if (dd_ward not in wards) and (dd_ward not in ward_error):
        i += 1
        print(dd_ward, i)
        ward_error.append(dd_ward)

TZ_Region = list()
for ix, row in train_data.iterrows():
    if row.ward not in wards:
        TZ_Region.append([row.id, row.region])
        continue
    if row.region.upper() != wards[row.ward]:
        TZ_Region.append([row.id, wards[row.ward]])
    else:
        TZ_Region.append([row.id, row.region])

TZ_Region_test = list()
for ix, row in test_data.iterrows():
    if row.ward not in wards:
        TZ_Region_test.append([row.id, row.region])
        continue
    if row.region.upper() != wards[row.ward]:
        TZ_Region_test.append([row.id, wards[row.ward]])
    else:
        TZ_Region_test.append([row.id, row.region])


with open(current_dir + 'TZ_region_train.csv', 'w') as f:
    f.write('id,TZ_Region\n')
    for row in TZ_Region:
        f.write('{},{}\n'.format(row[0],row[1]))

with open(current_dir + 'TZ_region_test.csv', 'w') as f:
    f.write('id,TZ_Region\n')
    for row in TZ_Region_test:
        f.write('{},{}\n'.format(row[0],row[1]))