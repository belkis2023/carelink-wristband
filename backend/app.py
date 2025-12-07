"""
CareLink Wristband Backend API

This Flask application provides a REST API for the CareLink Wristband mobile app.
It handles user authentication, profile management, sensor data, and alerts.

The backend uses:
- SQLite for data storage
- JWT for authentication
- Flask-CORS for cross-origin requests (allowing Flutter app to connect)
"""

from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from config import Config
from database import close_db, init_db

# Initialize Flask app
app = Flask(__name__)
app.config.from_object(Config)

# Enable CORS for all routes (needed for Flutter app to connect)
CORS(app)

# Initialize JWT for authentication
jwt = JWTManager(app)

# Register teardown function to close database connections
app.teardown_appcontext(close_db)

# Import and register route blueprints
from routes import auth, dashboard, profile, alerts

app.register_blueprint(auth.bp)
app.register_blueprint(dashboard.bp)
app.register_blueprint(profile.bp)
app.register_blueprint(alerts.bp)


@app.route('/')
def index():
    """
    Root endpoint - returns a welcome message.
    Useful for checking if the API is running.
    """
    return {
        'message': 'CareLink Wristband API',
        'version': '1.0.0',
        'status': 'running'
    }


if __name__ == '__main__':
    # Initialize database on first run
    init_db(app)
    
    # Run the Flask development server
    # Host 127.0.0.1 means it only accepts connections from this computer
    # Port 5000 is the default Flask port
    # Debug mode provides helpful error messages (disable in production)
    app.run(host='127.0.0.1', port=5000, debug=True)
