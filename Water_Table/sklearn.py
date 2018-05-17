import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_selection import SelectKBest
from sklearn.pipeline import Pipeline, FeatureUnion
import Water_Table.SparseInteractions as SparseInteractions
from sklearn.preprocessing import FunctionTransformer

#Loading the training data
current_dir = '/home/tine/PycharmProjects/pred498/MSDS_Capstone/Water_Table/'
train_data = pd.read_csv(current_dir + 'tanzania-X-train.csv', header=0)
train_target = pd.read_csv(current_dir + 'tanzania-y-train.csv', header=0)

#Load the test data:
test_data = pd.read_csv(current_dir + 'tanzania-x-test.csv', header=0)

# Fill scheme_name nulls with 'unknown' drop all the other NAs.
train_data.scheme_name.fillna('unknown', inplace=True)
train_data.dropna(axis=0, inplace=True)

TOKENS_ALPHANUMERIC = '[A-Za-z0-9]+(?=\\s+)'


def combine_object_columns(df):
    object_columns = df.describe(include=['object', 'category']).columns
    to_drop = [x for x in df.columns if x not in object_columns]
    text_data = df.drop(to_drop, axis=1)

    # Replace nans with blanks
    text_data.fillna('', inplace=True)

    # Join all text items in a row that have a space in between
    return text_data.apply(lambda x: " ".join(x), axis=1)

vect = CountVectorizer(token_pattern=TOKENS_ALPHANUMERIC, ngram_range=(1,2))

vect.fit(combine_object_columns(train_data))