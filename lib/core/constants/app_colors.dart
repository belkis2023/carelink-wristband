import 'package:flutter/material.dart';

/// This file contains all the color definitions used in the CareLink Wristband app.
/// Using a centralized color palette ensures consistency across the app. 
class AppColors {
  // Primary Colors - Main brand colors used for headers, icons, and key UI elements
  static const Color primaryBlue = Color(0xFF1E5A8D); // Dark blue for icons and headers
  static const Color secondaryBlue = Color(0xFF4A90B8); // Medium blue for progress bars and accents
  static const Color lightBlueBackground = Color(0xFFE8F4F8); // Light blue for icon backgrounds

  // Status Colors - Used to indicate different states and alerts
  static const Color successGreen = Color(0xFF4CAF50); // Connection status, "ON" badges
  static const Color warningYellow = Color(0xFFFFD54F); // Yellow alert icons
  static const Color warningOrange = Color(0xFFFF9800); // Orange for warnings  ← ADD THIS LINE
  static const Color dangerRed = Color(0xFFE53935); // Red alert icons

  // Background Colors - Used for screens, cards, and containers
  static const Color background = Color(0xFFF5F7FA); // Light gray background
  static const Color cardBackground = Color(0xFFFFFFFF); // White card backgrounds

  // Text Colors - Used for different text hierarchies
  static const Color textPrimary = Color(0xFF1A1A2E); // Dark navy/black for main text
  static const Color textSecondary = Color(0xFF6B7280); // Gray for secondary text

  // Additional UI Colors
  static const Color divider = Color(0xFFE5E7EB); // For dividers and borders
  static const Color disabled = Color(0xFFBDBDBD); // For disabled elements
}