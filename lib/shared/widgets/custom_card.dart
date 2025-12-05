import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// A reusable custom card widget that provides consistent styling across the app.
/// This widget wraps content in a rounded card with shadow and padding.
class CustomCard extends StatelessWidget {
  // The content to display inside the card
  final Widget child;

  // Optional padding inside the card (defaults to medium padding)
  final EdgeInsetsGeometry? padding;

  // Optional margin around the card
  final EdgeInsetsGeometry? margin;

  // Optional background color (defaults to white)
  final Color? color;

  // Optional callback when the card is tapped
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap the card in a GestureDetector if onTap is provided
    final cardWidget = Card(
      color: color ?? AppColors.cardBackground,
      elevation: AppConstants.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.paddingMedium),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
