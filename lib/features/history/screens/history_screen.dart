import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/noise_history_service.dart';
import '../../../core/services/heart_rate_history_service.dart';
import '../../../core/services/alert_service.dart';
import '../widgets/date_selector_card.dart';
import '../widgets/metrics_chart.dart';
import '../widgets/heart_rate_chart.dart';
import '../widgets/notable_event_card.dart';

/// Helper function to format date
String _formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Helper function to format time
String _formatTime(DateTime time) {
  final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
  final period = time.hour >= 12 ? 'PM' : 'AM';
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}

/// The history screen showing past monitoring data, trends, and notable events.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final NoiseHistoryService _historyService = NoiseHistoryService();
  final AlertService _alertService = AlertService();
  StreamSubscription? _historySubscription;
  StreamSubscription<AlertEvent>? _alertSubscription;

  List<NoiseDataPoint> _dataPoints = [];
  List<AlertEvent> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _historySubscription = _historyService.historyStream.listen((_) {
      if (mounted) {
        _loadData();
      }
    });
    _alertSubscription = _alertService.alertStream.listen((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _loadData() {
    setState(() {
      _dataPoints = _historyService.getTodayDataPoints();
      _alerts = _alertService.alerts.take(10).toList();
    });
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    _alertSubscription?.cancel();
    super.dispose();
  }

  double get _avgNoise {
    if (_dataPoints.isEmpty) return 0;
    return _dataPoints.fold<double>(0, (sum, dp) => sum + dp.rmsValue) / _dataPoints.length;
  }

  NoiseDataPoint? get _peakNoise {
    if (_dataPoints.isEmpty) return null;
    return _dataPoints.reduce((a, b) => a.rmsValue > b.rmsValue ? a : b);
  }

  int get _dangerCount {
    return _dataPoints.where((dp) => dp.rmsValue >= 1800).length;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateText = 'Today - ${_formatDate(now)}';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.paddingMedium),

          // Date Selector
          DateSelectorCard(
            dateText: dateText,
            onTap: () {
              _showDatePicker(context);
            },
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Noise Level Chart (Live noise data)
          const MetricsChart(),
          const SizedBox(height: AppConstants.paddingMedium),

          // Heart Rate Chart (Live BPM data)
          const HeartRateChart(),
          const SizedBox(height: AppConstants.paddingMedium),

          // Summary Cards Row (Live stats)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: Row(
              children: [
                // Average Noise Card
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Avg Noise',
                    value: _avgNoise.toStringAsFixed(0),
                    subtitle: _dataPoints.isEmpty
                        ? 'No data yet'
                        : '${_dataPoints.length} readings',
                    subtitleColor: AppColors.textSecondary,
                    icon: Icons.volume_up_rounded,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                // Peak Noise Card
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Peak Noise',
                    value: _peakNoise?.rmsValue.toStringAsFixed(0) ?? '-',
                    subtitle: _peakNoise != null
                        ? 'at ${_formatTime(_peakNoise!.timestamp)}'
                        : 'No data',
                    subtitleColor: _peakNoise != null && _peakNoise!.rmsValue >= 1800
                        ? AppColors.dangerRed
                        : AppColors.textSecondary,
                    icon: Icons.show_chart_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Danger Events Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: _dangerCount > 0
                    ? AppColors.dangerRed.withOpacity(0.1)
                    : AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(
                  color: _dangerCount > 0 ? AppColors.dangerRed : AppColors.successGreen,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _dangerCount > 0 ? Icons.warning_rounded : Icons.check_circle_rounded,
                    color: _dangerCount > 0 ? AppColors.dangerRed : AppColors.successGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dangerCount > 0
                              ? '$_dangerCount Danger Events Today'
                              : 'No Danger Events Today',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _dangerCount > 0 ? AppColors.dangerRed : AppColors.successGreen,
                          ),
                        ),
                        Text(
                          _dangerCount > 0
                              ? 'Noise exceeded 1800 RMS threshold'
                              : 'Noise levels have been safe',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Notable Events Section (Dynamic from AlertService)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notable Events',
                  style: AppTextStyles.heading3,
                ),
                if (_alerts.isNotEmpty)
                  Text(
                    '${_alerts.length} events',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Alert event cards from AlertService
          if (_alerts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_note_rounded,
                        size: 48,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No notable events yet',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Events will appear when noise exceeds thresholds',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ..._alerts.map((alert) => NotableEventCard(
              time: _formatTime(alert.timestamp),
              description: alert.description,
              stressLevel: 0, // Not used for noise alerts
              isNoiseAlert: true,
              severity: alert.severity,
            )),

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
          child: child!,
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
              Text(
                title,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            value,
            style: AppTextStyles.valueMedium,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
