import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_constants.dart';

/// This class represents a Bluetooth device we found while scanning.
///
/// WHY DO WE NEED THIS?
/// When we scan for Bluetooth devices, we get a lot of raw information.
/// This class organizes that information in a clean, easy-to-use way.
///
/// EXAMPLE:
/// Instead of dealing with raw Bluetooth data everywhere, we can do:
///   BleDeviceModel device = ... ;
///   print(device.name);       // "CareLink-001"
///   print(device.signalBars); // 3 (excellent signal)
///   print(device.isCareLink); // true

class BleDeviceModel {
  // ============================================================
  // PROPERTIES (the data this model holds)
  // ============================================================

  /// The actual Bluetooth device object (from flutter_blue_plus)
  /// We need this to connect to the device later
  final BluetoothDevice device;

  /// The name of the device (e.g., "CareLink-001")
  final String name;

  /// The unique ID of the device (like a MAC address: "AA:BB:CC:DD:EE:FF")
  final String id;

  /// Signal strength in dBm (decibels-milliwatts)
  /// Typical values: -30 (very close) to -90 (far away)
  /// Higher (less negative) = stronger signal
  final int rssi;

  // ============================================================
  // CONSTRUCTOR (how to create a new BleDeviceModel)
  // ============================================================

  BleDeviceModel({
    required this.device,
    required this.name,
    required this.id,
    required this.rssi,
  });

  // ============================================================
  // HELPER METHODS (useful calculations)
  // ============================================================

  /// Check if this device is a CareLink wristband
  /// Returns true if the device name starts with "CareLink"
  bool get isCareLink => name.startsWith(BleConstants.deviceNamePrefix);

  /// Convert signal strength (rssi) to a simple 0-3 "bars" indicator
  /// Like the WiFi bars on your phone!
  ///
  /// rssi >= -60  → 3 bars (Excellent - device is very close)
  /// rssi >= -70  → 2 bars (Good)
  /// rssi >= -80  → 1 bar  (Fair)
  /// rssi < -80   → 0 bars (Poor - device is far away)
  int get signalBars {
    if (rssi >= -60) return 3; // Excellent
    if (rssi >= -70) return 2; // Good
    if (rssi >= -80) return 1; // Fair
    return 0; // Poor
  }
}
