import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'navigation/app_router.dart';

/// The main entry point of the CareLink Wristband app.
/// This function initializes and runs the Flutter application.
void main() {
  runApp(const CareLinkApp());
}

/// The root widget of the CareLink Wristband application.
/// This widget sets up the app theme, routes, and initial screen.
class CareLinkApp extends StatelessWidget {
  const CareLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title shown in task switcher
      title: AppConstants.appName,

      // Apply custom theme
      theme: AppTheme.lightTheme,

      // Remove debug banner in top-right corner
      debugShowCheckedModeBanner: false,

      // Set initial route to login screen
      initialRoute: AppRouter.login,

      // Generate routes based on route names
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
