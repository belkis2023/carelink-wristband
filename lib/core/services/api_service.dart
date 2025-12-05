import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for communicating with the Flask backend API.
/// Handles authentication, data fetching, and token management.
class ApiService {
  // Base URL for the Flask API
  // Note: Use different URLs based on your development environment:
  // - Android Emulator: 'http://10.0.2.2:5000/api' (maps to host's localhost)
  // - iOS Simulator: 'http://127.0.0.1:5000/api'
  // - Physical Device: 'http://YOUR_COMPUTER_IP:5000/api' (e.g., 'http://192.168.1.100:5000/api')
  // 
  // TODO: Consider using environment configuration or a config file for production
  // to manage different base URLs across environments.
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // Private variable to store the JWT token in memory
  static String? _token;
  
  // Key for storing token in SharedPreferences
  static const String _tokenKey = 'jwt_token';

  /// Sign up a new user
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password (min 6 characters)
  /// - [fullName]: User's full name (optional)
  /// 
  /// Returns a Map containing the access token and user info
  /// Throws an exception if signup fails
  Future<Map<String, dynamic>> signup(String email, String password, String? fullName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Save token after successful signup
        await saveToken(data['access_token']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Log in an existing user
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// 
  /// Returns a Map containing the access token and user info
  /// Throws an exception if login fails
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save token after successful login
        await saveToken(data['access_token']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Log out the current user
  /// Clears the stored token
  Future<void> logout() async {
    try {
      // Get token for authenticated request
      final token = await getToken();
      
      if (token != null) {
        // Call logout endpoint (optional, for server-side cleanup)
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      // Even if logout request fails, we still clear the local token
      debugPrint('Logout request failed: $e');
    } finally {
      // Always clear the token locally
      await clearToken();
    }
  }

  /// Get current user information
  /// 
  /// Returns user data from the backend
  /// Throws an exception if request fails or token is invalid
  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user info');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Get dashboard metrics (sensor readings)
  /// 
  /// Returns the latest readings or mock data if none exist
  /// Throws an exception if request fails
  Future<Map<String, dynamic>> getMetrics() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/metrics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get metrics');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Save a new sensor reading
  /// 
  /// Parameters:
  /// - [data]: Map containing sensor data (heart_rate, motion, noise_level, stress_level, battery)
  /// 
  /// This will be used when BLE functionality is added
  Future<void> saveReading(Map<String, dynamic> data) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/readings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to save reading');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Get user profile information
  /// 
  /// Returns profile data (name, age, relationship, etc.)
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get profile');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Update user profile information
  /// 
  /// Parameters:
  /// - [data]: Map containing profile fields to update
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Get all alerts for the current user
  /// 
  /// Returns a list of alerts
  Future<List<dynamic>> getAlerts() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alerts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get alerts');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Mark an alert as read
  /// 
  /// Parameters:
  /// - [alertId]: ID of the alert to mark as read
  Future<void> markAlertRead(int alertId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/alerts/$alertId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark alert as read');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Token Management Methods

  /// Save JWT token to SharedPreferences and memory
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get JWT token from memory or SharedPreferences
  Future<String?> getToken() async {
    // Return from memory if available
    if (_token != null) {
      return _token;
    }
    
    // Otherwise, retrieve from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    return _token;
  }

  /// Clear JWT token from memory and SharedPreferences
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Check if user is logged in (has valid token)
  /// 
  /// Returns true if a token exists, false otherwise
  /// Note: This doesn't verify if the token is still valid
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
