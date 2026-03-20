import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/services/heart_rate_history_service.dart';
import '../../../core/services/threshold_settings.dart';

/// A chart widget displaying heart rate metrics over time.
/// Shows real-time BPM data from BLE sensor.
class HeartRateChart extends StatefulWidget {
  const HeartRateChart({super.key});

  @override
  State<HeartRateChart> createState() => _HeartRateChartState();
}

class _HeartRateChartState extends State<HeartRateChart> {
  final HeartRateHistoryService _historyService = HeartRateHistoryService();
  final ThresholdSettings _thresholdSettings = ThresholdSettings();
  StreamSubscription<List<HeartRateDataPoint>>? _subscription;
  List<HeartRateDataPoint> _dataPoints = [];

  // Maximum points to display on chart for performance
  static const int _maxDisplayPoints = 50;

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

    if (mounted) {
      setState(() {
        _dataPoints = newPoints;
      });
    }
  }

  /// Downsample data to reduce number of points while preserving trends
  List<HeartRateDataPoint> _downsampleData(List<HeartRateDataPoint> data, int targetPoints) {
    if (data.length <= targetPoints) return data;

    final result = <HeartRateDataPoint>[];
    final chunkSize = (data.length / targetPoints).ceil();

    for (var i = 0; i < data.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, data.length);
      final chunk = data.sublist(i, end);

      if (chunk.isEmpty) continue;

      // Calculate average BPM for this chunk
      final avgBpm = chunk.fold<double>(0, (sum, dp) => sum + dp.bpmValue) / chunk.length;

      // Find the worst status (prioritize abnormal)
      String status = 'Normal';
      for (final dp in chunk) {
        if (dp.status.toUpperCase() == 'HIGH') {
          status = 'High';
          break;
        } else if (dp.status.toUpperCase() == 'LOW') {
          status = 'Low';
        }
      }

      // Use middle timestamp of chunk
      final middleIndex = chunk.length ~/ 2;
      result.add(HeartRateDataPoint(
        timestamp: chunk[middleIndex].timestamp,
        bpmValue: avgBpm,
        status: status,
      ));
    }

    return result;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
                  "Heart Rate (Last 30 min)",
                  style: AppTextStyles.heading3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_dataPoints.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_dataPoints.length} pts',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.dangerRed,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Chart legend
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildLegendItem('BPM', AppColors.dangerRed),
              _buildThresholdLegend('High ${_thresholdSettings.heartRateHighThreshold.toInt()}', AppColors.dangerRed),
              _buildThresholdLegend('Low ${_thresholdSettings.heartRateLowThreshold.toInt()}', AppColors.warningYellow),
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
            Icons.favorite_rounded,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No heart rate data yet',
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
    final avgBpm = _dataPoints.isEmpty
        ? 0.0
        : _dataPoints.fold<double>(0, (sum, dp) => sum + dp.bpmValue) / _dataPoints.length;
    final maxBpm = _dataPoints.isEmpty
        ? 0.0
        : _dataPoints.map((dp) => dp.bpmValue).reduce((a, b) => a > b ? a : b);
    final minBpm = _dataPoints.isEmpty
        ? 0.0
        : _dataPoints.map((dp) => dp.bpmValue).reduce((a, b) => a < b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Avg', '${avgBpm.toStringAsFixed(0)}', AppColors.primaryBlue),
        _buildStatItem('Max', '${maxBpm.toStringAsFixed(0)}', AppColors.dangerRed),
        _buildStatItem('Min', '${minBpm.toStringAsFixed(0)}', AppColors.warningYellow),
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

  /// Creates the line chart data from heart rate history
  LineChartData _createChartData() {
    final lowThreshold = _thresholdSettings.heartRateLowThreshold;
    final highThreshold = _thresholdSettings.heartRateHighThreshold;

    // Convert data points to FlSpots
    final spots = <FlSpot>[];
    if (_dataPoints.isNotEmpty) {
      final firstTime = _dataPoints.first.timestamp;
      for (var i = 0; i < _dataPoints.length; i++) {
        final dp = _dataPoints[i];
        final minutesFromStart = dp.timestamp.difference(firstTime).inSeconds / 60.0;
        spots.add(FlSpot(minutesFromStart, dp.bpmValue));
      }
    }

    // Calculate Y axis range
    double minY = 40;
    double maxY = 160;
    if (_dataPoints.isNotEmpty) {
      final minBpm = _dataPoints.map((dp) => dp.bpmValue).reduce((a, b) => a < b ? a : b);
      final maxBpm = _dataPoints.map((dp) => dp.bpmValue).reduce((a, b) => a > b ? a : b);
      minY = (minBpm - 10).clamp(30, 60);
      maxY = (maxBpm + 10).clamp(100, 200);
    }

    // Calculate max X (time range in minutes)
    double maxX = 1;
    if (spots.length > 1) {
      maxX = (spots.last.x).clamp(1.0, 30.0);
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          Color lineColor = AppColors.divider;
          double strokeWidth = 1;

          // Highlight threshold lines
          if ((value - highThreshold).abs() < 2) {
            lineColor = AppColors.dangerRed.withOpacity(0.5);
            strokeWidth = 2;
          } else if ((value - lowThreshold).abs() < 2) {
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
            interval: 20,
            reservedSize: 40,
            getTitlesWidget: (double value, TitleMeta meta) {
              Color textColor = AppColors.textSecondary;

              if (value >= highThreshold) {
                textColor = AppColors.dangerRed;
              } else if (value <= lowThreshold) {
                textColor = AppColors.warningYellow;
              }

              return Text(
                '${value.toInt()}',
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
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppColors.dangerRed,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: spots.length <= 20,
            getDotPainter: (spot, percent, barData, index) {
              Color dotColor = AppColors.successGreen;
              if (spot.y >= highThreshold) {
                dotColor = AppColors.dangerRed;
              } else if (spot.y <= lowThreshold) {
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
                AppColors.dangerRed.withOpacity(0.3),
                AppColors.dangerRed.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              String status = 'Normal';
              Color color = AppColors.successGreen;
              if (spot.y >= highThreshold) {
                status = 'High';
                color = AppColors.dangerRed;
              } else if (spot.y <= lowThreshold) {
                status = 'Low';
                color = AppColors.warningYellow;
              }
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(0)} BPM\n$status',
                TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              );
            }).toList();
          },
        ),
      ),
    );
  }

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

