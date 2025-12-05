import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/api_service.dart';
import 'navigation/app_router.dart';

/// The main entry point of the CareLink Wristband app.
/// This function initializes and runs the Flutter application.
void main() async {
  // IMPORTANT: This must be called before using any plugins (like SharedPreferences)
  WidgetsFlutterBinding. ensureInitialized();
  
  runApp(const CareLinkApp());
}

/// The root widget of the CareLink Wristband application.
/// This widget sets up the app theme, routes, and initial screen.
class CareLinkApp extends StatefulWidget {
  const CareLinkApp({super.key});

  @override
  State<CareLinkApp> createState() => _CareLinkAppState();
}

class _CareLinkAppState extends State<CareLinkApp> {
  // API service for checking authentication status
  final _apiService = ApiService();
  
  // Track whether we're checking authentication
  bool _isCheckingAuth = true;
  
  // Initial route based on authentication status
  String _initialRoute = AppRouter.login;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  /// If logged in, start at dashboard; otherwise start at login
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      if (mounted) {
        setState(() {
          _initialRoute = isLoggedIn ? AppRouter.dashboard : AppRouter.login;
          _isCheckingAuth = false;
        });
      }
    } catch (e) {
      // If there's an error, default to login screen
      if (mounted) {
        setState(() {
          _initialRoute = AppRouter.login;
          _isCheckingAuth = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking authentication
    if (_isCheckingAuth) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      // App title shown in task switcher
      title: AppConstants.appName,

      // Apply custom theme
      theme: AppTheme.lightTheme,

      // Remove debug banner in top-right corner
      debugShowCheckedModeBanner: false,

      // Set initial route based on authentication status
      initialRoute: _initialRoute,

      // Generate routes based on route names
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}