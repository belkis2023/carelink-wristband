import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_colors.dart';
import 'core/services/api_service.dart';
import 'navigation/app_router.dart';

/// The main entry point of the CareLink Wristband app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CareLinkApp());
}

/// The root widget of the CareLink Wristband application.
class CareLinkApp extends StatefulWidget {
  const CareLinkApp({super.key});

  @override
  State<CareLinkApp> createState() => _CareLinkAppState();
}

class _CareLinkAppState extends State<CareLinkApp> {
  final _apiService = ApiService();
  bool _isCheckingAuth = true;
  String _initialRoute = AppRouter.login;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

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
      return MaterialApp(   // ← REMOVED "const" here! 
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: _initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}