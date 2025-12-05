import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/alerts/screens/alerts_screen.dart';
import '../features/settings/screens/settings_screen.dart';

/// This class manages all navigation routes in the CareLink Wristband app.
/// It provides a centralized location for route names and routing logic.
class AppRouter {
  // Route names - Used to navigate between screens
  static const String login = '/';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String alerts = '/alerts';
  static const String settings = '/settings';

  /// Generates routes based on the route name
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case alerts:
        return MaterialPageRoute(builder: (_) => const AlertsScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        // Return a default error page if route is not found
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}

/// A widget that manages the bottom navigation and displays the appropriate screen.
/// This is used after login to provide navigation between the 4 main screens.
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  // Currently selected tab index (0 = Dashboard, 1 = History, 2 = Alerts, 3 = Settings)
  int _currentIndex = 0;

  // List of screens corresponding to each tab
  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Display the current screen based on selected tab
    return _screens[_currentIndex];
  }

  /// Updates the current tab index when a navigation item is tapped
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
