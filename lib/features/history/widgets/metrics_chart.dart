import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';

/// A chart widget displaying metrics over time using line charts.
/// Shows Heart Rate, Noise Level, and Stress Level trends.
class MetricsChart extends StatelessWidget {
  const MetricsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Text(
            "Today's Metrics",
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Chart legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Heart Rate', AppColors.dangerRed),
              _buildLegendItem('Noise dB', AppColors.warningYellow),
              _buildLegendItem('Stress', AppColors.primaryBlue),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Line chart
          SizedBox(
            height: 200,
            child: LineChart(
              _createChartData(),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates the line chart data
  LineChartData _createChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 2,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              );
              String text;
              switch (value.toInt()) {
                case 0:
                  text = '8AM';
                  break;
                case 2:
                  text = '10AM';
                  break;
                case 4:
                  text = '12PM';
                  break;
                case 6:
                  text = '2PM';
                  break;
                case 8:
                  text = '4PM';
                  break;
                default:
                  text = '';
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(text, style: style),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: 35,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              );
              return Text(value.toInt().toString(), style: style);
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: AppColors.divider),
      ),
      minX: 0,
      maxX: 8,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        // Heart Rate line
        LineChartBarData(
          spots: const [
            FlSpot(0, 72),
            FlSpot(1, 75),
            FlSpot(2, 78),
            FlSpot(3, 80),
            FlSpot(4, 82),
            FlSpot(5, 79),
            FlSpot(6, 76),
            FlSpot(7, 75),
            FlSpot(8, 78),
          ],
          isCurved: true,
          color: AppColors.dangerRed,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
        // Noise Level line
        LineChartBarData(
          spots: const [
            FlSpot(0, 55),
            FlSpot(1, 60),
            FlSpot(2, 65),
            FlSpot(3, 70),
            FlSpot(4, 68),
            FlSpot(5, 65),
            FlSpot(6, 62),
            FlSpot(7, 60),
            FlSpot(8, 65),
          ],
          isCurved: true,
          color: AppColors.warningYellow,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
        // Stress Level line (scaled up for visibility)
        LineChartBarData(
          spots: const [
            FlSpot(0, 50),
            FlSpot(1, 55),
            FlSpot(2, 60),
            FlSpot(3, 72),
            FlSpot(4, 65),
            FlSpot(5, 62),
            FlSpot(6, 58),
            FlSpot(7, 55),
            FlSpot(8, 62),
          ],
          isCurved: true,
          color: AppColors.primaryBlue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  /// Helper to build legend items
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
