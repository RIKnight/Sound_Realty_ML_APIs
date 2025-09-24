import json
import pathlib
import pickle
import pandas as pd

MODEL_DIR = "app/model"  # Directory to load model artifacts from

model_filename = "model.pkl"
features_filename = "model_features.json"
demographics_filename = "zipcode_demographics.csv"

# List of columns (subset) used in training from home sale data
SALES_COLUMN_SELECTION = [
    'price', 'bedrooms', 'bathrooms', 'sqft_living', 'sqft_lot', 'floors',
    'sqft_above', 'sqft_basement', 'zipcode'
]
# same list of columns without the price, since that was the target
TRAINED_COLUMN_SELECTION = [
    'bedrooms', 'bathrooms', 'sqft_living', 'sqft_lot', 'floors',
    'sqft_above', 'sqft_basement', 'zipcode'
]

# Load model artifacts: pickled model and JSON list of features
model_dir = pathlib.Path(MODEL_DIR)
model = pickle.load(open(model_dir / model_filename, 'rb'))
#feature_names = json.load(open(model_dir / features_filename, 'r'))
demographics = pd.read_csv(model_dir / demographics_filename,
                           dtype={'zipcode': str})


def predict_price(new_data_row):
    """
    Inputs
    ------
    new_data_row: pandas? json?  Need to decide.
    
    Returns
    -------
    The prediction from the model: a house price
    
    """
    # this assumes that new_data_row is a pandas df
    merged_new_row = new_data_row[TRAINED_COLUMN_SELECTION].merge(
        demographics,
        how="left",
        on="zipcode").drop(columns="zipcode")
    result = model.predict(merged_new_row)
    return(result[0])
