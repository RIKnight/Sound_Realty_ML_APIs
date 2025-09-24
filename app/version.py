import os

def get_version() -> str:
    return os.getenv("APP_VERSION", "0.1.0")

