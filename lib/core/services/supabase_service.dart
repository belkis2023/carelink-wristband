import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class to initialize and manage Supabase connection
class SupabaseService {
  // Supabase project credentials
  static const String _supabaseUrl = 'https://rlybwycnxarprahcdxie.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJseWJ3eWNueGFycHJhaGNkeGllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ5MTI3MTksImV4cCI6MjA4MDQ4ODcxOX0.uuaInPWW4QMPoH3TfJG1bx_48VITcVV_BiG4G9mhwSk';

  /// Initialize Supabase - call this in main.dart before runApp()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current user (null if not logged in)
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;
}
