import 'dart:async';
import 'notification_service.dart';
import 'threshold_settings.dart';

/// Alert severity levels matching the AlertType enum in widgets
enum AlertSeverity { danger, warning, success, info }

/// Represents a single alert event
class AlertEvent {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final AlertSeverity severity;
  final bool isUnread;
  final String? rawValue; // The raw sensor value that triggered the alert

  AlertEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    this.isUnread = true,
    this.rawValue,
  });

  /// Create a copy with updated fields
  AlertEvent copyWith({bool? isUnread}) {
    return AlertEvent(
      id: id,
      title: title,
      description: description,
      timestamp: timestamp,
      severity: severity,
      isUnread: isUnread ?? this.isUnread,
      rawValue: rawValue,
    );
  }

  /// Format timestamp as relative time
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}

/// Service to manage alerts from sensor data
class AlertService {
  // Singleton pattern
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  // Stream controller for new alerts
  final _alertController = StreamController<AlertEvent>.broadcast();
  Stream<AlertEvent> get alertStream => _alertController.stream;

  // Store all alerts
  final List<AlertEvent> _alerts = [];
  List<AlertEvent> get alerts => List.unmodifiable(_alerts);

  // Use ThresholdSettings for configurable thresholds
  final ThresholdSettings _thresholdSettings = ThresholdSettings();

  // Debounce: don't spam alerts
  DateTime? _lastNoiseAlert;
  DateTime? _lastHeartRateAlert;
  static const _alertCooldown = Duration(seconds: 30);

  /// Process noise data from BLE
  /// The format from ESP32 is: "RMS | Status" (e.g., "1234 | Calme")
  void processNoiseData(String rawValue) {
    // Parse the value - format is "RMS | Status"
    final parts = rawValue.split('|').map((s) => s.trim()).toList();
    if (parts.isEmpty) return;

    // Try to extract numeric RMS value
    final rmsString = parts[0].replaceAll(RegExp(r'[^0-9.]'), '');
    final rms = double.tryParse(rmsString);
    if (rms == null) return;

    // Use configurable thresholds
    final isDanger = _thresholdSettings.isNoiseDanger(rms);
    final isWarning = _thresholdSettings.isNoiseWarning(rms);

    if (isDanger) {
      _triggerNoiseAlert(
        severity: AlertSeverity.danger,
        title: '⚠️ Noise Danger Alert!',
        description: 'Extreme noise level detected: ${rms.toStringAsFixed(0)} RMS. '
            'Please move to a quieter area immediately.',
        rawValue: rawValue,
      );
    } else if (isWarning) {
      _triggerNoiseAlert(
        severity: AlertSeverity.warning,
        title: 'High Noise Level',
        description: 'Moderate noise level: ${rms.toStringAsFixed(0)} RMS. '
            'Consider reducing exposure.',
        rawValue: rawValue,
      );
    }
  }

  /// Process heart rate data from BLE
  void processHeartRateData(String rawValue) {
    final bpm = double.tryParse(rawValue);
    if (bpm == null || bpm <= 0) return;

    final isAbnormal = _thresholdSettings.isHeartRateAbnormal(bpm);
    if (!isAbnormal) return;

    final isLow = bpm < _thresholdSettings.heartRateLowThreshold;
    final isHigh = bpm > _thresholdSettings.heartRateHighThreshold;

    if (isHigh) {
      _triggerHeartRateAlert(
        severity: AlertSeverity.danger,
        title: '⚠️ High Heart Rate!',
        description: 'Heart rate is elevated: ${bpm.toStringAsFixed(0)} BPM. '
            'Please rest and monitor.',
        rawValue: rawValue,
      );
    } else if (isLow) {
      _triggerHeartRateAlert(
        severity: AlertSeverity.warning,
        title: 'Low Heart Rate',
        description: 'Heart rate is low: ${bpm.toStringAsFixed(0)} BPM. '
            'Please check on the patient.',
        rawValue: rawValue,
      );
    }
  }

  /// Trigger a noise-related alert with debouncing
  void _triggerNoiseAlert({
    required AlertSeverity severity,
    required String title,
    required String description,
    String? rawValue,
  }) {
    // Check cooldown to avoid spamming
    final now = DateTime.now();
    if (_lastNoiseAlert != null &&
        now.difference(_lastNoiseAlert!) < _alertCooldown) {
      return; // Still in cooldown period
    }

    _lastNoiseAlert = now;
    _createAndSendAlert(id: 'noise_${now.millisecondsSinceEpoch}', title: title, description: description, severity: severity, rawValue: rawValue);
  }

  /// Trigger a heart rate alert with debouncing
  void _triggerHeartRateAlert({
    required AlertSeverity severity,
    required String title,
    required String description,
    String? rawValue,
  }) {
    // Check cooldown to avoid spamming
    final now = DateTime.now();
    if (_lastHeartRateAlert != null &&
        now.difference(_lastHeartRateAlert!) < _alertCooldown) {
      return; // Still in cooldown period
    }

    _lastHeartRateAlert = now;
    _createAndSendAlert(id: 'hr_${now.millisecondsSinceEpoch}', title: title, description: description, severity: severity, rawValue: rawValue);
  }

  /// Create and send an alert
  void _createAndSendAlert({
    required String id,
    required String title,
    required String description,
    required AlertSeverity severity,
    String? rawValue,
  }) {
    final now = DateTime.now();
    final alert = AlertEvent(
      id: id,
      title: title,
      description: description,
      timestamp: now,
      severity: severity,
      rawValue: rawValue,
    );

    _alerts.insert(0, alert); // Add to front (newest first)
    _alertController.add(alert);

    // Show push notification
    NotificationService().showAlertNotification(alert);

    print('🚨 ALERT: $title - $rawValue');
  }

  /// Add a custom alert
  void addAlert(AlertEvent alert) {
    _alerts.insert(0, alert);
    _alertController.add(alert);
  }

  /// Mark an alert as read
  void markAsRead(String alertId) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isUnread: false);
    }
  }

  /// Mark all alerts as read
  void markAllAsRead() {
    for (var i = 0; i < _alerts.length; i++) {
      _alerts[i] = _alerts[i].copyWith(isUnread: false);
    }
  }

  /// Get unread alert count
  int get unreadCount => _alerts.where((a) => a.isUnread).length;

  /// Clear all alerts
  void clearAlerts() {
    _alerts.clear();
  }

  /// Dispose
  void dispose() {
    _alertController.close();
  }
}

