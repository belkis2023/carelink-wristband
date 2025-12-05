import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';

/// A card widget displaying the monitored individual's profile information.
class ProfileCard extends StatelessWidget {
  // Name of the monitored individual
  final String name;

  // Age of the monitored individual
  final String age;

  const ProfileCard({
    super.key,
    required this.name,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: AppConstants.avatarMedium / 2,
            backgroundColor: AppColors.lightBlueBackground,
            child: Text(
              name[0].toUpperCase(),
              style: AppTextStyles.valueMedium.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),

          // Name and Age
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 4),
                Text(
                  'Age $age',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
