#!/usr/bin/env python
import requests

from tests.get_test_data import get_data_row_json

def test_predict_api(row_num):
    """
    Inputs
    ------
    row_num: int
        The row number of the test data to use from test file future_unseen_examples.csv
    
    Returns
    -------
    result: result of the request
    
    """
    test_json = get_data_row_json(row_num)
    result = requests.post('localhost:8000/api/predict', json=test_json)
    return(result)


if __name__ == "__main__":
    # get a number
    row_num = input("Enter a row number for testing: ")
    result = test_predict_api(int(row_num))
    
    print(f"return status code: {result.status_code}")
    print(f"prediction: {result.json()}")

