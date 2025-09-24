import os
import pytest
from app import create_app

from .get_test_data import get_data_row_json

@pytest.fixture()
def client():
    os.environ["APP_VERSION"] = "9.9.9-test"
    app = create_app()
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c

def test_healthz(client):
    rv = client.get("/healthz")
    assert rv.status_code == 200
    assert rv.get_json()["status"] == "ok"

def test_readyz(client):
    rv = client.get("/readyz")
    assert rv.status_code == 200
    assert rv.get_json()["status"] == "ready"

def test_hello_default(client):
    rv = client.get("/api/hello")
    assert rv.status_code == 200
    assert rv.get_json()["message"] == "Hello, world!"

def test_hello_with_name(client):
    rv = client.get("/api/hello?name=Knight")
    assert rv.status_code == 200
    assert rv.get_json()["message"] == "Hello, Knight!"

def test_version(client):
    rv = client.get("/version")
    assert rv.status_code == 200
    assert rv.get_json()["version"] == "9.9.9-test"


# test endpoints that need json data

def test_predict(client):
    # need to convert test data into json form for use in test
    rv = client.post("/api/predict", json=get_data_row_json(0))
    assert rv.status_code == 200
    #assert type(rv.get_json()["prediction"]) == 

