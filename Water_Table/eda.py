import pandas as pd
import matplotlib.pyplot as plt
import json

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
current_dir = '/home/tine/PycharmProjects/pred498/MSDS_Capstone/Water_Table/'
train_data = pd.read_csv(current_dir + 'tanzania-X-train.csv', header=0)
train_target = pd.read_csv(current_dir + 'tanzania-y-train.csv', header=0)

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




# Setting up options for map graphics.
mapoptions = GMapOptions(lat=train_data.latitude.mean(), lng=train_data.longitude.mean(), zoom=5)

p1 = gmap('AIzaSyDdmZU-YmmPrBVhMarTxPBbEv7N_vdrXjY', mapoptions, plot_width=350, plot_height=350,
         title='Functional Water Points')
p1.circle(x='longitude', y='latitude', source=train_data[train_target['status_group'] == 'functional'],
         color='green')
p2 = gmap('AIzaSyDdmZU-YmmPrBVhMarTxPBbEv7N_vdrXjY', mapoptions, plot_width=350, plot_height=350,
         title='Water Points Needing Repair')
p2.circle(x='longitude', y='latitude', source=train_data[train_target['status_group'] == 'functional needs repair'],
         color='yellow')
p3 = gmap('AIzaSyDdmZU-YmmPrBVhMarTxPBbEv7N_vdrXjY', mapoptions, plot_width=350, plot_height=350,
         title='Non-Functional Water Points')
p3.circle(x='longitude', y='latitude', source=train_data[train_target['status_group'] == 'non functional'],
         color='red')
show(row(p1,p2,p3))


def map_numeric_var(df, var):
    print(var)
    cmap = linear_cmap(var, Spectral10, df[var].min(), df[var].max())
    p1 = gmap('AIzaSyDdmZU-YmmPrBVhMarTxPBbEv7N_vdrXjY', mapoptions, plot_width=350, plot_height=350,
             title='Functional Water Points by ' + var, tools=[])
    p1.circle(x='longitude', y='latitude', source=train_data[train_target['status_group'] == 'functional'],
              color=cmap)
    p2 = gmap('AIzaSyDdmZU-YmmPrBVhMarTxPBbEv7N_vdrXjY', mapoptions, plot_width=350, plot_height=350,
             title='Water Points Needing Repair by ' + var, tools=[])
    p2.circle(x='longitude', y='latitude', source=train_data[train_target['status_group'] == 'functional needs repair'],
              color=cmap)
    p3 = gmap('AIzaSyDdmZU-YmmPrBVhMarTxPBbEv7N_vdrXjY', mapoptions, plot_width=350, plot_height=350,
             title='Non-Functional Water Points by ' + var, tools=[])
    p3.circle(x='longitude', y='latitude', source=train_data[train_target['status_group'] == 'non functional'],
              color=cmap)
    show(row(p1,p2,p3))

for vars in train_data.select_dtypes(['int64','float64']):
    print(vars)
for var in ['amount_tsh', 'gps_height','population','construction_year']:
    map_numeric_var(train_data, var)


# TRANSFORM: Convert to datetime
train_data.date_recorded = pd.to_datetime(train_data.date_recorded)

map_numeric_var(train_data, 'date_recorded')
train_data.date_recorded.describe()
# In[ ]:


map_numeric_var(train_data, 'amount_tsh')


# In[ ]:


"""
Variables

amount_tsh - Total static head (amount water available to waterpoint)
date_recorded - The date the row was entered
funder - Who funded the well
gps_height - Altitude of the well
installer - Organization that installed the well
longitude - GPS coordinate
latitude - GPS coordinate
wpt_name - Name of the waterpoint if there is one
num_private -
basin - Geographic water basin
subvillage - Geographic location
region - Geographic location
region_code - Geographic location (coded)
district_code - Geographic location (coded)
lga - Geographic location
ward - Geographic location
population - Population around the well
public_meeting - True/False
recorded_by - Group entering this row of data
scheme_management - Who operates the waterpoint
scheme_name - Who operates the waterpoint
permit - If the waterpoint is permitted
construction_year - Year the waterpoint was constructed
extraction_type - The kind of extraction the waterpoint uses
extraction_type_group - The kind of extraction the waterpoint uses
extraction_type_class - The kind of extraction the waterpoint uses
management - How the waterpoint is managed
management_group - How the waterpoint is managed
payment - What the water costs
payment_type - What the water costs
water_quality - The quality of the water
quality_group - The quality of the water
quantity - The quantity of water
quantity_group - The quantity of water
source - The source of the water
source_type - The source of the water
source_class - The source of the water
waterpoint_type - The kind of waterpoint
waterpoint_type_group - The kind of waterpoint
"""


# In[ ]:


def histogram(df, var):
    x = list(df.status_group.unique())
    counts = [len(df[df['status_group'] == i][var]) for i in x]
    p = figure(x_range=x, title="{} count by Status".format(var),
           toolbar_location=None, tools="", plot_height=250)
    p.vbar(x=x, top=counts, width=0.9)
    p.xgrid.grid_line_color = None
    p.y_range.start = 0
    show(p)
    
    
def explore_variable(df, var):
    print('#'*80)
    print('Exploring variable: {}'.format(var))
    print(df[var].describe())
    df[var].hist()


# In[ ]:


continuous_vars = ['amount_tsh', 'gps_height', 'longitude', 'latitude', 'population', 
                   'construction_year', 'payment', 'payment_type', 'water_quality',  'quantity']
date_vars = ['date_recorded']


# In[ ]:


for var in train_data.columns:
    length = len(train_data[var].unique())
    if length <= 25:
        train_data[var] = train_data[var].astype('category')
train_data.date_recorded = pd.to_datetime(train_data.date_recorded)


# In[ ]:


train_data.info()


# In[ ]:


from sklearn.linear_model import LinearRegression

lm = LinearRegression()
lm.fit(train_data, train_target)


# In[ ]:


objvars = ['funder', 'installer', 'wpt_name', 'subvillage', 'lga', 'ward', 'scheme_name']


# In[ ]:


for var in objvars:
    print(var, len(train_data[var].unique()))


# In[ ]:


train_trimmed = train_data.drop(columns=objvars)


# In[ ]:


lm = LinearRegression()
lm.fit(train_trimmed, train_target)


# In[ ]:


train_trimmed.info()


# In[ ]:


train_trimmed[train_trimmed.amount_tsh == 'hand pump']


# In[ ]:


for continuous_var in continuous_vars:
    train_trimmed[[continuous_var]].boxplot(vert=True)
    plt.show()


# In[ ]:


for continuous_var in train_data.select_dtypes(['int64','float64']).columns.values:
    print(continuous_var)
    train_data[[continuous_var]].hist(bins=20, by=train_target.status_group, xrot=3/4)
    plt.show()


# In[ ]:


for var in train_data.select_dtypes('object').columns.values:
    print(var,train_data[var].value_counts()[:20])


# In[ ]:


def top_n_categories(n, df, var):
    top_n = list(df[var].value_counts()[:n].index.values)
    return df[var].apply(lambda x: 'Other' if x not in top_n else x).astype('category')


# In[ ]:


top_n_categories(20, train_data, 'funder')


# In[ ]:


get_ipython().run_line_magic('pinfo', 'pd.DataFrame.boxplot')


# In[ ]:


train_data.basin.value_counts()

