import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'alert_service.dart';

/// Service to handle push notifications for alerts
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  /// Call this in main.dart before runApp
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+
    if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    }

    _isInitialized = true;
    print('🔔 NotificationService initialized');
  }

  /// Request notification permissions for Android 13+
  Future<void> _requestAndroidPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    // You can navigate to a specific screen based on payload
  }

  /// Show a notification for an alert
  Future<void> showAlertNotification(AlertEvent alert) async {
    if (!_isInitialized) {
      print('🔔 NotificationService not initialized');
      return;
    }

    // Define notification details based on severity
    final (icon, color, priority) = _getNotificationStyle(alert.severity);

    final androidDetails = AndroidNotificationDetails(
      'carelink_alerts', // Channel ID
      'CareLink Alerts', // Channel name
      channelDescription: 'Notifications for health and noise alerts',
      importance: Importance.high,
      priority: priority,
      icon: icon,
      color: color,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        alert.description,
        contentTitle: alert.title,
        summaryText: _getSeverityText(alert.severity),
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use timestamp as unique ID
    final notificationId = alert.timestamp.millisecondsSinceEpoch ~/ 1000;

    await _notifications.show(
      notificationId,
      alert.title,
      alert.description,
      details,
      payload: alert.id,
    );

    print('🔔 Notification shown: ${alert.title}');
  }

  /// Get notification style based on severity
  (String, Color, Priority) _getNotificationStyle(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.danger:
        return ('@mipmap/ic_launcher', const Color(0xFFE74C3C), Priority.max);
      case AlertSeverity.warning:
        return ('@mipmap/ic_launcher', const Color(0xFFF39C12), Priority.high);
      case AlertSeverity.success:
        return ('@mipmap/ic_launcher', const Color(0xFF27AE60), Priority.defaultPriority);
      case AlertSeverity.info:
        return ('@mipmap/ic_launcher', const Color(0xFF3498DB), Priority.defaultPriority);
    }
  }

  /// Get severity text for notification
  String _getSeverityText(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.danger:
        return '⚠️ DANGER ALERT';
      case AlertSeverity.warning:
        return '⚡ Warning';
      case AlertSeverity.success:
        return '✅ OK';
      case AlertSeverity.info:
        return 'ℹ️ Info';
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}

