import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';

/// A card widget displaying weekly average stress levels with a horizontal bar chart.
class WeeklyStressCard extends StatelessWidget {
  const WeeklyStressCard({super.key});

  // Mock data for weekly stress (day, value)
  final List<Map<String, dynamic>> _weeklyData = const [
    {'day': 'Mon', 'value': 5.2},
    {'day': 'Tue', 'value': 6.1},
    {'day': 'Wed', 'value': 4.8},
    {'day': 'Thu', 'value': 7.2},
    {'day': 'Fri', 'value': 5.5},
    {'day': 'Sat', 'value': 3.9},
    {'day': 'Sun', 'value': 4.5},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Average Stress',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Weekly bars
          Column(
            children: _weeklyData.map((data) {
              return _buildWeeklyBar(
                data['day'] as String,
                data['value'] as double,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Builds a single horizontal bar for a day
  Widget _buildWeeklyBar(String day, double value) {
    // Determine color based on stress level
    Color barColor;
    if (value < 4) {
      barColor = AppColors.successGreen;
    } else if (value < 7) {
      barColor = AppColors.warningYellow;
    } else {
      barColor = AppColors.dangerRed;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          // Day label
          SizedBox(
            width: 40,
            child: Text(
              day,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),

          // Bar
          Expanded(
            child: Stack(
              children: [
                // Background bar
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                ),
                // Filled bar
                FractionallySizedBox(
                  widthFactor: value / 10.0, // Scale to 0-10
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),

          // Value
          SizedBox(
            width: 35,
            child: Text(
              value.toStringAsFixed(1),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
