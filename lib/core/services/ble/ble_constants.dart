/// This file contains all the Bluetooth-related constants.
/// Think of it as a "settings" file for BLE configuration.
///
/// IMPORTANT: The UUIDs here must match what your ESP32 advertises!
/// If they don't match, the app won't find your wristband.

class BleConstants {
  // ============================================================
  // SERVICE UUID
  // ============================================================
  static const String serviceUuid = "12345678-1234-1234-1234-1234567890ab";

  // ============================================================
  // CHARACTERISTIC UUID (Single characteristic for all sensor data)
  // Format: "RMS:21|NOISE:Calme|ACC:0.00|GYRO:0.00|STATE:Chute|BPM:0"
  // ============================================================
  static const String sensorCharUuid = "abcdefab-1234-5678-1234-abcdefabcdef";

  // ============================================================
  // SENSOR DATA KEYS (keys in the parsed string)
  // ============================================================
  static const String keyRms = 'RMS';
  static const String keyNoise = 'NOISE';
  static const String keyAcc = 'ACC';
  static const String keyGyro = 'GYRO';
  static const String keyState = 'STATE';
  static const String keyBpm = 'BPM';

  // ============================================================
  // DEVICE NAME PREFIX
  // ============================================================
  static const String deviceNamePrefix = "CareLink";

  // ============================================================
  // TIMEOUTS
  // ============================================================
  static const Duration scanTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 15);
}
