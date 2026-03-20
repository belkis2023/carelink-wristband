import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/services/ble/ble_service.dart';
import '../../../navigation/app_router.dart';

/// A card widget with wristband control options like haptic feedback toggle.
class WristbandControlsCard extends StatefulWidget {
  const WristbandControlsCard({super.key});

  @override
  State<WristbandControlsCard> createState() => _WristbandControlsCardState();
}

class _WristbandControlsCardState extends State<WristbandControlsCard> {
  // Track whether haptic feedback is enabled
  bool _hapticEnabled = true;
  final BleService _bleService = BleService();

  ({String label, Color color}) _statusForState(BleConnectionState state) {
    switch (state) {
      case BleConnectionState.connected:
        return (label: 'Connected', color: AppColors.successGreen);
      case BleConnectionState.connecting:
        return (label: 'Connecting...', color: AppColors.warningYellow);
      case BleConnectionState.scanning:
        return (label: 'Scanning...', color: AppColors.warningYellow);
      case BleConnectionState.error:
        return (label: 'Error', color: AppColors.dangerRed);
      case BleConnectionState.disconnected:
      default:
        return (label: 'Disconnected', color: AppColors.dangerRed);
    }
  }

  ({String label, bool enabled, bool isDisconnect}) _actionForState(BleConnectionState state) {
    switch (state) {
      case BleConnectionState.connected:
        return (label: 'Disconnect Wristband', enabled: true, isDisconnect: true);
      case BleConnectionState.connecting:
        return (label: 'Connecting...', enabled: false, isDisconnect: false);
      case BleConnectionState.scanning:
        return (label: 'Scanning...', enabled: false, isDisconnect: false);
      case BleConnectionState.error:
      case BleConnectionState.disconnected:
      default:
        return (label: 'Connect Wristband', enabled: true, isDisconnect: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          // Haptic Feedback Toggle
          Row(
            children: [
              Icon(
                Icons.vibration_rounded,
                color: AppColors.primaryBlue,
                size: AppConstants.iconMedium,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Text(
                  'Haptic Feedback',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              Switch(
                value: _hapticEnabled,
                onChanged: (value) {
                  setState(() {
                    _hapticEnabled = value;
                  });
                },
              ),
            ],
          ),
          const Divider(),

          // Device Status
          Row(
            children: [
              Icon(
                Icons.watch_rounded,
                color: AppColors.primaryBlue,
                size: AppConstants.iconMedium,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Text(
                  'Device Status',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              StreamBuilder<BleConnectionState>(
                stream: _bleService.connectionState,
                initialData: _bleService.currentState,
                builder: (context, snapshot) {
                  final status = _statusForState(
                    snapshot.data ?? BleConnectionState.disconnected,
                  );

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    child: Text(
                      status.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          StreamBuilder<BleConnectionState>(
            stream: _bleService.connectionState,
            initialData: _bleService.currentState,
            builder: (context, snapshot) {
              final action = _actionForState(
                snapshot.data ?? BleConnectionState.disconnected,
              );

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: action.enabled
                      ? () {
                          if (action.isDisconnect) {
                            // Disconnect from wristband
                            _bleService.disconnect();
                          } else {
                            // Navigate to device connection screen
                            Navigator.of(context).pushNamed(
                              AppRouter.deviceConnection,
                            );
                          }
                        }
                      : null,
                  icon: Icon(action.isDisconnect
                      ? Icons.bluetooth_disabled_rounded
                      : Icons.bluetooth_connected_rounded),
                  label: Text(action.label),
                  style: action.isDisconnect
                      ? ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dangerRed,
                          foregroundColor: Colors.white,
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
