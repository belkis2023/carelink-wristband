import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';

/// A compact card widget that displays a single metric value.
/// Used for Heart Rate, Motion, Noise Level, and Battery metrics.
class MetricCard extends StatelessWidget {
  // The metric title (e.g., "Heart Rate")
  final String title;

  // The metric value (e.g., "78 BPM")
  final String value;

  // The icon to display
  final IconData icon;

  // Optional background color for the icon
  final Color? iconBackgroundColor;

  // Optional color for the value text
  final Color? valueColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconBackgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: AppConstants.iconMedium,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Metric value
          Text(
            value,
            style: AppTextStyles.valueMedium.copyWith(
              color: valueColor,
            ),
          ),

          // Metric title
          Text(
            title,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
