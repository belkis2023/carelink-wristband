import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';

/// A card widget displaying a single alert notification.
class AlertItemCard extends StatelessWidget {
  // Alert title
  final String title;

  // Alert description
  final String description;

  // Alert timestamp (e.g., "2 hours ago")
  final String timestamp;

  // Alert type (determines icon and color)
  final AlertType type;

  // Whether the alert is unread
  final bool isUnread;

  const AlertItemCard({
    super.key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isUnread = false,
  });

  /// Gets the icon based on alert type
  IconData _getIcon() {
    switch (type) {
      case AlertType.danger:
        return Icons.warning_rounded;
      case AlertType.warning:
        return Icons.error_outline_rounded;
      case AlertType.success:
        return Icons.check_circle_outline_rounded;
      case AlertType.info:
        return Icons.info_outline_rounded;
    }
  }

  /// Gets the color based on alert type
  Color _getColor() {
    switch (type) {
      case AlertType.danger:
        return AppColors.dangerRed;
      case AlertType.warning:
        return AppColors.warningYellow;
      case AlertType.success:
        return AppColors.successGreen;
      case AlertType.info:
        return AppColors.primaryBlue;
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
        // Highlight unread alerts with a subtle background
        border: isUnread
            ? Border.all(color: AppColors.primaryBlue.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert icon with background
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: _getColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              _getIcon(),
              color: _getColor(),
              size: AppConstants.iconMedium,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),

          // Alert content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Unread indicator dot
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  timestamp,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Enum to define different alert types
enum AlertType {
  danger,
  warning,
  success,
  info,
}
