import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage configurable alert thresholds
/// These thresholds determine when alerts are triggered based on sensor values
class ThresholdSettings {
  // Singleton pattern
  static final ThresholdSettings _instance = ThresholdSettings._internal();
  factory ThresholdSettings() => _instance;
  ThresholdSettings._internal();

  // Stream controller to notify listeners of changes
  final _thresholdController = StreamController<void>.broadcast();
  Stream<void> get onThresholdChanged => _thresholdController.stream;

  // ============================================================
  // NOISE THRESHOLDS (RMS values from microphone)
  // ============================================================
  // Default values match Arduino: SEUIL_FAIBLE=800, SEUIL_DANGER=1800
  double _noiseWarningThreshold = 800.0;  // Above this = "Bruit modéré"
  double _noiseDangerThreshold = 1800.0;  // Above this = "DANGER"

  double get noiseWarningThreshold => _noiseWarningThreshold;
  double get noiseDangerThreshold => _noiseDangerThreshold;

  // ============================================================
  // HEART RATE THRESHOLDS (BPM values)
  // ============================================================
  double _heartRateLowThreshold = 60.0;   // Below this = warning
  double _heartRateHighThreshold = 100.0; // Above this = warning

  double get heartRateLowThreshold => _heartRateLowThreshold;
  double get heartRateHighThreshold => _heartRateHighThreshold;

  // ============================================================
  // PERSISTENCE KEYS
  // ============================================================
  static const String _keyNoiseWarning = 'threshold_noise_warning';
  static const String _keyNoiseDanger = 'threshold_noise_danger';
  static const String _keyHrLow = 'threshold_hr_low';
  static const String _keyHrHigh = 'threshold_hr_high';

  /// Initialize and load saved thresholds from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _noiseWarningThreshold = prefs.getDouble(_keyNoiseWarning) ?? 800.0;
    _noiseDangerThreshold = prefs.getDouble(_keyNoiseDanger) ?? 1800.0;
    _heartRateLowThreshold = prefs.getDouble(_keyHrLow) ?? 60.0;
    _heartRateHighThreshold = prefs.getDouble(_keyHrHigh) ?? 100.0;

    print('🔧 Thresholds loaded: Noise[$_noiseWarningThreshold/$_noiseDangerThreshold], HR[$_heartRateLowThreshold/$_heartRateHighThreshold]');
  }

  /// Set noise warning threshold (Bruit modéré)
  Future<void> setNoiseWarningThreshold(double value) async {
    _noiseWarningThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyNoiseWarning, value);
    _thresholdController.add(null);
    print('🔧 Noise warning threshold set to: $value');
  }

  /// Set noise danger threshold (DANGER)
  Future<void> setNoiseDangerThreshold(double value) async {
    _noiseDangerThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyNoiseDanger, value);
    _thresholdController.add(null);
    print('🔧 Noise danger threshold set to: $value');
  }

  /// Set heart rate low threshold
  Future<void> setHeartRateLowThreshold(double value) async {
    _heartRateLowThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyHrLow, value);
    _thresholdController.add(null);
    print('🔧 HR low threshold set to: $value');
  }

  /// Set heart rate high threshold
  Future<void> setHeartRateHighThreshold(double value) async {
    _heartRateHighThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyHrHigh, value);
    _thresholdController.add(null);
    print('🔧 HR high threshold set to: $value');
  }

  /// Determine noise status from RMS value
  /// Returns: "Calme", "Modéré", or "DANGER"
  String getNoiseStatus(double rmsValue) {
    if (rmsValue >= _noiseDangerThreshold) {
      return 'DANGER';
    } else if (rmsValue >= _noiseWarningThreshold) {
      return 'Modéré';
    } else {
      return 'Calme';
    }
  }

  /// Determine heart rate status from BPM value
  /// Returns: "Normal", "Low", or "High"
  String getHeartRateStatus(double bpmValue) {
    if (bpmValue <= 0) return 'No data';
    if (bpmValue < _heartRateLowThreshold) {
      return 'Low';
    } else if (bpmValue > _heartRateHighThreshold) {
      return 'High';
    } else {
      return 'Normal';
    }
  }

  /// Check if noise level is in danger zone
  bool isNoiseDanger(double rmsValue) => rmsValue >= _noiseDangerThreshold;

  /// Check if noise level is in warning zone
  bool isNoiseWarning(double rmsValue) =>
      rmsValue >= _noiseWarningThreshold && rmsValue < _noiseDangerThreshold;

  /// Check if heart rate is abnormal
  bool isHeartRateAbnormal(double bpmValue) =>
      bpmValue > 0 && (bpmValue < _heartRateLowThreshold || bpmValue > _heartRateHighThreshold);

  /// Dispose
  void dispose() {
    _thresholdController.close();
  }
}

