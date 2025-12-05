import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../navigation/app_router.dart';

/// Enum for connection states
enum WristbandConnectionState {
  searching,
  connected,
  notFound,
}

/// Screen for testing wristband connectivity.
/// This appears after login/signup and allows users to connect their wristband.
/// 
/// Current behavior (without BLE):
/// - Simulates searching for 2 seconds
/// - Shows "Skip for Now" button to proceed to dashboard
/// 
/// Future behavior (with BLE):
/// - Actually scans for Bluetooth devices
/// - Connects to the CareLink wristband
/// - Shows connection status
class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  // Connection states
  WristbandConnectionState _connectionState = WristbandConnectionState.searching;
  
  @override
  void initState() {
    super.initState();
    _simulateConnectionSearch();
  }

  /// Simulates searching for the wristband
  /// In the future, this will be replaced with actual BLE scanning
  Future<void> _simulateConnectionSearch() async {
    setState(() {
      _connectionState = WristbandConnectionState.searching;
    });

    // Simulate a 2-second search
    await Future.delayed(const Duration(seconds: 2));

    // For now, we don't connect automatically
    // User must click "Skip for Now" or "Try Again"
    // When BLE is added, this will actually try to connect
    
    // Optionally, you can simulate a failure state:
    if (mounted) {
      setState(() {
        _connectionState = WristbandConnectionState.notFound;
      });
    }
  }

  /// Navigate to dashboard
  void _goToDashboard() {
    Navigator.of(context).pushReplacementNamed(AppRouter.dashboard);
  }

  /// Retry connection
  void _retryConnection() {
    _simulateConnectionSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Wristband Setup',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Wristband Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.watch_rounded,
                  size: 60,
                  color: _getIconColor(),
                ),
              ),
              const SizedBox(height: AppConstants.paddingXLarge),

              // Status Text
              Text(
                _getStatusText(),
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Status Indicator
              _buildStatusIndicator(),
              const SizedBox(height: AppConstants.paddingLarge),

              // Helper Text
              Text(
                _getHelperText(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: AppConstants.paddingMedium),

              // Skip Button (always visible)
              OutlinedButton(
                onPressed: _goToDashboard,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
                child: const Text('Skip for Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the status indicator based on connection state
  Widget _buildStatusIndicator() {
    switch (_connectionState) {
      case WristbandConnectionState.searching:
        return const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        );
      case WristbandConnectionState.connected:
        return Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.successGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 36,
          ),
        );
      case WristbandConnectionState.notFound:
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.warningOrange.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.bluetooth_disabled_rounded,
            color: AppColors.warningOrange,
            size: 36,
          ),
        );
    }
  }

  /// Build action buttons based on connection state
  Widget _buildActionButtons() {
    switch (_connectionState) {
      case WristbandConnectionState.searching:
        // No action button while searching
        return const SizedBox.shrink();
      case WristbandConnectionState.connected:
        return ElevatedButton(
          onPressed: _goToDashboard,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          child: const Text('Continue to Dashboard'),
        );
      case WristbandConnectionState.notFound:
        return ElevatedButton.icon(
          onPressed: _retryConnection,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
        );
    }
  }

  /// Get status text based on connection state
  String _getStatusText() {
    switch (_connectionState) {
      case WristbandConnectionState.searching:
        return 'Searching for Wristband...';
      case WristbandConnectionState.connected:
        return 'Connected!';
      case WristbandConnectionState.notFound:
        return 'Wristband Not Found';
    }
  }

  /// Get helper text based on connection state
  String _getHelperText() {
    switch (_connectionState) {
      case WristbandConnectionState.searching:
        return 'Make sure your CareLink wristband\nis powered on and within range.';
      case WristbandConnectionState.connected:
        return 'Your wristband is connected and ready.\nYou can now monitor in real-time.';
      case WristbandConnectionState.notFound:
        return 'Could not find your wristband.\nMake sure Bluetooth is enabled and\nthe wristband is nearby.';
    }
  }

  /// Get icon color based on connection state
  Color _getIconColor() {
    switch (_connectionState) {
      case WristbandConnectionState.searching:
        return AppColors.primaryBlue;
      case WristbandConnectionState.connected:
        return AppColors.successGreen;
      case WristbandConnectionState.notFound:
        return AppColors.warningOrange;
    }
  }
}
