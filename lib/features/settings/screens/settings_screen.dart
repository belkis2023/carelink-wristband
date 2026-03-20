import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/threshold_settings.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../navigation/app_router.dart';
import '../widgets/profile_card.dart';
import '../widgets/wristband_controls_card.dart';
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

  // Threshold settings service
  final ThresholdSettings _thresholdSettings = ThresholdSettings();

  // Current threshold values
  late double _noiseWarningThreshold;
  late double _noiseDangerThreshold;
  late double _heartRateLowThreshold;
  late double _heartRateHighThreshold;

  // ============ STATIC PATIENT DATA (Tunisian) ============
  static const String patientName = "Yassine Ben Salah";
  static const String patientAge = "22";
  static const String patientEmail = "yassine.bensalah@email.tn";
  static const String patientPhone = "+216 98 123 456";
  static const String emergencyContact = "Mohamed Ben Salah";
  static const String emergencyPhone = "+216 55 987 654";
  // ========================================================

  @override
  void initState() {
    super.initState();
    // Load current thresholds
    _noiseWarningThreshold = _thresholdSettings.noiseWarningThreshold;
    _noiseDangerThreshold = _thresholdSettings.noiseDangerThreshold;
    _heartRateLowThreshold = _thresholdSettings.heartRateLowThreshold;
    _heartRateHighThreshold = _thresholdSettings.heartRateHighThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.paddingMedium),

          // Monitored Individual Section
          _buildSectionHeader('Monitored Individual'),
          const ProfileCard(name: patientName, age: patientAge),
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
                _showDemoModeSnackbar(context);
              },
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Contact Information Section (NEW!)
          _buildSectionHeader('Contact Information'),
          CustomCard(
            child: Column(
              children: [
                _buildInfoRow(Icons.email_rounded, 'Email', patientEmail),
                const Divider(height: 24),
                _buildInfoRow(Icons.phone_rounded, 'Phone', patientPhone),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.emergency_rounded,
                  'Emergency Contact',
                  emergencyContact,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.phone_in_talk_rounded,
                  'Emergency Phone',
                  emergencyPhone,
                ),
              ],
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

                // Noise Warning Threshold Slider (Bruit modéré)
                _buildThresholdSection(
                  icon: Icons.volume_up_rounded,
                  iconColor: AppColors.warningYellow,
                  title: 'Noise Warning Level',
                  subtitle: 'RMS value for "Moderate" noise alert',
                ),
                Slider(
                  value: _noiseWarningThreshold,
                  min: 200.0,
                  max: 1500.0,
                  divisions: 26,
                  label: _noiseWarningThreshold.toStringAsFixed(0),
                  onChanged: (value) {
                    setState(() {
                      _noiseWarningThreshold = value;
                      // Ensure warning < danger
                      if (_noiseWarningThreshold >= _noiseDangerThreshold) {
                        _noiseDangerThreshold = _noiseWarningThreshold + 100;
                      }
                    });
                  },
                  onChangeEnd: (value) {
                    _thresholdSettings.setNoiseWarningThreshold(value);
                  },
                ),
                Text(
                  'Current: ${_noiseWarningThreshold.toStringAsFixed(0)} RMS',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.warningYellow),
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // Noise Danger Threshold Slider (DANGER)
                _buildThresholdSection(
                  icon: Icons.warning_rounded,
                  iconColor: AppColors.dangerRed,
                  title: 'Noise Danger Level',
                  subtitle: 'RMS value for "DANGER" noise alert',
                ),
                Slider(
                  value: _noiseDangerThreshold,
                  min: 500.0,
                  max: 3000.0,
                  divisions: 25,
                  label: _noiseDangerThreshold.toStringAsFixed(0),
                  activeColor: AppColors.dangerRed,
                  onChanged: (value) {
                    setState(() {
                      _noiseDangerThreshold = value;
                      // Ensure danger > warning
                      if (_noiseDangerThreshold <= _noiseWarningThreshold) {
                        _noiseWarningThreshold = _noiseDangerThreshold - 100;
                      }
                    });
                  },
                  onChangeEnd: (value) {
                    _thresholdSettings.setNoiseDangerThreshold(value);
                  },
                ),
                Text(
                  'Current: ${_noiseDangerThreshold.toStringAsFixed(0)} RMS',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.dangerRed),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                const Divider(),
                const SizedBox(height: AppConstants.paddingMedium),

                // Heart Rate Low Threshold
                _buildThresholdSection(
                  icon: Icons.favorite_rounded,
                  iconColor: AppColors.warningYellow,
                  title: 'Low Heart Rate Alert',
                  subtitle: 'Alert when BPM falls below this value',
                ),
                Slider(
                  value: _heartRateLowThreshold,
                  min: 40.0,
                  max: 80.0,
                  divisions: 40,
                  label: _heartRateLowThreshold.toStringAsFixed(0),
                  activeColor: AppColors.warningYellow,
                  onChanged: (value) {
                    setState(() {
                      _heartRateLowThreshold = value;
                    });
                  },
                  onChangeEnd: (value) {
                    _thresholdSettings.setHeartRateLowThreshold(value);
                  },
                ),
                Text(
                  'Current: ${_heartRateLowThreshold.toStringAsFixed(0)} BPM',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.warningYellow),
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // Heart Rate High Threshold
                _buildThresholdSection(
                  icon: Icons.favorite_rounded,
                  iconColor: AppColors.dangerRed,
                  title: 'High Heart Rate Alert',
                  subtitle: 'Alert when BPM exceeds this value',
                ),
                Slider(
                  value: _heartRateHighThreshold,
                  min: 80.0,
                  max: 150.0,
                  divisions: 70,
                  label: _heartRateHighThreshold.toStringAsFixed(0),
                  activeColor: AppColors.dangerRed,
                  onChanged: (value) {
                    setState(() {
                      _heartRateHighThreshold = value;
                    });
                  },
                  onChangeEnd: (value) {
                    _thresholdSettings.setHeartRateHighThreshold(value);
                  },
                ),
                Text(
                  'Current: ${_heartRateHighThreshold.toStringAsFixed(0)} BPM',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.dangerRed),
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
                  subtitle: 'Download your monitoring history',
                  icon: Icons.download_rounded,
                  onTap: () {
                    _showDemoModeSnackbar(context);
                  },
                ),
                const Divider(height: 1),
                SettingsMenuItem(
                  title: 'Privacy Settings',
                  subtitle: 'Manage data sharing preferences',
                  icon: Icons.privacy_tip_rounded,
                  onTap: () {
                    _showDemoModeSnackbar(context);
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showSignOutDialog(context);
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dangerRed,
                  side: const BorderSide(color: AppColors.dangerRed, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
        ],
      ),
    );
  }

  /// Builds an info row with icon, label and value
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a section header widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Text(title, style: AppTextStyles.heading3),
    );
  }

  /// Shows a snackbar for demo mode
  void _showDemoModeSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Demo Mode - Feature disabled'),
          ],
        ),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows the about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.watch_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            const Text('CareLink Wristband'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CareLink Wristband helps monitor stress levels, heart rate, motion, and environmental factors to support the well-being of elderly patients.',
            ),
            SizedBox(height: 16),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Developed in Tunisia 🇹🇳'),
            SizedBox(height: 8),
            Text('© 2024 CareLink Team'),
          ],
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(dialogContext).pop();
              // Navigate to login screen
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
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

  /// Builds a threshold section header with icon
  Widget _buildThresholdSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
