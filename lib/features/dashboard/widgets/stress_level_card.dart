import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';

/// A card widget that displays the current stress level (GSR) with a visual indicator.
/// Shows the stress value, status label, and a progress bar with scale.
class StressLevelCard extends StatelessWidget {
  // Current stress level value (0-10)
  final double stressLevel;

  // Status label (e.g., "Low", "Moderate", "High")
  final String status;

  const StressLevelCard({
    super.key,
    required this.stressLevel,
    required this.status,
  });

  /// Determines the color based on stress level
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
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(
                  Icons.psychology,
                  color: AppColors.primaryBlue,
                  size: AppConstants.iconMedium,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stress Level (GSR)',
                      style: AppTextStyles.heading3,
                    ),
                    Text(
                      status,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _getStressColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Large value display
              Text(
                stressLevel.toStringAsFixed(1),
                style: AppTextStyles.valueLarge.copyWith(
                  color: _getStressColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Progress bar with scale
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                child: LinearProgressIndicator(
                  value: stressLevel / 10.0,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(_getStressColor()),
                  minHeight: AppConstants.progressBarHeightLarge,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),

              // Scale markers (0 - 10)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0', style: AppTextStyles.caption),
                  Text('5', style: AppTextStyles.caption),
                  Text('10', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
