import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_constants.dart';
import 'ble_device_model.dart';

/// The different states our Bluetooth connection can be in
enum BleConnectionState {
  disconnected, // Not connected to any device
  scanning, // Currently looking for devices
  connecting, // Found a device, trying to connect
  connected, // Successfully connected!
  error, // Something went wrong
}

/// This service handles ALL Bluetooth communication with the wristband.
///
/// WHY USE A SERVICE?
/// Instead of putting Bluetooth code all over your app, you put it here.
/// Then any screen can use this service to:
///   - Scan for devices
///   - Connect to a device
///   - Receive heart rate data
///
/// SINGLETON PATTERN:
/// There's only ONE instance of this service in the entire app.
/// This ensures we don't have multiple Bluetooth connections fighting each other.

class BleService {
  // ============================================================
  // SINGLETON SETUP (ensures only one instance exists)
  // ============================================================

  // The single instance of this service
  static final BleService _instance = BleService._internal();

  // When you call BleService(), you get the existing instance
  factory BleService() => _instance;

  // Private constructor (can't create new instances from outside)
  BleService._internal();

  // ============================================================
  // STATE MANAGEMENT (tracking what's happening)
  // ============================================================

  // Current connection state
  BleConnectionState _currentState = BleConnectionState.disconnected;
  BleConnectionState get currentState => _currentState;
  bool get isConnected => _currentState == BleConnectionState.connected;

  // Stream controller for connection state (so UI can listen for changes)
  final _connectionStateController =
      StreamController<BleConnectionState>.broadcast();
  Stream<BleConnectionState> get connectionState =>
      _connectionStateController.stream;

  // ============================================================
  // DEVICE DISCOVERY (finding wristbands)
  // ============================================================

  // List of devices we've found
  final List<BleDeviceModel> _devices = [];

  // Stream controller for discovered devices
  final _devicesController = StreamController<List<BleDeviceModel>>.broadcast();
  Stream<List<BleDeviceModel>> get discoveredDevices =>
      _devicesController.stream;

  // ============================================================
  // HEART RATE DATA (from PPG sensor)
  // ============================================================

  // Stream controller for heart rate values
  final _heartRateController = StreamController<int>.broadcast();
  Stream<int> get heartRateStream => _heartRateController.stream;

  // Store the last known heart rate
  int _lastHeartRate = 0;
  int get lastHeartRate => _lastHeartRate;

  // ============================================================
  // CONNECTED DEVICE REFERENCES
  // ============================================================

  // The device we're connected to (null if not connected)
  BluetoothDevice? _connectedDevice;

  // The characteristic we read heart rate from
  BluetoothCharacteristic? _heartRateCharacteristic;

  // ============================================================
  // METHODS (things this service can do)
  // ============================================================

  /// Check if Bluetooth is available and turned on
  Future<bool> isBluetoothAvailable() async {
    try {
      // Check if the device supports Bluetooth
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        print('BLE: Bluetooth not supported on this device');
        return false;
      }

      // Check if Bluetooth is turned on
      final adapterState = await FlutterBluePlus.adapterState.first;
      final isOn = adapterState == BluetoothAdapterState.on;
      print('BLE: Bluetooth is ${isOn ? "ON" : "OFF"}');
      return isOn;
    } catch (e) {
      print('BLE: Error checking Bluetooth: $e');
      return false;
    }
  }

  /// Start scanning for BLE devices
  Future<void> startScan() async {
    print('BLE: Starting scan.. .');
    _updateState(BleConnectionState.scanning);
    _devices.clear();

    try {
      // Listen to scan results as they come in
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final deviceName = result.device.platformName;

          // Only add devices that have a name
          if (deviceName.isNotEmpty) {
            final device = BleDeviceModel(
              device: result.device,
              name: deviceName,
              id: result.device.remoteId.str,
              rssi: result.rssi,
            );

            // Check if we already have this device in our list
            final existingIndex = _devices.indexWhere((d) => d.id == device.id);

            if (existingIndex >= 0) {
              // Update existing device (signal strength may have changed)
              _devices[existingIndex] = device;
            } else {
              // Add new device
              _devices.add(device);
              print('BLE: Found device: ${device.name} (${device.id})');
            }
          }
        }

        // Notify listeners that the device list has changed
        _devicesController.add(List.from(_devices));
      });

      // Start the actual scan
      await FlutterBluePlus.startScan(timeout: BleConstants.scanTimeout);

      print('BLE: Scan complete.  Found ${_devices.length} devices.');
      _updateState(BleConnectionState.disconnected);
    } catch (e) {
      print('BLE: Scan error: $e');
      _updateState(BleConnectionState.error);
    }
  }

  /// Stop scanning for devices
  Future<void> stopScan() async {
    print('BLE: Stopping scan...');
    await FlutterBluePlus.stopScan();
    _updateState(BleConnectionState.disconnected);
  }

  /// Connect to a specific wristband device
  Future<bool> connectToDevice(BleDeviceModel deviceModel) async {
    print('BLE: Connecting to ${deviceModel.name}...');
    _updateState(BleConnectionState.connecting);

    try {
      // Step 1: Connect to the device
      await deviceModel.device.connect(timeout: BleConstants.connectionTimeout);
      print('BLE: Connected!  Discovering services...');

      _connectedDevice = deviceModel.device;

      // Step 2: Discover what services/characteristics the device has
      List<BluetoothService> services = await deviceModel.device
          .discoverServices();
      print('BLE: Found ${services.length} services');

      // Step 3: Find our specific service and characteristic
      for (BluetoothService service in services) {
        print('BLE: Service: ${service.uuid}');

        // Check if this is our CareLink service
        if (service.uuid.toString().toLowerCase() ==
            BleConstants.serviceUuid.toLowerCase()) {
          print('BLE: Found CareLink service! ');

          // Look for the heart rate characteristic
          for (BluetoothCharacteristic char in service.characteristics) {
            print('BLE: Characteristic: ${char.uuid}');

            if (char.uuid.toString().toLowerCase() ==
                BleConstants.heartRateCharUuid.toLowerCase()) {
              print('BLE: Found heart rate characteristic!');
              _heartRateCharacteristic = char;

              // Subscribe to heart rate notifications
              await _subscribeToHeartRate();
              break;
            }
          }
        }
      }

      _updateState(BleConnectionState.connected);
      print('BLE: Connection complete!');
      return true;
    } catch (e) {
      print('BLE: Connection error: $e');
      _updateState(BleConnectionState.error);
      return false;
    }
  }

  /// Subscribe to heart rate notifications from the wristband
  Future<void> _subscribeToHeartRate() async {
    if (_heartRateCharacteristic == null) {
      print('BLE: No heart rate characteristic to subscribe to');
      return;
    }

    try {
      // Enable notifications (tells the device to send us updates)
      await _heartRateCharacteristic!.setNotifyValue(true);
      print('BLE: Subscribed to heart rate notifications');

      // Listen for incoming heart rate values
      _heartRateCharacteristic!.onValueReceived.listen((value) {
        if (value.isNotEmpty) {
          // Parse the heart rate value
          // This assumes your ESP32 sends a single byte with the BPM
          // Adjust if your format is different!
          final heartRate = value[0];
          _lastHeartRate = heartRate;
          _heartRateController.add(heartRate);
          print('BLE: Heart rate received: $heartRate BPM');
        }
      });
    } catch (e) {
      print('BLE: Error subscribing to heart rate: $e');
    }
  }

  /// Disconnect from the current device
  Future<void> disconnect() async {
    print('BLE: Disconnecting.. .');

    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _heartRateCharacteristic = null;
    }

    _updateState(BleConnectionState.disconnected);
    print('BLE: Disconnected');
  }

  /// Update the connection state and notify listeners
  void _updateState(BleConnectionState state) {
    _currentState = state;
    _connectionStateController.add(state);
    print('BLE: State changed to: $state');
  }

  /// Clean up resources when the service is no longer needed
  void dispose() {
    _connectionStateController.close();
    _devicesController.close();
    _heartRateController.close();
  }
}
