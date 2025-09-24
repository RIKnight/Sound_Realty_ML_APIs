import pandas as pd
from flask import Blueprint, jsonify, request

from .serve_model import predict_price

api_bp = Blueprint("api", __name__)

@api_bp.get("/hello")
def hello():
    name = request.args.get("name", "world")
    return jsonify({"message": f"Hello, {name}!"})

@api_bp.post("/predict")
def predict():
    json_ = request.json
    query_df = pd.DataFrame(json_, index=[0])
    prediction = predict_price(query_df)
    return jsonify({'prediction': prediction})
