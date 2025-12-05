import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';

/// A slider widget for adjusting alert thresholds (stress level, noise level, etc.).
class ThresholdSlider extends StatefulWidget {
  // Label for the slider (e.g., "Stress Level Threshold")
  final String label;

  // Current slider value
  final double initialValue;

  // Minimum slider value
  final double min;

  // Maximum slider value
  final double max;

  // Number of divisions (for discrete values)
  final int divisions;

  // Unit suffix (e.g., "dB", "" for no unit)
  final String unit;

  // Callback when value changes
  final ValueChanged<double>? onChanged;

  const ThresholdSlider({
    super.key,
    required this.label,
    required this.initialValue,
    required this.min,
    required this.max,
    this.divisions = 10,
    this.unit = '',
    this.onChanged,
  });

  @override
  State<ThresholdSlider> createState() => _ThresholdSliderState();
}

class _ThresholdSliderState extends State<ThresholdSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              '${_currentValue.toStringAsFixed(1)}${widget.unit}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.secondaryBlue,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primaryBlue,
            overlayColor: AppColors.primaryBlue.withOpacity(0.1),
            valueIndicatorColor: AppColors.primaryBlue,
            valueIndicatorTextStyle: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
            ),
          ),
          child: Slider(
            value: _currentValue,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: '${_currentValue.toStringAsFixed(1)}${widget.unit}',
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
              widget.onChanged?.call(value);
            },
          ),
        ),
        // Min and Max labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.min.toStringAsFixed(1)}${widget.unit}',
              style: AppTextStyles.caption,
            ),
            Text(
              '${widget.max.toStringAsFixed(1)}${widget.unit}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }
}
