import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';

/// This file defines the overall theme configuration for the CareLink Wristband app.
/// The theme controls colors, text styles, and other visual elements app-wide.
class AppTheme {
  /// Returns the light theme configuration for the app
  static ThemeData get lightTheme {
    return ThemeData(
      // Use Material 3 design system
      useMaterial3: true,

      // Color Scheme - Defines primary, secondary, and background colors
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryBlue,
        surface: AppColors.cardBackground,
        background: AppColors.background,
        error: AppColors.dangerRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),

      // Scaffold Background - Default background color for all screens
      scaffoldBackgroundColor: AppColors.background,

      // App Bar Theme - Styling for the top app bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.heading2,
        iconTheme: IconThemeData(
          color: AppColors.primaryBlue,
          size: AppConstants.iconMedium,
        ),
      ),

      // Card Theme - Styling for cards used throughout the app
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: AppConstants.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
      ),

      // Button Themes - Styling for different button types
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeightMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          elevation: AppConstants.elevationLow,
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue, width: 2),
          minimumSize: const Size(double.infinity, AppConstants.buttonHeightMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primaryBlue),
        ),
      ),

      // Input Decoration Theme - Styling for text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.dangerRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingMedium,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        labelStyle: AppTextStyles.label,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryBlue,
        size: AppConstants.iconMedium,
      ),

      // Switch Theme - Styling for toggle switches
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return AppColors.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.successGreen;
          }
          return AppColors.disabled;
        }),
      ),

      // Slider Theme - Styling for sliders
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.secondaryBlue,
        inactiveTrackColor: AppColors.divider,
        thumbColor: AppColors.primaryBlue,
        overlayColor: AppColors.primaryBlue.withOpacity(0.1),
        valueIndicatorColor: AppColors.primaryBlue,
        valueIndicatorTextStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppConstants.paddingMedium,
      ),

      // Text Theme - Default text styles for the app
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.heading1,
        displayMedium: AppTextStyles.heading2,
        displaySmall: AppTextStyles.heading3,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.caption,
      ),
    );
  }
}
