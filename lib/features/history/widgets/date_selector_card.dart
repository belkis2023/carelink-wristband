import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';

/// A card widget for selecting and displaying the current date for history data.
class DateSelectorCard extends StatelessWidget {
  // The date text to display (e.g., "Today - Nov 27, 2025")
  final String dateText;

  // Callback when the date selector is tapped
  final VoidCallback? onTap;

  const DateSelectorCard({
    super.key,
    required this.dateText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          // Calendar icon with background
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primaryBlue,
              size: AppConstants.iconMedium,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),

          // Date text
          Expanded(
            child: Text(
              dateText,
              style: AppTextStyles.heading3,
            ),
          ),

          // Chevron icon indicating it's tappable
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: AppConstants.iconMedium,
            ),
        ],
      ),
    );
  }
}
