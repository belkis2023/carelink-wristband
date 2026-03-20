import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_constants.dart';
import '../alert_service.dart';
import '../noise_history_service.dart';
import '../heart_rate_history_service.dart';

/// Connection states for the wristband
enum BleConnectionState { disconnected, scanning, connecting, connected, error }

/// Simplified BLE service - scans for ALL Bluetooth devices
class BleService {
  // Singleton pattern
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  // Current state
  BleConnectionState _currentState = BleConnectionState.disconnected;
  BleConnectionState get currentState => _currentState;
  bool get isConnected => _currentState == BleConnectionState.connected;

  // Stream controllers
  final _connectionStateController =
      StreamController<BleConnectionState>.broadcast();
  Stream<BleConnectionState> get connectionState =>
      _connectionStateController.stream;

  final _devicesController = StreamController<List<ScanResult>>.broadcast();
  Stream<List<ScanResult>> get discoveredDevices => _devicesController.stream;

  // Stream for all sensor values: Map<characteristicUuid, formattedValue>
  final _sensorValuesController =
      StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get sensorValuesStream =>
      _sensorValuesController.stream;

  // Connected device
  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Store multiple characteristics and their subscriptions
  final Map<String, BluetoothCharacteristic> _characteristics = {};
  final Map<String, StreamSubscription<List<int>>> _notifySubs = {};
  final Map<String, String> _sensorValues = {}; // UUID -> formatted value

  /// Get current sensor values
  Map<String, String> get sensorValues => Map.unmodifiable(_sensorValues);

  // Store discovered devices (use Map to avoid duplicates)
  final Map<String, ScanResult> _scanResultsMap = {};

  // Subscription to cancel later
  StreamSubscription? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;

  /// Start scanning for ALL Bluetooth devices
  Future<void> startScan() async {
    print('BLE: Starting scan...');
    _scanResultsMap.clear();
    _updateState(BleConnectionState.scanning);

    try {
      // Check if Bluetooth is on
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        print('BLE: Bluetooth is OFF.  Please turn it on.');
        _updateState(BleConnectionState.error);
        return;
      }

      // Cancel any existing subscription
      await _scanSubscription?.cancel();

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          // Use device ID as key to avoid duplicates
          final deviceId = result.device.remoteId.str;
          _scanResultsMap[deviceId] = result;

          String name = result.device.platformName.isNotEmpty
              ? result.device.platformName
              : 'Unknown Device';
          print('BLE: Found: $name ($deviceId)');
        }

        // Send updated list to UI
        final deviceList = _scanResultsMap.values.toList();

        // Sort: devices with names first, then by signal strength
        deviceList.sort((a, b) {
          final aHasName = a.device.platformName.isNotEmpty;
          final bHasName = b.device.platformName.isNotEmpty;

          if (aHasName && !bHasName) return -1;
          if (!aHasName && bHasName) return 1;
          return b.rssi.compareTo(a.rssi); // Stronger signal first
        });

        _devicesController.add(deviceList);
        print('BLE: Total unique devices: ${deviceList.length}');
      });

      // Start scanning (scan for 15 seconds)
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      print('BLE: Scan complete.  Found ${_scanResultsMap.length} devices.');
      _updateState(BleConnectionState.disconnected);
    } catch (e) {
      print('BLE: Scan error: $e');
      _updateState(BleConnectionState.error);
    }
  }

  /// Stop scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _updateState(BleConnectionState.disconnected);
  }

  /// Connect to a device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    print('BLE: Connecting to ${device.platformName}...');
    _updateState(BleConnectionState.connecting);

    try {
      // Stop scanning first
      await FlutterBluePlus.stopScan();

      // Clear previous subscriptions and values
      for (final sub in _notifySubs.values) {
        await sub.cancel();
      }
      _notifySubs.clear();
      _characteristics.clear();
      _sensorValues.clear();

      await device.connect(timeout: BleConstants.connectionTimeout);
      _connectedDevice = device;

      await _deviceStateSubscription?.cancel();
      _deviceStateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connected) {
          _updateState(BleConnectionState.connected);
          return;
        }

        if (state == BluetoothConnectionState.disconnected) {
          _connectedDevice = null;
          // Clear subscriptions on disconnect
          for (final sub in _notifySubs.values) {
            sub.cancel();
          }
          _notifySubs.clear();
          _characteristics.clear();
          _sensorValues.clear();
          _updateState(BleConnectionState.disconnected);
        }
      });

      print('BLE: Connected! Discovering services...');

      // Discover services
      final services = await device.discoverServices();
      print('BLE: Found ${services.length} services');

      // Find our service
      final service = services.cast<BluetoothService?>().firstWhere(
            (svc) => svc?.uuid.toString().toLowerCase() ==
                BleConstants.serviceUuid.toLowerCase(),
            orElse: () => null,
          );

      if (service == null) {
        print('BLE: ❌ Service ${BleConstants.serviceUuid} not found');
        _updateState(BleConnectionState.connected);
        return true;
      }

      print('BLE: ✅ Found service: ${service.uuid}');

      // Find the sensor characteristic
      BluetoothCharacteristic? sensorChar;
      for (final characteristic in service.characteristics) {
        final uuid = characteristic.uuid.toString().toLowerCase();
        if (uuid == BleConstants.sensorCharUuid.toLowerCase()) {
          sensorChar = characteristic;
          break;
        }
      }

      if (sensorChar == null) {
        print('BLE: ❌ Sensor characteristic ${BleConstants.sensorCharUuid} not found');
        _updateState(BleConnectionState.connected);
        return true;
      }

      print('BLE: ✅ Found sensor characteristic: ${sensorChar.uuid}');

      // Subscribe to the characteristic
      if (sensorChar.properties.notify) {
        await sensorChar.setNotifyValue(true);
        print('BLE: ✅ Subscribed to sensor data notifications');

        _notifySubs['sensor']?.cancel();
        _notifySubs['sensor'] = sensorChar.onValueReceived.listen((value) {
          final rawString = _formatValue(value);
          print('BLE: 📊 Raw sensor data: $rawString');

          // Parse the combined sensor string
          final parsed = _parseSensorData(rawString);
          _sensorValues.addAll(parsed);
          _sensorValuesController.add(Map.from(_sensorValues));

          // Process noise data for alerts and history
          final rmsValue = parsed['rms'] ?? '';
          if (rmsValue.isNotEmpty && rmsValue != '-') {
            // Pass just the RMS value - status is determined by app thresholds
            AlertService().processNoiseData(rmsValue);
            // For history, combine RMS with locally-determined status
            NoiseHistoryService().addDataPoint(rmsValue);
          }

          // Process heart rate data for alerts and history
          final bpmValue = parsed['bpm'] ?? '';
          if (bpmValue.isNotEmpty && bpmValue != '-' && bpmValue != '0') {
            AlertService().processHeartRateData(bpmValue);
            HeartRateHistoryService().addDataPoint(bpmValue);
          }
        });
      } else if (sensorChar.properties.read) {
        // For read-only characteristics, read once
        final value = await sensorChar.read();
        final rawString = _formatValue(value);
        final parsed = _parseSensorData(rawString);
        _sensorValues.addAll(parsed);
        _sensorValuesController.add(Map.from(_sensorValues));
      }

      print('BLE: ✅ Connected and subscribed to sensor data');

      _updateState(BleConnectionState.connected);
      return true;
    } catch (e) {
      print('BLE: Connection error: $e');
      _updateState(BleConnectionState.error);
      return false;
    }
  }

  /// Parse combined sensor data string into individual values
  /// Format: "RMS:21|NOISE:Calme|ACC:0.00|GYRO:0.00|STATE:Chute|BPM:0"
  Map<String, String> _parseSensorData(String rawData) {
    final result = <String, String>{
      'rms': '-',
      'noise': '-',
      'acc': '-',
      'gyro': '-',
      'state': '-',
      'bpm': '-',
    };

    if (rawData.isEmpty || rawData == '-') return result;

    // Split by pipe delimiter
    final parts = rawData.split('|');

    for (final part in parts) {
      // Each part is "KEY:VALUE"
      final keyValue = part.split(':');
      if (keyValue.length >= 2) {
        final key = keyValue[0].trim().toUpperCase();
        final value = keyValue.sublist(1).join(':').trim(); // Handle values with colons

        // Map to our result keys
        switch (key) {
          case 'RMS':
            result['rms'] = value;
            break;
          case 'NOISE':
            result['noise'] = value;
            break;
          case 'ACC':
            result['acc'] = value;
            break;
          case 'GYRO':
            result['gyro'] = value;
            break;
          case 'STATE':
            result['state'] = value;
            break;
          case 'BPM':
            result['bpm'] = value;
            break;
        }
      }
    }

    print('BLE: Parsed - RMS: ${result['rms']}, Noise: ${result['noise']}, '
          'ACC: ${result['acc']}, Gyro: ${result['gyro']}, '
          'State: ${result['state']}, BPM: ${result['bpm']}');
    return result;
  }

  /// Format sensor value from raw bytes
  String _formatValue(List<int> value) {
    if (value.isEmpty) return '-';

    // Try to decode as UTF-8/ASCII text
    try {
      // Remove trailing null bytes (common in C strings)
      final trimmedBytes = value.where((b) => b != 0).toList();
      if (trimmedBytes.isEmpty) return '-';

      final text = String.fromCharCodes(trimmedBytes).trim();

      // Check if most bytes are printable ASCII (allow some slack)
      final printableCount = trimmedBytes.where((b) =>
          (b >= 32 && b <= 126) || b == 10 || b == 13 || b == 9).length;
      final printableRatio = printableCount / trimmedBytes.length;

      if (printableRatio >= 0.8 && text.isNotEmpty) {
        return text;
      }
    } catch (_) {}

    // Fallback to numeric display
    if (value.length == 1) {
      return '${value.first}';
    }
    if (value.length == 2) {
      // Try little-endian 16-bit value
      return '${value[0] | (value[1] << 8)}';
    }

    // Fallback to hex display for longer data
    final hex = value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    return '0x$hex';
  }

  /// Disconnect
  Future<void> disconnect() async {
    // Cancel all subscriptions
    for (final sub in _notifySubs.values) {
      await sub.cancel();
    }
    _notifySubs.clear();
    _characteristics.clear();
    _sensorValues.clear();

    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }
    await _deviceStateSubscription?.cancel();
    _updateState(BleConnectionState.disconnected);
  }

  /// Update state
  void _updateState(BleConnectionState state) {
    _currentState = state;
    _connectionStateController.add(state);
    print('BLE: State changed to: $state');
  }

  /// Dispose
  void dispose() {
    _scanSubscription?.cancel();
    _deviceStateSubscription?.cancel();
    for (final sub in _notifySubs.values) {
      sub.cancel();
    }
    _notifySubs.clear();
    _connectionStateController.close();
    _devicesController.close();
    _sensorValuesController.close();
  }
}
