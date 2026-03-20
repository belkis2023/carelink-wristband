import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/alert_service.dart';
import '../widgets/alert_threshold_card.dart';
import '../widgets/alert_item_card.dart';

/// The alerts screen showing all notifications and alert thresholds.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertService _alertService = AlertService();
  StreamSubscription<AlertEvent>? _alertSubscription;
  List<AlertEvent> _liveAlerts = [];

  @override
  void initState() {
    super.initState();
    _liveAlerts = List.from(_alertService.alerts);
    _alertSubscription = _alertService.alertStream.listen((alert) {
      if (mounted) {
        setState(() {
          // Add new alert to the front
          _liveAlerts.insert(0, alert);
        });
        // Show a snackbar for immediate feedback
        _showAlertSnackbar(alert);
      }
    });
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    super.dispose();
  }

  void _showAlertSnackbar(AlertEvent alert) {
    final color = _getColorForSeverity(alert.severity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getIconForSeverity(alert.severity), color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(alert.description, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getColorForSeverity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.danger:
        return AppColors.dangerRed;
      case AlertSeverity.warning:
        return AppColors.warningYellow;
      case AlertSeverity.success:
        return AppColors.successGreen;
      case AlertSeverity.info:
        return AppColors.primaryBlue;
    }
  }

  IconData _getIconForSeverity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.danger:
        return Icons.warning_rounded;
      case AlertSeverity.warning:
        return Icons.error_outline_rounded;
      case AlertSeverity.success:
        return Icons.check_circle_outline_rounded;
      case AlertSeverity.info:
        return Icons.info_outline_rounded;
    }
  }

  AlertType _toAlertType(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.danger:
        return AlertType.danger;
      case AlertSeverity.warning:
        return AlertType.warning;
      case AlertSeverity.success:
        return AlertType.success;
      case AlertSeverity.info:
        return AlertType.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separate live alerts into unread and read
    final unreadAlerts = _liveAlerts.where((a) => a.isUnread).toList();
    final readAlerts = _liveAlerts.where((a) => !a.isUnread).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.paddingMedium),

          // Alert Thresholds Info Card
          const AlertThresholdCard(),
          const SizedBox(height: AppConstants.paddingLarge),

          // Live Alerts Section (from BLE)
          if (_liveAlerts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Alerts (${unreadAlerts.length} new)',
                    style: AppTextStyles.heading3,
                  ),
                  if (unreadAlerts.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _alertService.markAllAsRead();
                        setState(() {
                          _liveAlerts = List.from(_alertService.alerts);
                        });
                      },
                      child: const Text('Mark all read'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            // Live alert items
            ...unreadAlerts.map((alert) => AlertItemCard(
              title: alert.title,
              description: alert.description,
              timestamp: alert.relativeTime,
              type: _toAlertType(alert.severity),
              isUnread: true,
            )),

            if (readAlerts.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                child: Text('Earlier', style: AppTextStyles.heading3),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              ...readAlerts.take(5).map((alert) => AlertItemCard(
                title: alert.title,
                description: alert.description,
                timestamp: alert.relativeTime,
                type: _toAlertType(alert.severity),
                isUnread: false,
              )),
            ],

            const SizedBox(height: AppConstants.paddingLarge),
          ],

          // Demo/Static Alerts Section (commented out for production)
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
          //   child: Text(
          //     _liveAlerts.isEmpty ? 'Sample Alerts' : 'Demo Alerts',
          //     style: AppTextStyles.heading3.copyWith(
          //       color: AppColors.textSecondary,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: AppConstants.paddingSmall),

          // // Sample alert items (for demo)
          // const AlertItemCard(
          //   title: 'High Stress Alert',
          //   description: 'Stress level reached 8.5. Consider taking a break.',
          //   timestamp: '15 minutes ago',
          //   type: AlertType.danger,
          //   isUnread: false,
          // ),
          // const AlertItemCard(
          //   title: 'Noise Level Warning',
          //   description: 'Ambient noise at 82 dB for 10 minutes.',
          //   timestamp: '1 hour ago',
          //   type: AlertType.warning,
          //   isUnread: false,
          // ),
          // const AlertItemCard(
          //   title: 'Battery Low',
          //   description: 'Wristband battery at 15%. Please charge soon.',
          //   timestamp: '2 hours ago',
          //   type: AlertType.warning,
          //   isUnread: false,
          // ),
          const SizedBox(height: AppConstants.paddingLarge),
        ],
      ),
    );
  }
}
