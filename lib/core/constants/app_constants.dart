/// This file contains all constant values used throughout the CareLink Wristband app.
/// This includes sizing, spacing, padding, and other static values.
class AppConstants {
  // Spacing and Padding - Used to maintain consistent spacing throughout the app
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius - Used for rounded corners on cards and buttons
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Icon Sizes
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Card Elevation - Used for shadow depth on cards
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // App Bar Height
  static const double appBarHeight = 56.0;

  // Bottom Navigation Bar Height
  static const double bottomNavBarHeight = 70.0;

  // Avatar Sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 96.0;

  // Progress Bar Heights
  static const double progressBarHeight = 8.0;
  static const double progressBarHeightLarge = 12.0;

  // Metric Value Ranges - Used for stress levels and other metrics
  static const double stressMin = 0.0;
  static const double stressMax = 10.0;
  static const double stressWarningThreshold = 7.0;

  static const double noiseMin = 0.0;
  static const double noiseMax = 100.0;
  static const double noiseWarningThreshold = 75.0;

  // App Strings
  static const String appName = 'CareLink Wristband';
  static const String monitoredIndividual = 'Alex Johnson';
  static const String individualAge = '14';
}
