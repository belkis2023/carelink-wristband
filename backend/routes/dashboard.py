"""
Dashboard Routes

This module handles dashboard-related endpoints including metrics and sensor readings.
"""

from datetime import datetime
from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db

# Create a Blueprint for dashboard routes
# All routes in this file will be prefixed with /api/dashboard
bp = Blueprint('dashboard', __name__, url_prefix='/api/dashboard')


@bp.route('/metrics', methods=['GET'])
@jwt_required()
def get_metrics():
    """
    Get the latest dashboard metrics for the authenticated user.
    
    If no readings exist, returns mock data with is_connected=false.
    
    Headers required:
    - Authorization: Bearer <jwt_token>
    
    Returns:
    - 200: Latest metrics or mock data
    """
    user_id = get_jwt_identity()
    db = get_db(current_app)
    
    # Get the most recent reading for this user
    reading = db.execute(
        '''SELECT heart_rate, motion, noise_level, stress_level, battery, timestamp
           FROM wristband_readings
           WHERE user_id = ?
           ORDER BY timestamp DESC
           LIMIT 1''',
        (user_id,)
    ).fetchone()
    
    if reading:
        # Calculate stress status based on stress level
        stress_level = reading['stress_level']
        if stress_level < 4:
            stress_status = 'Low'
        elif stress_level < 7:
            stress_status = 'Moderate'
        else:
            stress_status = 'High'
        
        return jsonify({
            'stress_level': stress_level,
            'stress_status': stress_status,
            'heart_rate': reading['heart_rate'],
            'motion': reading['motion'],
            'noise_level': reading['noise_level'],
            'battery': reading['battery'],
            'is_connected': False,  # Will be true when BLE is connected
            'last_updated': reading['timestamp']
        }), 200
    else:
        # No readings yet - return mock data
        return jsonify({
            'stress_level': 6.2,
            'stress_status': 'Moderate',
            'heart_rate': 78,
            'motion': 'Moderate',
            'noise_level': 65,
            'battery': 68,
            'is_connected': False,  # Will be true when BLE is connected
            'last_updated': datetime.utcnow().isoformat() + 'Z'
        }), 200


@bp.route('/readings', methods=['POST'])
@jwt_required()
def save_reading():
    """
    Save a new wristband reading from the device.
    
    This endpoint will be used when BLE functionality is added to send
    sensor data from the wristband to the backend.
    
    Request body (JSON) - all fields optional:
    - heart_rate: integer - Heart rate in BPM
    - motion: string - Motion level (Low, Moderate, High)
    - noise_level: integer - Noise level in dB
    - stress_level: float - Stress level (0-10)
    - battery: integer - Battery percentage (0-100)
    
    Headers required:
    - Authorization: Bearer <jwt_token>
    
    Returns:
    - 201: Reading saved successfully
    - 400: Invalid input
    """
    user_id = get_jwt_identity()
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'Request body is required'}), 400
    
    # Extract values (all optional)
    heart_rate = data.get('heart_rate')
    motion = data.get('motion')
    noise_level = data.get('noise_level')
    stress_level = data.get('stress_level')
    battery = data.get('battery')
    
    db = get_db(current_app)
    
    # Insert reading into database
    cursor = db.execute(
        '''INSERT INTO wristband_readings 
           (user_id, heart_rate, motion, noise_level, stress_level, battery)
           VALUES (?, ?, ?, ?, ?, ?)''',
        (user_id, heart_rate, motion, noise_level, stress_level, battery)
    )
    
    reading_id = cursor.lastrowid
    db.commit()
    
    return jsonify({
        'message': 'Reading saved successfully',
        'id': reading_id
    }), 201
