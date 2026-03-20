import 'dart:async';
import 'threshold_settings.dart';

/// Represents a single noise data point
class NoiseDataPoint {
  final DateTime timestamp;
  final double rmsValue;
  final String status; // Calme, Moderate, DANGER

  NoiseDataPoint({
    required this.timestamp,
    required this.rmsValue,
    required this.status,
  });
}

/// Service to store noise history for charts
class NoiseHistoryService {
  // Singleton pattern
  static final NoiseHistoryService _instance = NoiseHistoryService._internal();
  factory NoiseHistoryService() => _instance;
  NoiseHistoryService._internal();

  // Store noise data points (last 24 hours max)
  final List<NoiseDataPoint> _dataPoints = [];
  static const int _maxDataPoints = 1000; // Limit storage

  // Stream controller for real-time updates
  final _historyController = StreamController<List<NoiseDataPoint>>.broadcast();
  Stream<List<NoiseDataPoint>> get historyStream => _historyController.stream;

  /// Get all data points
  List<NoiseDataPoint> get dataPoints => List.unmodifiable(_dataPoints);

  /// Get data points for a specific time range
  List<NoiseDataPoint> getDataPointsForRange(DateTime start, DateTime end) {
    return _dataPoints
        .where((dp) => dp.timestamp.isAfter(start) && dp.timestamp.isBefore(end))
        .toList();
  }

  /// Get data points for today
  List<NoiseDataPoint> getTodayDataPoints() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return getDataPointsForRange(startOfDay, now);
  }

  /// Get data points for the last N minutes
  List<NoiseDataPoint> getRecentDataPoints(int minutes) {
    final cutoff = DateTime.now().subtract(Duration(minutes: minutes));
    return _dataPoints.where((dp) => dp.timestamp.isAfter(cutoff)).toList();
  }

  /// Add a new noise data point
  /// Call this when receiving BLE data
  void addDataPoint(String rawValue) {
    print('📈 NoiseHistory: Received raw value: $rawValue');

    // Parse the raw value - can be just RMS number or "RMS | Status"
    double rmsValue = 0;
    String status = 'Unknown';

    // Extract numeric RMS value
    final rmsString = rawValue.replaceAll(RegExp(r'[^0-9.]'), '');
    rmsValue = double.tryParse(rmsString) ?? 0;

    // Determine status using configurable thresholds
    status = ThresholdSettings().getNoiseStatus(rmsValue);

    final dataPoint = NoiseDataPoint(
      timestamp: DateTime.now(),
      rmsValue: rmsValue,
      status: status,
    );

    _dataPoints.add(dataPoint);
    print('📈 NoiseHistory: Added point - RMS: $rmsValue, Status: $status, Total points: ${_dataPoints.length}');

    // Trim old data if needed
    if (_dataPoints.length > _maxDataPoints) {
      _dataPoints.removeAt(0);
    }

    // Notify listeners
    _historyController.add(List.from(_dataPoints));
  }

  /// Get average RMS for a time period
  double getAverageRms(DateTime start, DateTime end) {
    final points = getDataPointsForRange(start, end);
    if (points.isEmpty) return 0;

    final sum = points.fold<double>(0, (sum, dp) => sum + dp.rmsValue);
    return sum / points.length;
  }

  /// Get peak RMS for a time period
  NoiseDataPoint? getPeakRms(DateTime start, DateTime end) {
    final points = getDataPointsForRange(start, end);
    if (points.isEmpty) return null;

    return points.reduce((a, b) => a.rmsValue > b.rmsValue ? a : b);
  }

  /// Get danger events count for today
  int getTodayDangerCount() {
    return getTodayDataPoints()
        .where((dp) => dp.status.toUpperCase().contains('DANGER'))
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

