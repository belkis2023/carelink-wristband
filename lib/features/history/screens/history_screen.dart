import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';
import '../widgets/date_selector_card.dart';
import '../widgets/metrics_chart.dart';
import '../widgets/weekly_stress_card.dart';
import '../widgets/notable_event_card.dart';

/// The history screen showing past monitoring data, trends, and notable events.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.paddingMedium),

          // Date Selector
          DateSelectorCard(
            dateText: 'Today - Nov 27, 2025',
            onTap: () {
              // In a real app, this would open a date picker
              _showDatePicker(context);
            },
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Metrics Chart
          const MetricsChart(),
          const SizedBox(height: AppConstants.paddingMedium),

          // Summary Cards Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              children: [
                // Average Stress Card
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Avg Stress',
                    value: '5.3',
                    subtitle: '-0.8 from yesterday',
                    subtitleColor: AppColors.successGreen,
                    icon: Icons.trending_down_rounded,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                // Peak Stress Card
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Peak Stress',
                    value: '7.2',
                    subtitle: 'at 11:15 AM',
                    subtitleColor: AppColors.textSecondary,
                    icon: Icons.show_chart_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Weekly Average Stress
          const WeeklyStressCard(),
          const SizedBox(height: AppConstants.paddingLarge),

          // Notable Events Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Text('Notable Events', style: AppTextStyles.heading3),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Event cards
          const NotableEventCard(
            time: '11:15 AM',
            description: 'High stress spike detected during class presentation',
            stressLevel: 7.2,
          ),
          const NotableEventCard(
            time: '2:30 PM',
            description: 'Noise level exceeded 75dB for 15 minutes',
            stressLevel: 6.5,
          ),
          const NotableEventCard(
            time: '4:45 PM',
            description: 'Stress normalized after outdoor activity',
            stressLevel: 4.1,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
        ],
      ),
    );
  }

  /// Shows a date picker dialog
  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child ?? const SizedBox.shrink(), // ← FIXED!
        );
      },
    );
  }

  /// Builds a summary card widget
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryBlue,
                size: AppConstants.iconSmall,
              ),
              const SizedBox(width: 4),
              Text(title, style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(value, style: AppTextStyles.valueMedium),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(color: subtitleColor),
          ),
        ],
      ),
    );
  }
}
