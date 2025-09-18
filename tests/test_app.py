import os
import pytest
from app import create_app

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

