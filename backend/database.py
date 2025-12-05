"""
Database utilities for the CareLink Wristband API.
"""

import sqlite3
from flask import g

def get_db(app):
    """
    Get a database connection.
    Creates a new connection if one doesn't exist for this request.
    Uses Flask's 'g' object to store connection per request.
    """
    if 'db' not in g:
        g.db = sqlite3.connect(
            app.config['DATABASE'],
            detect_types=sqlite3.PARSE_DECLTYPES
        )
        # Return rows as dictionaries instead of tuples
        g.db.row_factory = sqlite3.Row
    return g.db


def close_db(e=None):
    """
    Close the database connection at the end of each request.
    This is automatically called by Flask after handling a request.
    """
    db = g.pop('db', None)
    if db is not None:
        db.close()


def init_db(app):
    """
    Initialize the database with required tables.
    Creates tables for users, profiles, wristband readings, and alerts.
    """
    with app.app_context():
        db = get_db(app)
        
        # Users table - stores authentication information
        db.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                full_name TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Profiles table - stores information about the monitored person
        db.execute('''
            CREATE TABLE IF NOT EXISTS profiles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                name TEXT DEFAULT 'Alex Johnson',
                age INTEGER DEFAULT 14,
                date_of_birth TEXT,
                relationship TEXT DEFAULT 'Parent',
                emergency_contact_name TEXT,
                emergency_contact_phone TEXT,
                FOREIGN KEY (user_id) REFERENCES users (id)
            )
        ''')
        
        # Wristband readings table - stores sensor data from the wristband
        db.execute('''
            CREATE TABLE IF NOT EXISTS wristband_readings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                heart_rate INTEGER,
                motion TEXT,
                noise_level INTEGER,
                stress_level REAL,
                battery INTEGER,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id)
            )
        ''')
        
        # Alerts table - stores notifications for the user
        db.execute('''
            CREATE TABLE IF NOT EXISTS alerts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                type TEXT NOT NULL,
                title TEXT NOT NULL,
                message TEXT,
                is_read INTEGER DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id)
            )
        ''')
        
        db.commit()
