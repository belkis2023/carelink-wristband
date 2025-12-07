import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../navigation/app_router.dart';

class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({super.key});

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  List<ScanResult> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _errorMessage;
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _devices = [];
      _errorMessage = null;
      _isScanning = true;
    });

    try {
      // Check Bluetooth
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        setState(() {
          _errorMessage = 'Please turn on Bluetooth';
          _isScanning = false;
        });
        return;
      }

      // Cancel previous subscription
      await _scanSubscription?.cancel();

      // Collect devices in a map to avoid duplicates
      final Map<String, ScanResult> deviceMap = {};

      // Listen to results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (var result in results) {
          deviceMap[result.device.remoteId.str] = result;
        }
      });

      // Scan for 8 seconds
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

      // After scan completes, update UI once
      if (mounted) {
        final deviceList = deviceMap.values.toList();

        // Sort: named devices first
        deviceList.sort((a, b) {
          final aName = a.device.platformName;
          final bName = b.device.platformName;
          if (aName.isNotEmpty && bName.isEmpty) return -1;
          if (aName.isEmpty && bName.isNotEmpty) return 1;
          return b.rssi.compareTo(a.rssi);
        });

        setState(() {
          _devices = deviceList;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Scan error: $e';
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    final name = device.platformName.isNotEmpty
        ? device.platformName
        : 'Device';

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      await FlutterBluePlus.stopScan();
      await device.connect(timeout: const Duration(seconds: 10));

      print('✅ Connected to $name!');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Connected successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Wait a moment so user sees the message
        await Future.delayed(const Duration(seconds: 1));

        // Navigate to dashboard
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRouter.dashboard);
        }
      }
    } catch (e) {
      print('❌ Connection failed: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to connect to $name';
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Connect Wristband'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.bluetooth_searching,
                  size: 48,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 8),
                Text('Select Your Wristband', style: AppTextStyles.heading2),
                const SizedBox(height: 4),
                Text(
                  _isScanning
                      ? 'Scanning.. .'
                      : '${_devices.length} devices found',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Progress bar
          if (_isScanning) const LinearProgressIndicator(),

          // Error
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // Device list
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: _isScanning
                        ? const CircularProgressIndicator()
                        : const Text(
                            'No devices found.  Tap Scan to try again. ',
                          ),
                  )
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final result = _devices[index];
                      final device = result.device;
                      final name = device.platformName.isNotEmpty
                          ? device.platformName
                          : 'Unknown Device';
                      final isCareLink = name.toLowerCase().contains(
                        'carelink',
                      );

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isCareLink
                              ? Border.all(
                                  color: AppColors.primaryBlue,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isCareLink
                                      ? AppColors.primaryBlue.withOpacity(0.1)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isCareLink ? Icons.watch : Icons.bluetooth,
                                  color: isCareLink
                                      ? AppColors.primaryBlue
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name and signal
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: isCareLink
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Signal: ${result.rssi} dBm',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Connect button
                              SizedBox(
                                width: 80,
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: _isConnecting
                                      ? null
                                      : () => _connect(device),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCareLink
                                        ? AppColors.primaryBlue
                                        : AppColors.secondaryBlue,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Connect',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_isScanning || _isConnecting)
                        ? null
                        : _startScan,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(_isScanning ? 'Scanning...' : 'Scan Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRouter.dashboard,
                  ),
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
