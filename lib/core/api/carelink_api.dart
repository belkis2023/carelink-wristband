import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CareLinkApi {
  static const String baseUrl = "http://10.47.176.9:5000/auth";

  // Key for storing token
  static const String _tokenKey = 'jwt_token';

  // In-memory token cache
  static String? _token;

  // Save token to local storage
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token from memory or local storage
  static Future<String?> getToken() async {
    if (_token != null) return _token;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    return _token;
  }

  // Clear token (for logout)
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Signup
  static Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final response = jsonDecode(res.body);

    // Save token if login successful
    if (response["token"] != null) {
      await saveToken(response["token"]);
    }

    return response;
  }

  // Get Profile (token required)
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  // Update Profile (token required)
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final token = await getToken();

    if (token == null) {
      return {"error": "Not authenticated"};
    }

    final res = await http.put(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }
}
