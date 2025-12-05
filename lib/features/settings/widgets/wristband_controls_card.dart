import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';

/// A card widget with wristband control options like haptic feedback toggle.
class WristbandControlsCard extends StatefulWidget {
  const WristbandControlsCard({super.key});

  @override
  State<WristbandControlsCard> createState() => _WristbandControlsCardState();
}

class _WristbandControlsCardState extends State<WristbandControlsCard> {
  // Track whether haptic feedback is enabled
  bool _hapticEnabled = true;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          // Haptic Feedback Toggle
          Row(
            children: [
              Icon(
                Icons.vibration_rounded,
                color: AppColors.primaryBlue,
                size: AppConstants.iconMedium,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Text(
                  'Haptic Feedback',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              Switch(
                value: _hapticEnabled,
                onChanged: (value) {
                  setState(() {
                    _hapticEnabled = value;
                  });
                },
              ),
            ],
          ),
          const Divider(),

          // Device Status
          Row(
            children: [
              Icon(
                Icons.watch_rounded,
                color: AppColors.primaryBlue,
                size: AppConstants.iconMedium,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Text(
                  'Device Status',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  'Connected',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
