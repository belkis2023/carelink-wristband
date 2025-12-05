import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../widgets/stress_level_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/haptic_toggle_card.dart';
import '../../history/screens/history_screen.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../settings/screens/settings_screen.dart';

/// The main dashboard screen showing real-time monitoring data.
/// This is the primary screen users see after logging in.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Current tab index for bottom navigation
  int _currentIndex = 0;

  // List of screens for each tab
  final List<Widget> _screens = const [
    _DashboardContent(),
    HistoryScreen(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Alex's Monitor",
        showConnectionStatus: true,
        isConnected: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

/// The actual dashboard content (separated for cleaner code organization)
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.paddingMedium),

          // Current Status Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time monitoring data',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Stress Level Card
          const StressLevelCard(
            stressLevel: 6.2,
            status: 'Moderate',
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Metrics Grid (2x2 grid of metric cards)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppConstants.paddingMedium,
              crossAxisSpacing: AppConstants.paddingMedium,
              childAspectRatio: 1.0,
              children: const [
                MetricCard(
                  title: 'Heart Rate',
                  value: '78 BPM',
                  icon: Icons.favorite_rounded,
                ),
                MetricCard(
                  title: 'Motion',
                  value: 'Moderate',
                  icon: Icons.directions_walk_rounded,
                ),
                MetricCard(
                  title: 'Noise Level',
                  value: '65 dB',
                  icon: Icons.volume_up_rounded,
                ),
                MetricCard(
                  title: 'Battery',
                  value: '68%',
                  icon: Icons.battery_5_bar_rounded,
                  valueColor: AppColors.successGreen,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Haptic Feedback Toggle
          const HapticToggleCard(),
          const SizedBox(height: AppConstants.paddingLarge),

          // About These Metrics Section
          CustomCard(
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
                      'About These Metrics',
                      style: AppTextStyles.heading3,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildMetricInfo(
                  'Stress Level (GSR)',
                  'Measures skin conductance to detect stress and emotional responses. Scale: 0-10.',
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildMetricInfo(
                  'Heart Rate',
                  'Tracks beats per minute (BPM) to monitor cardiovascular activity.',
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildMetricInfo(
                  'Motion',
                  'Detects movement patterns using accelerometer data.',
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildMetricInfo(
                  'Noise Level',
                  'Measures ambient sound in decibels (dB) to assess environmental conditions.',
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildMetricInfo(
                  'Haptic Feedback',
                  'Provides vibration alerts when stress levels exceed thresholds.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
        ],
      ),
    );
  }

  /// Helper widget to build metric information rows
  Widget _buildMetricInfo(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
