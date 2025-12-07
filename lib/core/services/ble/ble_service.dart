import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

  final _heartRateController = StreamController<int>.broadcast();
  Stream<int> get heartRateStream => _heartRateController.stream;

  // Connected device
  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Store discovered devices (use Map to avoid duplicates)
  final Map<String, ScanResult> _scanResultsMap = {};

  // Subscription to cancel later
  StreamSubscription? _scanSubscription;

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

      await device.connect(timeout: const Duration(seconds: 15));
      _connectedDevice = device;

      print('BLE: Connected!  Discovering services...');

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      print('BLE: Found ${services.length} services');

      // Log all services and characteristics (for debugging)
      for (BluetoothService service in services) {
        print('BLE: Service: ${service.uuid}');
        for (BluetoothCharacteristic char in service.characteristics) {
          print('BLE:   - Characteristic: ${char.uuid}');
        }
      }

      _updateState(BleConnectionState.connected);
      return true;
    } catch (e) {
      print('BLE: Connection error: $e');
      _updateState(BleConnectionState.error);
      return false;
    }
  }

  /// Disconnect
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }
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
    _connectionStateController.close();
    _devicesController.close();
    _heartRateController.close();
  }
}
