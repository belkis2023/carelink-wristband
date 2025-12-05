"""
Authentication Routes

This module handles user authentication including signup, login, logout, and user info.
Uses JWT tokens for secure authentication.
"""

import re
import sqlite3
import bcrypt
from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from database import get_db

# Create a Blueprint for auth routes
# All routes in this file will be prefixed with /api/auth
bp = Blueprint('auth', __name__, url_prefix='/api/auth')


def is_valid_email(email):
    """
    Validate email format using a simple regex pattern.
    Returns True if email is valid, False otherwise.
    """
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None


@bp.route('/signup', methods=['POST'])
def signup():
    """
    Create a new user account.
    
    Request body (JSON):
    - email: string (required) - User's email address
    - password: string (required) - Password (min 6 characters)
    - full_name: string (optional) - User's full name
    
    Returns:
    - 201: Account created successfully with JWT token
    - 400: Invalid input or email already exists
    """
    data = request.get_json()
    
    # Validate required fields
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({'error': 'Email and password are required'}), 400
    
    email = data['email'].strip().lower()
    password = data['password']
    full_name = data.get('full_name', '').strip()
    
    # Validate email format
    if not is_valid_email(email):
        return jsonify({'error': 'Invalid email format'}), 400
    
    # Validate password length
    if len(password) < 6:
        return jsonify({'error': 'Password must be at least 6 characters'}), 400
    
    # Hash the password using bcrypt for security
    password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    
    db = get_db(current_app)
    
    try:
        # Insert new user into database
        cursor = db.execute(
            'INSERT INTO users (email, password_hash, full_name) VALUES (?, ?, ?)',
            (email, password_hash, full_name if full_name else None)
        )
        user_id = cursor.lastrowid
        
        # Create a default profile for the user
        db.execute(
            'INSERT INTO profiles (user_id) VALUES (?)',
            (user_id,)
        )
        
        db.commit()
        
        # Create JWT access token
        access_token = create_access_token(identity=user_id)
        
        return jsonify({
            'message': 'Account created successfully',
            'access_token': access_token,
            'user': {
                'id': user_id,
                'email': email,
                'full_name': full_name
            }
        }), 201
        
    except sqlite3.IntegrityError:
        # Email already exists
        return jsonify({'error': 'Email already registered'}), 400


@bp.route('/login', methods=['POST'])
def login():
    """
    Authenticate user and return JWT token.
    
    Request body (JSON):
    - email: string (required)
    - password: string (required)
    
    Returns:
    - 200: Login successful with JWT token
    - 401: Invalid credentials
    """
    data = request.get_json()
    
    # Validate required fields
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({'error': 'Email and password are required'}), 400
    
    email = data['email'].strip().lower()
    password = data['password']
    
    db = get_db(current_app)
    
    # Find user by email
    user = db.execute(
        'SELECT id, email, password_hash, full_name FROM users WHERE email = ?',
        (email,)
    ).fetchone()
    
    # Check if user exists and password matches
    if user and bcrypt.checkpw(password.encode('utf-8'), user['password_hash']):
        # Create JWT access token
        access_token = create_access_token(identity=user['id'])
        
        return jsonify({
            'message': 'Login successful',
            'access_token': access_token,
            'user': {
                'id': user['id'],
                'email': user['email'],
                'full_name': user['full_name']
            }
        }), 200
    else:
        return jsonify({'error': 'Invalid email or password'}), 401


@bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    """
    Logout user.
    
    Note: JWT tokens are stateless, so logout is handled on the client side
    by removing the token from storage. This endpoint confirms the logout.
    
    Returns:
    - 200: Logout successful
    """
    return jsonify({'message': 'Logout successful'}), 200


@bp.route('/me', methods=['GET'])
@jwt_required()
def get_current_user():
    """
    Get current authenticated user's information.
    
    Headers required:
    - Authorization: Bearer <jwt_token>
    
    Returns:
    - 200: User information
    - 401: Invalid or missing token
    """
    # Get user ID from JWT token
    user_id = get_jwt_identity()
    
    db = get_db(current_app)
    
    # Fetch user data
    user = db.execute(
        'SELECT id, email, full_name, created_at FROM users WHERE id = ?',
        (user_id,)
    ).fetchone()
    
    if user:
        return jsonify({
            'id': user['id'],
            'email': user['email'],
            'full_name': user['full_name'],
            'created_at': user['created_at']
        }), 200
    else:
        return jsonify({'error': 'User not found'}), 404

