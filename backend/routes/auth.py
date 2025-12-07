from flask import Blueprint, request, jsonify
import sqlite3
import hashlib
import datetime
import jwt
import os
from functools import wraps

auth_bp = Blueprint('auth_bp', __name__)

# --- JWT Setup ---
JWT_SECRET = 'your-very-secret-key'  # Replace with a strong secret!
JWT_ALGORITHM = 'HS256'

def generate_jwt(user_id, email):
    payload = {
        "user_id": user_id,
        "email": email,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=12)
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

def decode_jwt(token):
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            bearer = request.headers['Authorization']
            parts = bearer.split()
            if len(parts) == 2 and parts[0] == 'Bearer':
                token = parts[1]
        if not token:
            return jsonify({"error": "Token is missing!"}), 401
        decoded = decode_jwt(token)
        if not decoded:
            return jsonify({"error": "Invalid or expired token!"}), 401
        request.user = decoded
        return f(*args, **kwargs)
    return decorated

# --- Database helpers ---
DATABASE = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'carelink.db'))

def get_db_connection():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode('utf-8')).hexdigest()

# --- Signup route ---
@auth_bp.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    required_fields = ['email', 'password', 'full_name']

    for field in required_fields:
        if field not in data or not data[field]:
            return jsonify({"error": f"Missing required field: {field}"}), 400

    email = data['email']
    password = data['password']
    full_name = data['full_name']
    password_hash = hash_password(password)
    created_at = datetime.datetime.utcnow().isoformat()

    conn = get_db_connection()
    cursor = conn.cursor()

    # Check for duplicate email
    cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
    if cursor.fetchone():
        conn.close()
        return jsonify({"error": "Email already registered"}), 409

    # Insert new user
    cursor.execute(
        "INSERT INTO users (email, password_hash, full_name, created_at) VALUES (?, ?, ?, ?)",
        (email, password_hash, full_name, created_at)
    )
    user_id = cursor.lastrowid

    # Insert profile info if present
    profile_fields = ['name', 'age', 'date_of_birth', 'relationship', 'emergency_contact_name', 'emergency_contact_phone']
    profile_data = {field: data.get(field, "") for field in profile_fields}
    profile_data['user_id'] = user_id

    cursor.execute(
        """
        INSERT INTO profiles (user_id, name, age, date_of_birth, relationship, emergency_contact_name, emergency_contact_phone)
        VALUES (:user_id, :name, :age, :date_of_birth, :relationship, :emergency_contact_name, :emergency_contact_phone)
        """,
        profile_data
    )

    conn.commit()
    conn.close()

    return jsonify({"message": "User registered successfully", "user_id": user_id}), 201

# --- Login route with JWT ---
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    required_fields = ['email', 'password']

    for field in required_fields:
        if field not in data or not data[field]:
            return jsonify({"error": f"Missing field: {field}"}), 400

    email = data['email']
    password = data['password']
    password_hash = hash_password(password)

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT * FROM users WHERE email = ? AND password_hash = ?",
        (email, password_hash)
    )
    user = cursor.fetchone()
    conn.close()

    if user:
        token = generate_jwt(user["id"], user["email"])
        return jsonify({
            "message": "Login successful",
            "token": token,
            "user_id": user["id"],
            "full_name": user["full_name"],
            "email": user["email"]
        }), 200
    else:
        return jsonify({"error": "Invalid email or password"}), 401

# --- Example protected route: Profile ---
@auth_bp.route('/profile', methods=['GET'])
@token_required
def get_profile():
    user_id = request.user['user_id']
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM profiles WHERE user_id = ?", (user_id,))
    profile = cursor.fetchone()
    conn.close()
    if profile:
        return jsonify(dict(profile)), 200
    else:
        return jsonify({"error": "Profile not found"}), 404
    
# --- Update Profile route ---
@auth_bp.route('/profile', methods=['PUT'])
@token_required
def update_profile():
    user_id = request.user['user_id']
    data = request.get_json()

    conn = get_db_connection()
    cursor = conn.cursor()

    # Update profile fields
    cursor.execute(
        """
        UPDATE profiles 
        SET name = ?, age = ?, date_of_birth = ?, relationship = ?, 
            emergency_contact_name = ?, emergency_contact_phone = ? 
        WHERE user_id = ?
        """,
        (
            data.get('name', ''),
            data.get('age', ''),
            data.get('date_of_birth', ''),
            data.get('relationship', ''),
            data.get('emergency_contact_name', ''),
            data.get('emergency_contact_phone', ''),
            user_id
        )
    )

    conn.commit()
    conn.close()

    return jsonify({"message": "Profile updated successfully"}), 200
