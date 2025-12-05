import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';

/// An info card explaining alert thresholds and notification triggers.
class AlertThresholdCard extends StatelessWidget {
  const AlertThresholdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryBlue,
                size: AppConstants.iconMedium,
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                'Alert Thresholds',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'You will be notified when:',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          _buildThresholdItem(
            '• Stress level exceeds 7.0 for more than 5 minutes',
          ),
          _buildThresholdItem(
            '• Noise level exceeds 75 dB for extended periods',
          ),
          _buildThresholdItem(
            '• Battery level drops below 20%',
          ),
          _buildThresholdItem(
            '• Wristband connection is lost',
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTextStyles.bodySmall,
      ),
    );
  }
}
