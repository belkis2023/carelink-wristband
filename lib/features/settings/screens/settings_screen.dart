import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';
import '../widgets/profile_card.dart';
import '../widgets/wristband_controls_card.dart';
import '../widgets/threshold_slider.dart';
import '../widgets/settings_menu_item.dart';

/// The settings screen for configuring app preferences, thresholds, and account settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Track whether push notifications are enabled
  bool _pushNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.paddingMedium),

          // Monitored Individual Section
          _buildSectionHeader('Monitored Individual'),
          const ProfileCard(
            name: 'Alex Johnson',
            age: '14',
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Edit Profile Menu Item
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
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
            child: SettingsMenuItem(
              title: 'Edit Profile',
              icon: Icons.edit_rounded,
              onTap: () {
                // Navigate to edit profile screen
                Navigator.of(context).pushNamed('/edit-profile');
              },
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Wristband Controls Section
          _buildSectionHeader('Wristband Controls'),
          const WristbandControlsCard(),
          const SizedBox(height: AppConstants.paddingLarge),

          // Alert Thresholds Section
          _buildSectionHeader('Alert Thresholds'),
          CustomCard(
            child: Column(
              children: [
                // Push Notifications Toggle
                Row(
                  children: [
                    Icon(
                      Icons.notifications_rounded,
                      color: AppColors.primaryBlue,
                      size: AppConstants.iconMedium,
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Text(
                        'Push Notifications',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: _pushNotificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _pushNotificationsEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                const Divider(),
                const SizedBox(height: AppConstants.paddingMedium),

                // Stress Level Threshold Slider
                ThresholdSlider(
                  label: 'Stress Level Threshold',
                  initialValue: 7.0,
                  min: 5.0,
                  max: 9.0,
                  divisions: 40,
                  onChanged: (value) {
                    // Handle threshold change
                  },
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // Noise Level Threshold Slider
                ThresholdSlider(
                  label: 'Noise Level Threshold',
                  initialValue: 75.0,
                  min: 60.0,
                  max: 90.0,
                  divisions: 30,
                  unit: ' dB',
                  onChanged: (value) {
                    // Handle threshold change
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Data & Privacy Section
          _buildSectionHeader('Data & Privacy'),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
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
              children: [
                SettingsMenuItem(
                  title: 'Export Health Data',
                  subtitle: 'Download your monitoring data',
                  icon: Icons.download_rounded,
                  onTap: () {
                    _showComingSoonSnackbar(context, 'Export Health Data');
                  },
                ),
                const Divider(height: 1),
                SettingsMenuItem(
                  title: 'Privacy Settings',
                  subtitle: 'Manage data sharing preferences',
                  icon: Icons.privacy_tip_rounded,
                  onTap: () {
                    _showComingSoonSnackbar(context, 'Privacy Settings');
                  },
                ),
                const Divider(height: 1),
                SettingsMenuItem(
                  title: 'About This App',
                  subtitle: 'Version 1.0.0',
                  icon: Icons.info_rounded,
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Sign Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: OutlinedButton(
              onPressed: () {
                _showSignOutDialog(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.dangerRed,
                side: const BorderSide(color: AppColors.dangerRed, width: 2),
              ),
              child: const Text('Sign Out'),
            ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
        ],
      ),
    );
  }

  /// Builds a section header widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Text(
        title,
        style: AppTextStyles.heading3,
      ),
    );
  }

  /// Shows a snackbar for features not yet implemented
  void _showComingSoonSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  /// Shows the about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About CareLink Wristband'),
        content: const Text(
          'CareLink Wristband helps monitor stress levels, heart rate, motion, and environmental factors to support well-being.\n\nVersion: 1.0.0\n\nDeveloped with ❤️ for caregivers and individuals.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Shows the sign-out confirmation dialog
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to login (in a real app)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signed out successfully'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
        ],
      ),
    );
  }
}
