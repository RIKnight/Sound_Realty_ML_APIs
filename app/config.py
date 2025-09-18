import os

class Config:
    APP_NAME = os.getenv("APP_NAME", "flask-api")
    ENVIRONMENT = os.getenv("ENVIRONMENT", "dev")
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

