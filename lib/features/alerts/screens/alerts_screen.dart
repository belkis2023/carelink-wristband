import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/alert_threshold_card.dart';
import '../widgets/alert_item_card.dart';

/// The alerts screen showing all notifications and alert thresholds.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.paddingMedium),

          // Alert Thresholds Info Card
          const AlertThresholdCard(),
          const SizedBox(height: AppConstants.paddingLarge),

          // New Alerts Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: Text(
              'New (3)',
              style: AppTextStyles.heading3,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // New alert items
          const AlertItemCard(
            title: 'High Stress Alert',
            description: 'Stress level reached 8.5. Consider taking a break.',
            timestamp: '15 minutes ago',
            type: AlertType.danger,
            isUnread: true,
          ),
          const AlertItemCard(
            title: 'Noise Level Warning',
            description: 'Ambient noise at 82 dB for 10 minutes.',
            timestamp: '1 hour ago',
            type: AlertType.warning,
            isUnread: true,
          ),
          const AlertItemCard(
            title: 'Battery Low',
            description: 'Wristband battery at 15%. Please charge soon.',
            timestamp: '2 hours ago',
            type: AlertType.warning,
            isUnread: true,
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Earlier Alerts Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: Text(
              'Earlier',
              style: AppTextStyles.heading3,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Earlier alert items
          const AlertItemCard(
            title: 'Stress Normalized',
            description: 'Stress level returned to normal range (4.2).',
            timestamp: 'Yesterday, 4:30 PM',
            type: AlertType.success,
            isUnread: false,
          ),
          const AlertItemCard(
            title: 'Peak Stress Event',
            description: 'Stress spike detected during morning hours (7.8).',
            timestamp: 'Yesterday, 11:15 AM',
            type: AlertType.danger,
            isUnread: false,
          ),
          const AlertItemCard(
            title: 'Connection Restored',
            description: 'Wristband reconnected successfully.',
            timestamp: '2 days ago',
            type: AlertType.success,
            isUnread: false,
          ),
          const AlertItemCard(
            title: 'Extended High Noise',
            description: 'Noise exceeded 75 dB for 30 minutes.',
            timestamp: '2 days ago',
            type: AlertType.warning,
            isUnread: false,
          ),
          const AlertItemCard(
            title: 'Daily Summary',
            description: 'Average stress: 5.8. Peak: 7.2 at 2:15 PM.',
            timestamp: '3 days ago',
            type: AlertType.info,
            isUnread: false,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
        ],
      ),
    );
  }
}
