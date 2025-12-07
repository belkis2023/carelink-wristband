import 'dart:convert';
import 'package:http/http.dart' as http;

class CareLinkApi {
  static const String baseUrl = "http://127.0.0.1:5000/auth";

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
    return jsonDecode(res.body);
  }

  // Get Profile (token required)
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }
}
