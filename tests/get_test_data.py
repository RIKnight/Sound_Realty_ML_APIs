import json
import pathlib
import os
import pandas as pd

BASE_DIR = os.getcwd()
DATA_DIR = "mle-project-challenge-2/data"

data_dir = os.path.join(BASE_DIR, DATA_DIR)
data_dir = pathlib.Path(data_dir)
#training_data_filename = "kc_house_data.csv"
unseen_data_filename = "future_unseen_examples.csv"

"""
# List of columns (subset) that will be taken from home sale data
SALES_COLUMN_SELECTION = [
    'price', 'bedrooms', 'bathrooms', 'sqft_living', 'sqft_lot', 'floors',
    'sqft_above', 'sqft_basement', 'zipcode'
]

data = pd.read_csv(data_dir / training_data_filename,
                   usecols=SALES_COLUMN_SELECTION,
                   dtype={'zipcode': str})
"""

unseen = pd.read_csv(data_dir / unseen_data_filename,
                     dtype={'zipcode': str})
num_rows = unseen.shape[0]

def get_data_row_json(row_num):
    """
    Inputs
    ------
    row_num: int
        The row from unseen data to retrieve.
        Modulo of input integer will be taken prior to indexing.

    Returns
    -------
    json_row: json object
        Contains one row of data from future_unseen_examples.csv
        
    """
    new_data_row = unseen.iloc[[row_num%num_rows]]
    json_row = json.loads(new_data_row.to_json(orient='records'))[0]
    return json_row
