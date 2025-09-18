from flask import Blueprint, jsonify, request

api_bp = Blueprint("api", __name__)

@api_bp.get("/hello")
def hello():
    name = request.args.get("name", "world")
    return jsonify({"message": f"Hello, {name}!"})

