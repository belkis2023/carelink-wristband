import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';

/// A menu item widget for settings navigation (e.g., "Edit Profile", "Privacy Settings").
class SettingsMenuItem extends StatelessWidget {
  // The title of the menu item
  final String title;

  // Optional subtitle text
  final String? subtitle;

  // The icon to display
  final IconData icon;

  // Callback when the item is tapped
  final VoidCallback? onTap;

  // Whether to show a chevron (arrow) on the right
  final bool showChevron;

  const SettingsMenuItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingMedium,
        ),
        child: Row(
          children: [
            // Icon
            Icon(
              icon,
              color: AppColors.primaryBlue,
              size: AppConstants.iconMedium,
            ),
            const SizedBox(width: AppConstants.paddingMedium),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),

            // Chevron icon
            if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: AppConstants.iconMedium,
              ),
          ],
        ),
      ),
    );
  }
}
