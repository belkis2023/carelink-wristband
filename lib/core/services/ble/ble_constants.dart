/// This file contains all the Bluetooth-related constants.
/// Think of it as a "settings" file for BLE configuration.
///
/// IMPORTANT: The UUIDs here must match what your ESP32 advertises!
/// If they don't match, the app won't find your wristband.

class BleConstants {
  // ============================================================
  // SERVICE UUID
  // ============================================================
  // This is like an "address" for your ESP32's Bluetooth service.
  // Your ESP32 code must use the SAME UUID.
  // You can generate your own at: https://www.uuidgenerator.net/
  //
  // Example: If your ESP32 code has:
  //   #define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
  // Then use that same value here:
  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";

  // ============================================================
  // CHARACTERISTIC UUID (Heart Rate)
  // ============================================================
  // A "characteristic" is a specific piece of data within a service.
  // This one is for heart rate data from your PPG sensor.
  // Again, must match your ESP32 code!
  static const String heartRateCharUuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  // ============================================================
  // DEVICE NAME PREFIX
  // ============================================================
  // What name does your ESP32 advertise?
  // If your ESP32 code has: BLEDevice::init("CareLink-001")
  // Then use "CareLink" here (the prefix/beginning of the name)
  static const String deviceNamePrefix = "CareLink";

  // ============================================================
  // TIMEOUTS
  // ============================================================
  // How long to scan before giving up (10 seconds)
  static const Duration scanTimeout = Duration(seconds: 10);

  // How long to wait when connecting before giving up (15 seconds)
  static const Duration connectionTimeout = Duration(seconds: 15);
}
