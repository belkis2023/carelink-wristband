import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/ble/ble_service.dart';
import '../../../core/services/ble/ble_device_model.dart';
import '../../../navigation/app_router.dart';

/// This screen allows users to scan for and connect to their CareLink wristband.
/// It appears after login and before the dashboard.
///
/// FLOW:
/// 1. User sees this screen after logging in
/// 2. App automatically starts scanning for devices
/// 3.  User sees a list of found devices
/// 4. User taps on their wristband to connect
/// 5. Once connected, app navigates to the dashboard

class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({super.key});

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  // Get the BLE service instance
  final BleService _bleService = BleService();

  // List of discovered devices
  List<BleDeviceModel> _devices = [];

  // Are we currently scanning?
  bool _isScanning = false;

  // Are we currently connecting?
  bool _isConnecting = false;

  // Error message to display (if any)
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Set up listeners and start scanning when the screen loads
    _setupListeners();
    _checkBluetoothAndScan();
  }

  /// Set up listeners for BLE events
  void _setupListeners() {
    // Listen for connection state changes
    _bleService.connectionState.listen((state) {
      setState(() {
        _isScanning = state == BleConnectionState.scanning;
        _isConnecting = state == BleConnectionState.connecting;
      });

      // If we successfully connected, go to the dashboard!
      if (state == BleConnectionState.connected) {
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }

      // If there was an error, show a message
      if (state == BleConnectionState.error) {
        setState(() {
          _errorMessage = 'Connection failed. Please try again.';
          _isConnecting = false;
        });
      }
    });

    // Listen for discovered devices
    _bleService.discoveredDevices.listen((devices) {
      setState(() {
        _devices = devices;
      });
    });
  }

  /// Check if Bluetooth is available and start scanning
  Future<void> _checkBluetoothAndScan() async {
    final isAvailable = await _bleService.isBluetoothAvailable();

    if (!isAvailable) {
      setState(() {
        _errorMessage = 'Please enable Bluetooth to connect your wristband';
      });
      return;
    }

    _startScan();
  }

  /// Start scanning for devices
  Future<void> _startScan() async {
    setState(() {
      _errorMessage = null;
    });
    await _bleService.startScan();
  }

  /// Connect to a specific device
  Future<void> _connectToDevice(BleDeviceModel device) async {
    setState(() {
      _errorMessage = null;
    });

    final success = await _bleService.connectToDevice(device);

    if (!success) {
      setState(() {
        _errorMessage =
            'Failed to connect to ${device.name}.  Please try again.';
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
              const SizedBox(height: AppConstants.paddingLarge),

              // ============================================================
              // HEADER SECTION (icon and instructions)
              // ============================================================
              Icon(Icons.watch_rounded, size: 80, color: AppColors.primaryBlue),
              const SizedBox(height: AppConstants.paddingMedium),

              Text(
                'Find Your CareLink Wristband',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingSmall),

              Text(
                'Make sure your wristband is turned on and nearby',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingLarge),

              // ============================================================
              // ERROR MESSAGE (if any)
              // ============================================================
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
                    border: Border.all(
                      color: AppColors.dangerRed.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.dangerRed),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.dangerRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ============================================================
              // MAIN CONTENT (scanning indicator or device list)
              // ============================================================
              Expanded(child: _buildMainContent()),

              // ============================================================
              // BOTTOM BUTTONS
              // ============================================================
              const SizedBox(height: AppConstants.paddingMedium),

              // Scan Again button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (_isScanning || _isConnecting) ? null : _startScan,
                  icon: Icon(_isScanning ? Icons.hourglass_top : Icons.refresh),
                  label: Text(_isScanning ? 'Scanning...' : 'Scan Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMedium,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),

              // Skip button (for testing only - remove in production!)
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRouter.dashboard);
                },
                child: Text(
                  'Skip for now (Testing only)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the main content based on current state
  Widget _buildMainContent() {
    // Show loading spinner while scanning
    if (_isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Scanning for devices... '),
          ],
        ),
      );
    }

    // Show loading spinner while connecting
    if (_isConnecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to wristband...'),
          ],
        ),
      );
    }

    // Show "no devices" message if list is empty
    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_searching,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text('No devices found', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 8),
            Text(
              'Make sure your wristband is turned on',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    // Show list of discovered devices
    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  /// Build a card for a single device
  Widget _buildDeviceCard(BleDeviceModel device) {
    // Determine if this is a CareLink device (highlight it!)
    final isCareLink = device.isCareLink;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        side: isCareLink
            ? BorderSide(color: AppColors.primaryBlue, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
        leading: Container(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          decoration: BoxDecoration(
            color: isCareLink
                ? AppColors.primaryBlue.withOpacity(0.1)
                : AppColors.lightBlueBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          child: Icon(
            Icons.watch_rounded,
            color: isCareLink ? AppColors.primaryBlue : AppColors.textLight,
            size: 32,
          ),
        ),
        title: Text(
          device.name,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: isCareLink ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                // Signal strength indicator
                ...List.generate(
                  3,
                  (i) => Icon(
                    Icons.signal_cellular_alt,
                    size: 12,
                    color: i < device.signalBars
                        ? AppColors.successGreen
                        : AppColors.textLight.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _signalStrengthText(device.signalBars),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            if (isCareLink)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '✓ CareLink Wristband',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _connectToDevice(device),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCareLink
                ? AppColors.primaryBlue
                : AppColors.secondaryBlue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Connect'),
        ),
      ),
    );
  }

  /// Convert signal bars to text
  String _signalStrengthText(int bars) {
    switch (bars) {
      case 3:
        return 'Excellent';
      case 2:
        return 'Good';
      case 1:
        return 'Fair';
      default:
        return 'Weak';
    }
  }
}
