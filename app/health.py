from flask import Blueprint, jsonify

health_bp = Blueprint("health", __name__)
_app_ready = True  # Replace with real checks if needed

@health_bp.get("/healthz")
def healthz():
    return jsonify({"status": "ok"}), 200

@health_bp.get("/readyz")
def readyz():
    if _app_ready:
        return jsonify({"status": "ready"}), 200
    return jsonify({"status": "not_ready"}), 503

