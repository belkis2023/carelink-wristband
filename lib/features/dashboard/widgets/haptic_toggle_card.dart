import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';

/// A card widget with a toggle switch for controlling haptic feedback.
/// Shows current status and allows users to turn haptic feedback on/off.
class HapticToggleCard extends StatefulWidget {
  const HapticToggleCard({super.key});

  @override
  State<HapticToggleCard> createState() => _HapticToggleCardState();
}

class _HapticToggleCardState extends State<HapticToggleCard> {
  // Track whether haptic feedback is enabled
  bool _isEnabled = true;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Row(
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              Icons.vibration_rounded,
              color: AppColors.primaryBlue,
              size: AppConstants.iconMedium,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),

          // Title and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Haptic Feedback',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingSmall,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _isEnabled
                            ? AppColors.successGreen.withOpacity(0.1)
                            : AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Text(
                        _isEnabled ? 'Active' : 'Inactive',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _isEnabled
                              ? AppColors.successGreen
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Toggle switch
          Switch(
            value: _isEnabled,
            onChanged: (value) {
              setState(() {
                _isEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
