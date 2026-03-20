import 'dart:async';
import 'threshold_settings.dart';

/// Represents a single heart rate data point
class HeartRateDataPoint {
  final DateTime timestamp;
  final double bpmValue;
  final String status; // Normal, Low, High

  HeartRateDataPoint({
    required this.timestamp,
    required this.bpmValue,
    required this.status,
  });
}

/// Service to store heart rate history for charts
class HeartRateHistoryService {
  // Singleton pattern
  static final HeartRateHistoryService _instance = HeartRateHistoryService._internal();
  factory HeartRateHistoryService() => _instance;
  HeartRateHistoryService._internal();

  // Store heart rate data points (last 24 hours max)
  final List<HeartRateDataPoint> _dataPoints = [];
  static const int _maxDataPoints = 1000; // Limit storage

  // Stream controller for real-time updates
  final _historyController = StreamController<List<HeartRateDataPoint>>.broadcast();
  Stream<List<HeartRateDataPoint>> get historyStream => _historyController.stream;

  /// Get all data points
  List<HeartRateDataPoint> get dataPoints => List.unmodifiable(_dataPoints);

  /// Get data points for a specific time range
  List<HeartRateDataPoint> getDataPointsForRange(DateTime start, DateTime end) {
    return _dataPoints
        .where((dp) => dp.timestamp.isAfter(start) && dp.timestamp.isBefore(end))
        .toList();
  }

  /// Get data points for today
  List<HeartRateDataPoint> getTodayDataPoints() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return getDataPointsForRange(startOfDay, now);
  }

  /// Get data points for the last N minutes
  List<HeartRateDataPoint> getRecentDataPoints(int minutes) {
    final cutoff = DateTime.now().subtract(Duration(minutes: minutes));
    return _dataPoints.where((dp) => dp.timestamp.isAfter(cutoff)).toList();
  }

  /// Add a new heart rate data point
  /// Call this when receiving BLE data
  void addDataPoint(String rawValue) {
    print('💓 HeartRateHistory: Received raw value: $rawValue');

    // Parse the raw value
    final bpmValue = double.tryParse(rawValue) ?? 0;
    if (bpmValue <= 0) return; // Skip invalid values

    // Determine status using configurable thresholds
    final status = ThresholdSettings().getHeartRateStatus(bpmValue);

    final dataPoint = HeartRateDataPoint(
      timestamp: DateTime.now(),
      bpmValue: bpmValue,
      status: status,
    );

    _dataPoints.add(dataPoint);
    print('💓 HeartRateHistory: Added point - BPM: $bpmValue, Status: $status, Total points: ${_dataPoints.length}');

    // Trim old data if needed
    if (_dataPoints.length > _maxDataPoints) {
      _dataPoints.removeAt(0);
    }

    // Notify listeners
    _historyController.add(List.from(_dataPoints));
  }

  /// Get average BPM for a time period
  double getAverageBpm(DateTime start, DateTime end) {
    final points = getDataPointsForRange(start, end);
    if (points.isEmpty) return 0;

    final sum = points.fold<double>(0, (sum, dp) => sum + dp.bpmValue);
    return sum / points.length;
  }

  /// Get peak BPM for a time period
  HeartRateDataPoint? getPeakBpm(DateTime start, DateTime end) {
    final points = getDataPointsForRange(start, end);
    if (points.isEmpty) return null;

    return points.reduce((a, b) => a.bpmValue > b.bpmValue ? a : b);
  }

  /// Get lowest BPM for a time period
  HeartRateDataPoint? getLowestBpm(DateTime start, DateTime end) {
    final points = getDataPointsForRange(start, end);
    if (points.isEmpty) return null;

    return points.reduce((a, b) => a.bpmValue < b.bpmValue ? a : b);
  }

  /// Get abnormal events count for today
  int getTodayAbnormalCount() {
    return getTodayDataPoints()
        .where((dp) => dp.status.toUpperCase() != 'NORMAL')
        .length;
  }

  /// Clear all data
  void clear() {
    _dataPoints.clear();
    _historyController.add([]);
  }

  /// Dispose
  void dispose() {
    _historyController.close();
  }
}

