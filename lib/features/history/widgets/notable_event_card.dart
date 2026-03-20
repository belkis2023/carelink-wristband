import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/alert_service.dart';

/// A card widget displaying a single notable event from history.
class NotableEventCard extends StatelessWidget {
  // Event time (e.g., "11:15 AM")
  final String time;

  // Event description
  final String description;

  // Stress level value at the time of event (for stress alerts)
  final double stressLevel;

  // Whether this is a noise alert
  final bool isNoiseAlert;

  // Alert severity (for noise alerts)
  final AlertSeverity? severity;

  const NotableEventCard({
    super.key,
    required this.time,
    required this.description,
    required this.stressLevel,
    this.isNoiseAlert = false,
    this.severity,
  });

  /// Determines the badge color based on stress level or severity
  Color _getColor() {
    if (isNoiseAlert && severity != null) {
      switch (severity!) {
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

    // Stress level based color
    if (stressLevel < 4) {
      return AppColors.successGreen;
    } else if (stressLevel < 7) {
      return AppColors.warningYellow;
    } else {
      return AppColors.dangerRed;
    }
  }

  String _getSeverityLabel() {
    if (severity == null) return '';
    switch (severity!) {
      case AlertSeverity.danger:
        return 'DANGER';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.success:
        return 'OK';
      case AlertSeverity.info:
        return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: isNoiseAlert && severity == AlertSeverity.danger
            ? Border.all(color: AppColors.dangerRed.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time indicator with vertical line
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isNoiseAlert
                      ? _getColor().withOpacity(0.1)
                      : AppColors.lightBlueBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isNoiseAlert ? _getColor() : AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppConstants.paddingMedium),

          // Event description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Row(
                  children: [
                    if (isNoiseAlert) ...[
                      Icon(
                        Icons.volume_up_rounded,
                        size: 14,
                        color: _getColor(),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                        child: Text(
                          _getSeverityLabel(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _getColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Stress Level: ',
                        style: AppTextStyles.bodySmall,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                        child: Text(
                          stressLevel.toStringAsFixed(1),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _getColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
