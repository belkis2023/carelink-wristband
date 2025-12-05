import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';

/// A card widget displaying a single notable event from history.
class NotableEventCard extends StatelessWidget {
  // Event time (e.g., "11:15 AM")
  final String time;

  // Event description
  final String description;

  // Stress level value at the time of event
  final double stressLevel;

  const NotableEventCard({
    super.key,
    required this.time,
    required this.description,
    required this.stressLevel,
  });

  /// Determines the badge color based on stress level
  Color _getStressColor() {
    if (stressLevel < 4) {
      return AppColors.successGreen;
    } else if (stressLevel < 7) {
      return AppColors.warningYellow;
    } else {
      return AppColors.dangerRed;
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
                  color: AppColors.lightBlueBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryBlue,
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
                        color: _getStressColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Text(
                        stressLevel.toStringAsFixed(1),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _getStressColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
