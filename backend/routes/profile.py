"""
Profile Routes

This module handles user profile management endpoints.
"""

from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db

# Create a Blueprint for profile routes
# All routes in this file will be prefixed with /api/profile
bp = Blueprint('profile', __name__, url_prefix='/api/profile')


@bp.route('', methods=['GET'])
@jwt_required()
def get_profile():
    """
    Get the user's profile information (the monitored person's details).
    
    Headers required:
    - Authorization: Bearer <jwt_token>
    
    Returns:
    - 200: Profile information
    - 404: Profile not found
    """
    user_id = get_jwt_identity()
    db = get_db(current_app)
    
    # Fetch profile for the current user
    profile = db.execute(
        '''SELECT name, age, date_of_birth, relationship, 
                  emergency_contact_name, emergency_contact_phone
           FROM profiles
           WHERE user_id = ?''',
        (user_id,)
    ).fetchone()
    
    if profile:
        return jsonify({
            'name': profile['name'],
            'age': profile['age'],
            'date_of_birth': profile['date_of_birth'],
            'relationship': profile['relationship'],
            'emergency_contact_name': profile['emergency_contact_name'] or '',
            'emergency_contact_phone': profile['emergency_contact_phone'] or ''
        }), 200
    else:
        return jsonify({'error': 'Profile not found'}), 404


@bp.route('', methods=['PUT'])
@jwt_required()
def update_profile():
    """
    Update the user's profile information.
    
    Request body (JSON) - all fields optional:
    - name: string - Name of the monitored person
    - age: integer - Age of the monitored person
    - date_of_birth: string - Date of birth (YYYY-MM-DD format)
    - relationship: string - Relationship to the user (e.g., "Parent", "Caregiver")
    - emergency_contact_name: string - Emergency contact name
    - emergency_contact_phone: string - Emergency contact phone number
    
    Headers required:
    - Authorization: Bearer <jwt_token>
    
    Returns:
    - 200: Profile updated successfully with updated profile data
    - 400: Invalid input
    """
    user_id = get_jwt_identity()
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'Request body is required'}), 400
    
    db = get_db(current_app)
    
    # Build update query dynamically based on provided fields
    update_fields = []
    values = []
    
    allowed_fields = ['name', 'age', 'date_of_birth', 'relationship', 
                     'emergency_contact_name', 'emergency_contact_phone']
    
    for field in allowed_fields:
        if field in data:
            update_fields.append(f'{field} = ?')
            values.append(data[field])
    
    if not update_fields:
        return jsonify({'error': 'No valid fields to update'}), 400
    
    # Add user_id for WHERE clause
    values.append(user_id)
    
    # Execute update
    query = f"UPDATE profiles SET {', '.join(update_fields)} WHERE user_id = ?"
    db.execute(query, values)
    db.commit()
    
    # Fetch and return updated profile
    profile = db.execute(
        '''SELECT name, age, date_of_birth, relationship, 
                  emergency_contact_name, emergency_contact_phone
           FROM profiles
           WHERE user_id = ?''',
        (user_id,)
    ).fetchone()
    
    return jsonify({
        'message': 'Profile updated successfully',
        'profile': {
            'name': profile['name'],
            'age': profile['age'],
            'date_of_birth': profile['date_of_birth'],
            'relationship': profile['relationship'],
            'emergency_contact_name': profile['emergency_contact_name'] or '',
            'emergency_contact_phone': profile['emergency_contact_phone'] or ''
        }
    }), 200
