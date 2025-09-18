from flask import Flask, jsonify
from .config import Config
from .routes import api_bp
from .health import health_bp
from .version import get_version

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Blueprints
    app.register_blueprint(api_bp, url_prefix="/api")
    app.register_blueprint(health_bp)

    # Version endpoint
    @app.get("/version")
    def version():
        return jsonify({"version": get_version()})

    @app.errorhandler(404)
    def not_found(e):
        return jsonify({"error": "Not found"}), 404

    return app

