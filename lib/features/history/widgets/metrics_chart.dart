import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/services/noise_history_service.dart';

/// A chart widget displaying noise level metrics over time.
/// Shows real-time noise data from BLE sensor.
class MetricsChart extends StatefulWidget {
  const MetricsChart({super.key});

  @override
  State<MetricsChart> createState() => _MetricsChartState();
}

class _MetricsChartState extends State<MetricsChart> {
  final NoiseHistoryService _historyService = NoiseHistoryService();
  StreamSubscription<List<NoiseDataPoint>>? _subscription;
  List<NoiseDataPoint> _dataPoints = [];

  @override
  void initState() {
    super.initState();
    _refreshData();

    _subscription = _historyService.historyStream.listen((data) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  // Maximum points to display on chart for performance
  static const int _maxDisplayPoints = 50;

  void _refreshData() {
    // Get recent data points (last 30 minutes)
    var newPoints = _historyService.getRecentDataPoints(30);

    // If no recent data, try to get all data points
    if (newPoints.isEmpty) {
      newPoints = _historyService.dataPoints.toList();
    }

    // Downsample if too many points
    if (newPoints.length > _maxDisplayPoints) {
      newPoints = _downsampleData(newPoints, _maxDisplayPoints);
    }

    print('📊 Chart: Refreshing data, display points: ${newPoints.length}, total stored: ${_historyService.dataPoints.length}');

    if (mounted) {
      setState(() {
        _dataPoints = newPoints;
      });
    }
  }

  /// Downsample data to reduce number of points while preserving trends
  /// Uses averaging over intervals
  List<NoiseDataPoint> _downsampleData(List<NoiseDataPoint> data, int targetPoints) {
    if (data.length <= targetPoints) return data;

    final result = <NoiseDataPoint>[];
    final chunkSize = (data.length / targetPoints).ceil();

    for (var i = 0; i < data.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, data.length);
      final chunk = data.sublist(i, end);

      if (chunk.isEmpty) continue;

      // Calculate average RMS for this chunk
      final avgRms = chunk.fold<double>(0, (sum, dp) => sum + dp.rmsValue) / chunk.length;

      // Find the max status (prioritize danger > moderate > calm)
      String status = 'Calm';
      for (final dp in chunk) {
        if (dp.status.toUpperCase().contains('DANGER')) {
          status = 'DANGER';
          break;
        } else if (dp.status.toLowerCase().contains('moder')) {
          status = 'Moderate';
        }
      }

      // Use middle timestamp of chunk
      final middleIndex = chunk.length ~/ 2;
      result.add(NoiseDataPoint(
        timestamp: chunk[middleIndex].timestamp,
        rmsValue: avgRms,
        status: status,
      ));
    }

    return result;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when the widget becomes visible
    _refreshData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Noise Level (Last 30 min)",
                  style: AppTextStyles.heading3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_dataPoints.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_dataPoints.length} pts',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.successGreen,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Chart legend - wrap to prevent overflow
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildLegendItem('Noise', AppColors.primaryBlue),
              _buildThresholdLegend('Danger 72%', AppColors.dangerRed),
              _buildThresholdLegend('Warn 32%', AppColors.warningYellow),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Line chart
          SizedBox(
            height: 200,
            child: _dataPoints.isEmpty
                ? _buildEmptyState()
                : LineChart(_createChartData()),
          ),

          // Stats row
          if (_dataPoints.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            _buildStatsRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No noise data yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Connect to wristband to see live data',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    const double maxRmsForScale = 2500.0;

    final avgRms = _dataPoints.isEmpty
        ? 0.0
        : _dataPoints.fold<double>(0, (sum, dp) => sum + dp.rmsValue) / _dataPoints.length;
    final maxRms = _dataPoints.isEmpty
        ? 0.0
        : _dataPoints.map((dp) => dp.rmsValue).reduce((a, b) => a > b ? a : b);
    final dangerCount = _dataPoints.where((dp) => dp.rmsValue >= 1800).length;

    // Convert to percentages
    final avgPercent = (avgRms / maxRmsForScale * 100).clamp(0.0, 100.0);
    final maxPercent = (maxRms / maxRmsForScale * 100).clamp(0.0, 100.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Avg', '${avgPercent.toStringAsFixed(0)}%', AppColors.primaryBlue),
        _buildStatItem('Peak', '${maxPercent.toStringAsFixed(0)}%', AppColors.warningYellow),
        _buildStatItem('Danger', '$dangerCount', AppColors.dangerRed),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(color: color),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  /// Creates the line chart data from noise history
  /// Uses percentage scale: 0% = 0 RMS, 100% = 2500 RMS (danger zone)
  LineChartData _createChartData() {
    // Max RMS value for 100% scale
    const double maxRmsForScale = 2500.0;

    // Convert data points to FlSpots with percentage Y values
    final spots = <FlSpot>[];
    if (_dataPoints.isNotEmpty) {
      final firstTime = _dataPoints.first.timestamp;
      for (var i = 0; i < _dataPoints.length; i++) {
        final dp = _dataPoints[i];
        final minutesFromStart = dp.timestamp.difference(firstTime).inSeconds / 60.0;
        // Convert RMS to percentage (capped at 100%)
        final percentage = (dp.rmsValue / maxRmsForScale * 100).clamp(0.0, 100.0);
        spots.add(FlSpot(minutesFromStart, percentage));
      }
    }

    print('📊 Chart: Creating chart with ${spots.length} spots');

    // Calculate max X (time range in minutes)
    double maxX = 1; // Default to at least 1 minute
    if (spots.length > 1) {
      maxX = (spots.last.x).clamp(1.0, 30.0);
    }

    // Threshold percentages
    const dangerThreshold = 1800 / maxRmsForScale * 100; // ~72%
    const warningThreshold = 800 / maxRmsForScale * 100; // ~32%

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25, // 0%, 25%, 50%, 75%, 100%
        getDrawingHorizontalLine: (value) {
          Color lineColor = AppColors.divider;
          double strokeWidth = 1;

          // Highlight threshold lines
          if ((value - dangerThreshold).abs() < 2) {
            lineColor = AppColors.dangerRed.withOpacity(0.5);
            strokeWidth = 2;
          } else if ((value - warningThreshold).abs() < 2) {
            lineColor = AppColors.warningYellow.withOpacity(0.5);
            strokeWidth = 2;
          }

          return FlLine(
            color: lineColor,
            strokeWidth: strokeWidth,
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
            interval: maxX > 5 ? maxX / 5 : 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              // Skip edge labels to avoid overlap
              if (value == 0 || value == maxX) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  '${value.toStringAsFixed(0)}m',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 25,
            reservedSize: 40,
            getTitlesWidget: (double value, TitleMeta meta) {
              String label = '${value.toInt()}%';
              Color textColor = AppColors.textSecondary;

              // Color the labels based on thresholds
              if (value >= dangerThreshold) {
                textColor = AppColors.dangerRed;
              } else if (value >= warningThreshold) {
                textColor = AppColors.warningYellow;
              }

              return Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: AppColors.divider),
      ),
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        // Noise Level line
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppColors.primaryBlue,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: spots.length <= 20, // Only show dots if few points
            getDotPainter: (spot, percent, barData, index) {
              Color dotColor = AppColors.successGreen;
              if (spot.y >= dangerThreshold) {
                dotColor = AppColors.dangerRed;
              } else if (spot.y >= warningThreshold) {
                dotColor = AppColors.warningYellow;
              }
              return FlDotCirclePainter(
                radius: 3,
                color: dotColor,
                strokeWidth: 0,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryBlue.withOpacity(0.3),
                AppColors.primaryBlue.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              String status = 'Calm';
              Color color = AppColors.successGreen;
              if (spot.y >= dangerThreshold) {
                status = 'DANGER';
                color = AppColors.dangerRed;
              } else if (spot.y >= warningThreshold) {
                status = 'Moderate';
                color = AppColors.warningYellow;
              }
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(0)}%\n$status',
                TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  /// Helper to build legend items
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildThresholdLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 2,
          color: color.withOpacity(0.5),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
