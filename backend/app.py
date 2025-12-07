from flask import Flask, jsonify
from routes.auth import auth_bp  # Import the auth blueprint
from flask_cors import CORS

def create_app():
    app = Flask(__name__)
    CORS(app)

    @app.route('/')
    def health_check():
        return jsonify({
            "message": "CareLink Wristband API",
            "status": "running",
            "version": "1.0.0"
        })

    # Register blueprint!
    app.register_blueprint(auth_bp, url_prefix='/auth')

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)