# CareLink Wristband - Quick Start Guide

This guide will help you get the CareLink Wristband app running on your device.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.10.1 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter --version`

2. **An IDE** (choose one):
   - **VS Code** with Flutter extension
   - **Android Studio** with Flutter plugin
   - **IntelliJ IDEA** with Flutter plugin

3. **Device/Emulator**:
   - **Android**: Android Studio with AVD (Android Virtual Device)
   - **iOS**: Xcode with iOS Simulator (macOS only)
   - **Physical Device**: Connected via USB with developer mode enabled

## 🚀 Installation Steps

### Step 1: Get the Code
```bash
# Clone the repository
git clone https://github.com/belkis2023/carelink-wristband.git

# Navigate to the project directory
cd carelink-wristband
```

### Step 2: Install Dependencies
```bash
# This downloads all required packages (including fl_chart for charts)
flutter pub get
```

### Step 3: Verify Setup
```bash
# Check if Flutter can detect your devices
flutter devices

# You should see available devices/emulators listed
```

### Step 4: Run the App
```bash
# Run on the default device
flutter run

# Or specify a device
flutter run -d <device-id>

# For release mode (better performance)
flutter run --release
```

## 📱 First Run

When you first launch the app, you'll see the **Login Screen**.

### Testing the App

Since this is UI-only (no backend), you can log in with any credentials:

1. **Email**: Enter any valid-looking email (e.g., `test@example.com`)
   - Must contain an `@` symbol
   
2. **Password**: Enter any password with 6+ characters (e.g., `password123`)

3. Click **"Sign In"** to access the main app

### Exploring the App

After logging in, you'll arrive at the **Dashboard** with bottom navigation:

- **Dashboard Tab** (🏠): View real-time monitoring data
- **History Tab** (📊): See trends and historical data
- **Alerts Tab** (🔔): Review notifications and alerts
- **Settings Tab** (⚙️): Configure preferences and thresholds

## 🎯 What You'll See

### Dashboard Screen
- Connection status indicator (green dot)
- Current stress level with progress bar
- Metrics grid: Heart Rate, Motion, Noise, Battery
- Haptic feedback toggle
- About metrics section

### History Screen
- Date selector (tap to change date)
- Line chart with today's trends
- Average and peak stress cards
- Weekly bar chart
- Notable events timeline

### Alerts Screen
- Alert thresholds info
- New alerts (3 unread)
- Earlier alerts (5 historical)
- Color-coded by severity

### Settings Screen
- User profile card
- Wristband controls
- Alert threshold sliders
- Data & privacy options
- Sign out button

## 🔧 Development Tips

### Hot Reload
When you make code changes:
- Press `r` in the terminal (or save in VS Code with hot reload enabled)
- Changes apply instantly without restarting the app

### Hot Restart
For larger changes (adding new files, changing app structure):
- Press `R` in the terminal
- Fully restarts the app

### Debug Mode vs Release Mode
- **Debug mode**: `flutter run` - Includes debug tools, slower performance
- **Release mode**: `flutter run --release` - Optimized, production-like performance

### Device Selection
```bash
# List all available devices
flutter devices

# Run on specific device
flutter run -d chrome         # Web browser
flutter run -d windows        # Windows desktop
flutter run -d android        # Android device/emulator
flutter run -d ios            # iOS simulator/device
```

## 🐛 Troubleshooting

### Issue: "flutter: command not found"
**Solution**: 
- Ensure Flutter SDK is properly installed
- Add Flutter to your PATH environment variable
- Restart your terminal

### Issue: "No devices found"
**Solution**:
- **Android**: Start an Android emulator from Android Studio
- **iOS**: Open Xcode and start iOS Simulator
- **Physical Device**: Enable developer mode and connect via USB

### Issue: "Error resolving dependencies"
**Solution**:
```bash
# Clean the project
flutter clean

# Re-download dependencies
flutter pub get

# Try running again
flutter run
```

### Issue: "Gradle build failed" (Android)
**Solution**:
```bash
# Navigate to android folder
cd android

# Clean Gradle cache
./gradlew clean

# Return to project root
cd ..

# Run again
flutter run
```

### Issue: "CocoaPods error" (iOS)
**Solution**:
```bash
# Navigate to iOS folder
cd ios

# Remove existing pods
rm -rf Pods Podfile.lock

# Reinstall pods
pod install

# Return to project root
cd ..

# Run again
flutter run
```

## 📚 Learning Resources

### Flutter Documentation
- Official Docs: https://flutter.dev/docs
- Widget Catalog: https://flutter.dev/docs/development/ui/widgets
- Cookbook: https://flutter.dev/docs/cookbook

### Video Tutorials
- Flutter YouTube Channel: https://www.youtube.com/c/flutterdev
- Code with Andrea: https://codewithandrea.com/
- Fireship.io: https://fireship.io/

### Community
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: [flutter] tag
- Reddit: r/FlutterDev

## 🎨 Customization

Want to customize the app? Start with these files:

### Colors
Edit `lib/core/constants/app_colors.dart`
```dart
static const Color primaryBlue = Color(0xFF1E5A8D); // Change this!
```

### Text Styles
Edit `lib/core/constants/app_text_styles.dart`
```dart
static const TextStyle heading1 = TextStyle(
  fontSize: 28, // Change font sizes
  fontWeight: FontWeight.bold,
);
```

### Spacing & Sizes
Edit `lib/core/constants/app_constants.dart`
```dart
static const double paddingMedium = 16.0; // Adjust spacing
```

### Mock Data
Update the hardcoded values in screen files:
- Dashboard: `lib/features/dashboard/screens/dashboard_screen.dart`
- History: `lib/features/history/screens/history_screen.dart`
- Alerts: `lib/features/alerts/screens/alerts_screen.dart`

## 🚢 Building for Production

### Android APK
```bash
# Build APK (Android Package)
flutter build apk --release

# Find the APK at: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Google Play)
```bash
# Build AAB (Android App Bundle)
flutter build appbundle --release

# Find the AAB at: build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA (macOS only)
```bash
# Build iOS app
flutter build ios --release

# Open Xcode to archive and export IPA
open ios/Runner.xcworkspace
```

## 📊 App Statistics

- **Total Screens**: 7
- **Total Widgets**: 31 custom widgets
- **Lines of Code**: ~3,700
- **Dependencies**: 3 (flutter, cupertino_icons, fl_chart)
- **Supported Platforms**: iOS, Android, Web, Desktop (with minimal changes)

## 🔄 Next Steps

This is a UI-only implementation. To make it fully functional:

1. **Add Backend API**
   - User authentication
   - Real-time data streaming
   - Alert management

2. **Integrate Bluetooth**
   - Connect to wristband device
   - Receive sensor data
   - Send haptic feedback commands

3. **Add Data Persistence**
   - Local storage (SQLite, Hive)
   - Cloud sync (Firebase, AWS)
   - Export functionality

4. **Implement Push Notifications**
   - Firebase Cloud Messaging
   - Local notifications
   - Alert triggers

5. **Add Analytics**
   - User behavior tracking
   - Crash reporting
   - Performance monitoring

## 💡 Tips for Beginners

1. **Start Simple**: Focus on understanding one screen at a time
2. **Use Hot Reload**: Make small changes and see them instantly
3. **Read Comments**: The code includes extensive comments explaining everything
4. **Follow the Structure**: The app uses a feature-based folder structure
5. **Explore Widgets**: Open widget files to see how UI components are built
6. **Modify Values**: Change colors, text, or data to see how things work
7. **Ask for Help**: Use Flutter's community resources when stuck

## 📞 Support

For issues or questions:
- Check `IMPLEMENTATION_SUMMARY.md` for technical details
- Review `SCREENS.md` for screen-by-screen breakdown
- Open an issue on GitHub
- Refer to Flutter documentation

---

**Happy Coding! 🎉**

Start exploring the app and feel free to modify it to learn Flutter development!
