import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/services/ble/ble_service.dart';
import '../../../core/services/alert_service.dart';
import '../../../core/services/threshold_settings.dart';
import '../widgets/metric_card.dart';
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
  final BleService _bleService = BleService();

  ({String label, bool isConnected}) _appBarStatusForState(
    BleConnectionState state,
  ) {
    switch (state) {
      case BleConnectionState.connected:
        return (label: 'Wristband connected', isConnected: true);
      case BleConnectionState.connecting:
        return (label: 'Connecting to wristband...', isConnected: false);
      case BleConnectionState.scanning:
        return (label: 'Scanning for wristband...', isConnected: false);
      case BleConnectionState.error:
        return (label: 'Wristband error', isConnected: false);
      case BleConnectionState.disconnected:
      default:
        return (label: 'Wristband disconnected', isConnected: false);
    }
  }

  // ============ STATIC PATIENT DATA ==========
  // ============ STATIC PATIENT DATA (Tunisian) ============
  static const String patientName = "Yassine Ben Salah";
  static const int patientAge = 22;
  static const String patientCondition = "Heart Monitoring";
  // ========================================================
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppConstants.appBarHeight + 20),
        child: StreamBuilder<BleConnectionState>(
          stream: _bleService.connectionState,
          initialData: _bleService.currentState,
          builder: (context, snapshot) {
            final status = _appBarStatusForState(
              snapshot.data ?? BleConnectionState.disconnected,
            );

            return CustomAppBar(
              title: "$patientName's Monitor",
              showConnectionStatus: true,
              isConnected: status.isConnected,
              connectionStatus: status.label,
            );
          },
        ),
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

/// The actual dashboard content with LIVE sensor values from BLE
class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  // ============ DYNAMIC DATA (from ESP32) ============
  Map<String, String> _sensorValues = {}; // UUID -> formatted value
  bool _isReadingData = false;
  AlertEvent? _latestDangerAlert; // Track latest danger alert
  // ==================================================

  // ============ STATIC DATA (for demo) ============
  static const int batteryLevel = 85;
  // ================================================

  final BleService _bleService = BleService();
  final AlertService _alertService = AlertService();
  StreamSubscription<Map<String, String>>? _sensorSubscription;
  StreamSubscription<AlertEvent>? _alertSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToSensor();
    _subscribeToAlerts();
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _alertSubscription?.cancel();
    super.dispose();
  }

  /// Subscribe to sensor values stream from BleService
  void _subscribeToSensor() {
    // Initialize with current values
    _sensorValues = Map.from(_bleService.sensorValues);
    _isReadingData = _sensorValues.isNotEmpty;
    print('🏠 Dashboard: Initial sensor values: $_sensorValues');

    _sensorSubscription = _bleService.sensorValuesStream.listen((values) {
      print('🏠 Dashboard: Received sensor update: $values');
      if (mounted) {
        setState(() {
          _sensorValues = values;
          _isReadingData = values.isNotEmpty;
        });
        print('🏠 Dashboard: Updated - RMS: ${values['rms']}, BPM: ${values['bpm']}, State: ${values['state']}');
      }
    });
  }

  /// Subscribe to alert stream for danger alerts
  void _subscribeToAlerts() {
    _alertSubscription = _alertService.alertStream.listen((alert) {
      if (mounted && alert.severity == AlertSeverity.danger) {
        setState(() {
          _latestDangerAlert = alert;
        });
        // Auto-dismiss after 10 seconds
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted && _latestDangerAlert?.id == alert.id) {
            setState(() {
              _latestDangerAlert = null;
            });
          }
        });
      }
    });
  }

  /// Get RMS value from sensor values
  String get _rmsValue {
    return _sensorValues['rms'] ?? '-';
  }

  /// Get noise status based on RMS value and configurable thresholds
  /// Status is determined locally using ThresholdSettings
  String get _noiseStatus {
    final rmsString = _sensorValues['rms'] ?? '-';
    if (rmsString == '-') return 'Unknown';

    final rms = double.tryParse(rmsString);
    if (rms == null) return 'Unknown';

    // Use configurable thresholds to determine status
    return ThresholdSettings().getNoiseStatus(rms);
  }

  /// Get color for noise status
  Color get _noiseStatusColor {
    final status = _noiseStatus.toUpperCase();
    if (status.contains('DANGER')) return AppColors.dangerRed;
    if (status.contains('MODER') || status.contains('MODÉRÉ')) return AppColors.warningYellow;
    if (status.contains('CALME') || status.contains('CALM')) return AppColors.successGreen;
    return AppColors.textSecondary;
  }

  /// Get heart rate (BPM) value from sensor values
  String get _heartRateValue {
    return _sensorValues['bpm'] ?? '-';
  }

  /// Get heart rate status based on configurable thresholds
  String get _heartRateStatus {
    final bpmString = _sensorValues['bpm'] ?? '-';
    if (bpmString == '-') return 'Unknown';

    final bpm = double.tryParse(bpmString);
    if (bpm == null) return 'Unknown';

    return ThresholdSettings().getHeartRateStatus(bpm);
  }

  /// Get gyroscope value from sensor values
  String get _gyroValue {
    return _sensorValues['gyro'] ?? '-';
  }

  /// Get accelerometer value from sensor values
  String get _accValue {
    return _sensorValues['acc'] ?? '-';
  }

  /// Get motion state from sensor values (Chute, Marche, etc.)
  String get _motionState {
    return _sensorValues['state'] ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.paddingMedium),

          // DANGER ALERT BANNER (shows when noise exceeds danger threshold)
          if (_latestDangerAlert != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.dangerRed,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dangerRed.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _latestDangerAlert!.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _latestDangerAlert!.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _latestDangerAlert = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          if (_latestDangerAlert != null)
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
                  _isReadingData
                      ? 'Live data from wristband'
                      : 'Connecting to wristband...',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Metrics Grid
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
                // 📊 DYNAMIC NOISE STATUS FROM ESP32!
                MetricCard(
                  label: 'Noise Level',
                  value: _noiseStatus,
                  icon: Icons.volume_up_rounded,
                  valueColor: _noiseStatusColor,
                ),
                // 📊 DYNAMIC HEART RATE FROM ESP32!
                MetricCard(
                  label: 'Heart Rate',
                  value: _heartRateValue,
                  unit: 'BPM',
                  icon: Icons.favorite_rounded,
                  valueColor: _getHeartRateColor(_heartRateValue),
                ),
                // 📊 DYNAMIC MOTION STATE FROM ESP32!
                MetricCard(
                  label: 'Motion',
                  value: _motionState,
                  icon: Icons.directions_walk_rounded,
                  valueColor: _getMotionStateColor(_motionState),
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
                  'Noise Level',
                  'Measures ambient sound from the audio sensor. Calm = safe, Moderate = caution, DANGER = excessive noise.',
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildMetricInfo(
                  'Heart Rate',
                  'Monitors heart rate in beats per minute (BPM). Normal range: 60-100 BPM.',
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildMetricInfo(
                  'Motion',
                  'Detects movement patterns using accelerometer data.',
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildMetricInfo(
                  'Battery',
                  'Shows remaining wristband battery percentage.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
        ],
      ),
    );
  }

  /// Get color based on noise level value (String)
  Color _getSensorValueColor(String value) {
    final intValue = int.tryParse(value) ?? 0;
    // For noise level (in dB): green if low, red if high
    if (intValue < 60) return AppColors.successGreen; // Quiet
    if (intValue > 80) return AppColors.dangerRed; // Too loud
    return AppColors.warningYellow; // Moderate
  }

  /// Get color based on heart rate value (String)
  Color _getHeartRateColor(String value) {
    final doubleValue = double.tryParse(value) ?? 0;
    // For heart rate: green if normal, red if too high/low
    if (doubleValue == 0) return AppColors.textSecondary; // No data
    if (doubleValue < ThresholdSettings().heartRateLowThreshold) return AppColors.warningYellow; // Low
    if (doubleValue > ThresholdSettings().heartRateHighThreshold) return AppColors.dangerRed; // High
    return AppColors.successGreen; // Normal
  }

  /// Get color based on motion state
  Color _getMotionStateColor(String state) {
    final upper = state.toUpperCase();
    if (upper.contains('CHUTE') || upper.contains('FALL')) {
      return AppColors.dangerRed; // Fall detected - danger!
    }
    if (upper.contains('COURSE') || upper.contains('RUN')) {
      return AppColors.warningYellow; // Running
    }
    if (upper.contains('MARCHE') || upper.contains('WALK')) {
      return AppColors.primaryBlue; // Walking
    }
    if (upper.contains('REPOS') || upper.contains('REST') || upper.contains('IDLE') || upper.contains('OK')) {
      return AppColors.successGreen; // Resting / OK
    }
    return AppColors.textSecondary; // Unknown
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
