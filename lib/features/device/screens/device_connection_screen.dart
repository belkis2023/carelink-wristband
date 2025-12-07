import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/ble/ble_service.dart';
import '../../../navigation/app_router.dart';

class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({super.key});

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  final BleService _bleService = BleService();
  List<ScanResult> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _startScan();
  }

  void _setupListeners() {
    // Listen for connection state changes
    _bleService.connectionState.listen((state) {
      if (mounted) {
        setState(() {
          _isScanning = state == BleConnectionState.scanning;
          _isConnecting = state == BleConnectionState.connecting;
        });

        if (state == BleConnectionState.connected) {
          Navigator.pushReplacementNamed(context, AppRouter.dashboard);
        }

        if (state == BleConnectionState.error && !_isScanning) {
          setState(() {
            _errorMessage = 'Connection failed. Please try again.';
          });
        }
      }
    });

    // Listen for discovered devices
    _bleService.discoveredDevices.listen((devices) {
      print('UI: Received ${devices.length} devices');
      if (mounted) {
        setState(() {
          _devices = devices;
        });
      }
    });
  }

  Future<void> _startScan() async {
    setState(() {
      _errorMessage = null;
      _devices = [];
    });

    // Check if Bluetooth is on
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      setState(() {
        _errorMessage = 'Please turn on Bluetooth';
      });

      // Try to turn on Bluetooth (Android only)
      await FlutterBluePlus.turnOn();
      return;
    }

    await _bleService.startScan();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _errorMessage = null;
    });

    final success = await _bleService.connectToDevice(device);
    if (!success) {
      setState(() {
        _errorMessage = 'Failed to connect.  Please try again.';
      });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            children: [
              const SizedBox(height: AppConstants.paddingMedium),

              // Header
              Icon(
                Icons.bluetooth_searching,
                size: 60,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'Find Your Wristband',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'Select your CareLink wristband from the list below',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Error message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  margin: const EdgeInsets.only(
                    bottom: AppConstants.paddingMedium,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.dangerRed),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppColors.dangerRed),
                        ),
                      ),
                    ],
                  ),
                ),

              // Device list or status
              Expanded(child: _buildContent()),

              // Buttons at bottom
              const SizedBox(height: AppConstants.paddingMedium),

              // Scan button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (_isScanning || _isConnecting) ? null : _startScan,
                  icon: _isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isScanning ? 'Scanning...' : 'Scan for Devices'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),

              // Skip button (for testing)
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRouter.dashboard);
                },
                child: Text(
                  'Skip for now',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Scanning for Bluetooth devices...'),
          ],
        ),
      );
    }

    if (_isConnecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting... '),
          ],
        ),
      );
    }

    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text('No devices found', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 8),
            Text(
              'Make sure Bluetooth is on and your\nwristband is nearby',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show list of ALL discovered devices
    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final result = _devices[index];
        final device = result.device;
        final name = device.platformName.isNotEmpty
            ? device.platformName
            : 'Unknown Device';
        final rssi = result.rssi;

        // Highlight CareLink devices
        final isCareLink = name.toLowerCase().contains('carelink');

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isCareLink
                ? BorderSide(color: AppColors.primaryBlue, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCareLink
                    ? AppColors.primaryBlue.withOpacity(0.1)
                    : AppColors.lightBlueBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCareLink ? Icons.watch : Icons.bluetooth,
                color: isCareLink
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
              ),
            ),
            title: Text(
              name,
              style: TextStyle(
                fontWeight: isCareLink ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${device.remoteId}'),
                Text('Signal: $rssi dBm'),
                if (isCareLink)
                  Text(
                    '✓ CareLink Wristband',
                    style: TextStyle(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: _isConnecting ? null : () => _connectToDevice(device),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCareLink
                    ? AppColors.primaryBlue
                    : AppColors.secondaryBlue,
              ),
              child: const Text('Connect'),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
