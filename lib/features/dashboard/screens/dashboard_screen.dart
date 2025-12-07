import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../widgets/stress_level_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/haptic_toggle_card.dart';
import '../../history/screens/history_screen.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../settings/screens/settings_screen.dart';

/// The main dashboard screen showing real-time monitoring data.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Current tab index for bottom navigation
  int _currentIndex = 0;

  // ============ STATIC PATIENT DATA ============
  // ============ STATIC PATIENT DATA (Tunisian) ============
  static const String patientName = "Fatma Ben Ali"; // ← Changed!
  static const int patientAge = 68;
  static const String patientCondition = "Heart Monitoring";
  // ========================================================
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "$patientName's Monitor",
        showConnectionStatus: true,
        isConnected: true, // We just connected, so show as connected
        connectionStatus: 'Wristband connected',
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardContent(),
          HistoryScreen(),
          AlertsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

/// The actual dashboard content with LIVE heart rate from BLE
class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  // ============ DYNAMIC DATA (from ESP32) ============
  int _heartRate = 72; // Will update from BLE
  bool _isReadingHeartRate = false;
  // ==================================================

  // ============ STATIC DATA (for demo) ============
  static const double stressLevel = 4.2;
  static const String stressStatus = "Low";
  static const String motionStatus = "Resting";
  static const int noiseLevel = 42;
  static const int batteryLevel = 85;
  // ================================================

  StreamSubscription? _heartRateSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToHeartRate();
  }

  @override
  void dispose() {
    _heartRateSubscription?.cancel();
    super.dispose();
  }

  /// Subscribe to heart rate notifications from connected BLE device
  Future<void> _subscribeToHeartRate() async {
    try {
      // Get list of connected devices
      final connectedDevices = FlutterBluePlus.connectedDevices;

      if (connectedDevices.isEmpty) {
        print('❌ No connected devices');
        return;
      }

      final device = connectedDevices.first;
      print('📱 Connected to: ${device.platformName}');

      // Discover services
      final services = await device.discoverServices();
      print('🔍 Found ${services.length} services');

      for (var service in services) {
        print('  Service: ${service.uuid}');

        for (var characteristic in service.characteristics) {
          print(
            '    Char: ${characteristic.uuid} - notify: ${characteristic.properties.notify}',
          );

          // Look for Heart Rate Measurement characteristic (standard UUID)
          // OR any characteristic that can notify (for custom ESP32 implementations)
          final uuid = characteristic.uuid.toString().toLowerCase();

          // Standard Heart Rate Measurement UUID: 00002a37-...
          // You can also add your custom ESP32 UUID here
          if (uuid.contains('2a37') || characteristic.properties.notify) {
            try {
              await characteristic.setNotifyValue(true);
              print('✅ Subscribed to: ${characteristic.uuid}');

              setState(() {
                _isReadingHeartRate = true;
              });

              _heartRateSubscription = characteristic.onValueReceived.listen((
                value,
              ) {
                if (value.isNotEmpty) {
                  // Parse heart rate value
                  int hr = _parseHeartRate(value);
                  print('❤️ Heart Rate: $hr BPM');

                  setState(() {
                    _heartRate = hr;
                  });
                }
              });

              // Only subscribe to first matching characteristic
              return;
            } catch (e) {
              print('⚠️ Could not subscribe to ${characteristic.uuid}: $e');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error subscribing to heart rate: $e');
    }
  }

  /// Parse heart rate from BLE characteristic value
  int _parseHeartRate(List<int> value) {
    if (value.isEmpty) return _heartRate;

    // Standard Heart Rate Measurement format:
    // Byte 0: Flags (bit 0 = 0 means HR is uint8, bit 0 = 1 means HR is uint16)
    // Byte 1: Heart Rate value (uint8) or Bytes 1-2: Heart Rate value (uint16)

    final flags = value[0];
    final isUint16 = (flags & 0x01) != 0;

    if (isUint16 && value.length >= 3) {
      // uint16 little-endian
      return value[1] | (value[2] << 8);
    } else if (value.length >= 2) {
      // uint8
      return value[1];
    } else {
      // Fallback: just use first byte as heart rate (custom format)
      return value[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.paddingMedium),

          // Current Status Section Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Status', style: AppTextStyles.heading2),
                const SizedBox(height: 4),
                Text(
                  _isReadingHeartRate
                      ? 'Live data from wristband'
                      : 'Connecting to wristband...',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Stress Level Card (STATIC)
          const StressLevelCard(stressLevel: stressLevel, status: stressStatus),
          const SizedBox(height: AppConstants.paddingMedium),

          // Metrics Grid (Heart Rate is DYNAMIC, others are STATIC)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppConstants.paddingMedium,
              crossAxisSpacing: AppConstants.paddingMedium,
              childAspectRatio: 0.9,
              children: [
                // ❤️ DYNAMIC HEART RATE FROM ESP32!
                MetricCard(
                  label: 'Heart Rate',
                  value: '$_heartRate',
                  unit: 'BPM',
                  icon: Icons.favorite_rounded,
                  valueColor: _getHeartRateColor(_heartRate),
                ),
                // Static metrics below
                const MetricCard(
                  label: 'Motion',
                  value: motionStatus,
                  icon: Icons.directions_walk_rounded,
                ),
                const MetricCard(
                  label: 'Noise Level',
                  value: '$noiseLevel',
                  unit: 'dB',
                  icon: Icons.volume_up_rounded,
                ),
                const MetricCard(
                  label: 'Battery',
                  value: '$batteryLevel',
                  unit: '%',
                  icon: Icons.battery_5_bar_rounded,
                  valueColor: AppColors.successGreen,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Haptic Feedback Toggle
          const HapticToggleCard(),
          const SizedBox(height: AppConstants.paddingLarge),

          // About These Metrics Section
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryBlue,
                      size: AppConstants.iconMedium,
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text('About These Metrics', style: AppTextStyles.heading3),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildMetricInfo(
                  'Stress Level (GSR)',
                  'Measures skin conductance to detect stress and emotional responses. Scale: 0-10.',
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildMetricInfo(
                  'Heart Rate',
                  'Tracks beats per minute (BPM) from the wristband sensor.  Normal range: 60-100 BPM.',
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildMetricInfo(
                  'Motion',
                  'Detects movement patterns using accelerometer data.',
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildMetricInfo(
                  'Noise Level',
                  'Measures ambient sound in decibels (dB) to assess environmental conditions.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
        ],
      ),
    );
  }

  /// Get color based on heart rate value
  Color _getHeartRateColor(int hr) {
    if (hr < 60) return AppColors.dangerRed; // Too low
    if (hr > 100) return AppColors.dangerRed; // Too high
    return AppColors.successGreen; // Normal
  }

  /// Helper widget to build metric information rows
  Widget _buildMetricInfo(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(description, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
