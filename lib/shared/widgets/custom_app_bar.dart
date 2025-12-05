import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';

/// A custom app bar widget that displays the user's name and connection status.
/// This provides a consistent header design across the main app screens.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // The title text to display (e.g., "Alex's Monitor")
  final String title;

  // Whether to show the connection status indicator
  final bool showConnectionStatus;

  // The connection status text (e.g., "Wristband connected")
  final String connectionStatus;

  // Whether the device is connected (true = green, false = red)
  final bool isConnected;

  // Optional actions to display on the right side
  final List<Widget>? actions;

  // Whether to show a back button
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showConnectionStatus = true,
    this.connectionStatus = 'Wristband connected',
    this.isConnected = true,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading2,
          ),
          if (showConnectionStatus) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isConnected ? AppColors.successGreen : AppColors.dangerRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  connectionStatus,
                  style: AppTextStyles.caption.copyWith(
                    color: isConnected ? AppColors.successGreen : AppColors.dangerRed,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: actions,
      // Add a subtle bottom border
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.divider,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.appBarHeight + 20);
}
