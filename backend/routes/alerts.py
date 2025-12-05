"""
Alerts Routes

This module handles alert management endpoints.
"""

from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db

# Create a Blueprint for alerts routes
# All routes in this file will be prefixed with /api/alerts
bp = Blueprint('alerts', __name__, url_prefix='/api/alerts')


@bp.route('', methods=['GET'])
@jwt_required()
def get_alerts():
    """
    Get all alerts for the authenticated user, ordered by newest first.
    
    Headers required:
    - Authorization: Bearer <jwt_token>
    
    Returns:
    - 200: List of alerts
    """
    user_id = get_jwt_identity()
    db = get_db()
    
    # Fetch all alerts for the user, newest first
    alerts = db.execute(
        '''SELECT id, type, title, message, is_read, created_at
           FROM alerts
           WHERE user_id = ?
           ORDER BY created_at DESC''',
        (user_id,)
    ).fetchall()
    
    # Convert to list of dictionaries
    alerts_list = []
    for alert in alerts:
        alerts_list.append({
            'id': alert['id'],
            'type': alert['type'],
            'title': alert['title'],
            'message': alert['message'],
            'is_read': bool(alert['is_read']),
            'created_at': alert['created_at']
        })
    
    return jsonify(alerts_list), 200


@bp.route('', methods=['POST'])
@jwt_required()
def create_alert():
    """
    Create a new alert.
    
    Request body (JSON):
    - type: string (required) - Alert type (e.g., "stress", "heart_rate", "motion")
    - title: string (required) - Alert title
    - message: string (optional) - Alert message/description
    
    Headers required:
    - Authorization: Bearer <jwt_token>
    
    Returns:
    - 201: Alert created successfully
    - 400: Invalid input
    """
    user_id = get_jwt_identity()
    data = request.get_json()
    
    # Validate required fields
    if not data or not data.get('type') or not data.get('title'):
        return jsonify({'error': 'Type and title are required'}), 400
    
    alert_type = data['type']
    title = data['title']
    message = data.get('message', '')
    
    db = get_db(current_app)
    
    # Insert new alert
    cursor = db.execute(
        '''INSERT INTO alerts (user_id, type, title, message)
           VALUES (?, ?, ?, ?)''',
        (user_id, alert_type, title, message)
    )
    
    alert_id = cursor.lastrowid
    db.commit()
    
    # Fetch and return the created alert
    alert = db.execute(
        '''SELECT id, type, title, message, is_read, created_at
           FROM alerts
           WHERE id = ?''',
        (alert_id,)
    ).fetchone()
    
    return jsonify({
        'message': 'Alert created successfully',
        'alert': {
            'id': alert['id'],
            'type': alert['type'],
            'title': alert['title'],
            'message': alert['message'],
            'is_read': bool(alert['is_read']),
            'created_at': alert['created_at']
        }
    }), 201


@bp.route('/<int:alert_id>/read', methods=['PUT'])
@jwt_required()
def mark_alert_read(alert_id):
    """
    Mark an alert as read.
    
    Path parameters:
    - alert_id: integer - ID of the alert to mark as read
    
    Headers required:
    - Authorization: Bearer <jwt_token>
    
    Returns:
    - 200: Alert marked as read
    - 404: Alert not found
    """
    user_id = get_jwt_identity()
    db = get_db(current_app)
    
    # Check if alert exists and belongs to the user
    alert = db.execute(
        'SELECT id FROM alerts WHERE id = ? AND user_id = ?',
        (alert_id, user_id)
    ).fetchone()
    
    if not alert:
        return jsonify({'error': 'Alert not found'}), 404
    
    # Mark as read
    db.execute(
        'UPDATE alerts SET is_read = 1 WHERE id = ?',
        (alert_id,)
    )
    db.commit()
    
    return jsonify({'message': 'Alert marked as read'}), 200
