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
    test_json: the json that was sent for the test
    result: result of the request
    
    """
    test_json = get_data_row_json(row_num)
    result = requests.post('http://localhost:80/api/predict', json=test_json)
    return(test_json, result)


if __name__ == "__main__":
    print("Press Ctrl-C to stop sending sample requests.")

    while True:
        # get a number
        row_num = input("Enter a row number for testing: ")  # input will probably be 1-based
        test_json, result = test_predict_api(int(row_num-1))  # switch to 0-based indexing

        print(f"test json from row {row_num} of the file: {test_json}")
        print(f"return status code: {result.status_code}")
        print(f"prediction: {result.json()["prediction"]}")

