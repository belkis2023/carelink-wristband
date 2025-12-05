import os
from datetime import timedelta

class Config:
    """
    Configuration class for the Flask application.
    Contains settings for JWT authentication, database, and other app configurations.
    """
    
    # Secret key for JWT tokens (in production, use environment variable)
    SECRET_KEY = os.environ.get('SECRET_KEY', 'carelink-secret-key-change-in-production')
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', 'carelink-jwt-secret-key-2024')
    
    # JWT token will be valid for 7 days
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=7)
    
    # SQLite database path
    DATABASE = 'carelink.db'
