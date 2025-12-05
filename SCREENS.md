# CareLink Wristband - Screen Guide

This document provides a detailed overview of each screen in the CareLink Wristband app.

## 🔐 Authentication Flow

### 1. Login Screen
**File**: `lib/features/auth/screens/login_screen.dart`

**Components**:
- CareLink watch icon (80px)
- App title "CareLink Wristband"
- Tagline "Monitor. Care. Connect."
- Welcome text "Welcome Back"
- Email input field with validation
- Password input field with show/hide toggle
- "Forgot Password?" link
- "Sign In" button (full width, blue)
- "Don't have an account? Sign Up" link

**Navigation**:
- Sign In → Dashboard Screen
- Forgot Password → Forgot Password Screen
- Sign Up → Sign Up Screen

---

### 2. Sign Up Screen
**File**: `lib/features/auth/screens/signup_screen.dart`

**Components**:
- Back button in app bar
- "Create Account" header
- Full name input field
- Email input field with validation
- Password input field with visibility toggle
- Confirm password field (validates match)
- Terms & conditions checkbox
- "Create Account" button
- "Already have an account? Sign In" link

**Navigation**:
- Create Account → Dashboard Screen
- Sign In → Back to Login Screen

---

### 3. Forgot Password Screen
**File**: `lib/features/auth/screens/forgot_password_screen.dart`

**Components**:
- Lock reset icon (80px)
- "Forgot Password?" header
- Instruction text
- Email input field
- "Send Reset Link" button
- "Back to Sign In" link
- Success snackbar on submit

**Navigation**:
- Back → Login Screen
- After 2 seconds → Auto navigate to Login

---

## 📊 Main App Screens (With Bottom Navigation)

### 4. Dashboard Screen
**File**: `lib/features/dashboard/screens/dashboard_screen.dart`

**App Bar**:
- Title: "Alex's Monitor"
- Green dot + "Wristband connected" status

**Content**:
1. **Current Status Section**
   - Header: "Current Status"
   - Subtitle: "Real-time monitoring data"

2. **Stress Level Card** (full width)
   - Heart icon with blue background
   - "Stress Level (GSR)" title
   - Status label: "Moderate" (color-coded)
   - Large value: "6.2"
   - Progress bar (0-10 scale)
   - Scale markers: 0, 5, 10

3. **Metrics Grid** (2x2)
   - **Heart Rate**: 78 (BPM icon)
   - **Motion**: Moderate (walk icon)
   - **Noise Level**: 65 dB (volume icon)
   - **Battery**: 68% (battery icon, green)

4. **Haptic Feedback Card**
   - Vibration icon
   - "Haptic Feedback" title
   - "Active" badge
   - ON/OFF toggle switch

5. **About These Metrics**
   - Info icon + "About These Metrics" header
   - Detailed explanations for each metric:
     - Stress Level (GSR)
     - Heart Rate
     - Motion
     - Noise Level
     - Haptic Feedback

**Bottom Nav**: Dashboard (active), History, Alerts, Settings

---

### 5. History Screen
**File**: `lib/features/history/screens/history_screen.dart`

**App Bar**: Same as Dashboard

**Content**:
1. **Date Selector Card**
   - Calendar icon
   - "Today - Nov 27, 2025"
   - Chevron (tappable for date picker)

2. **Metrics Chart**
   - "Today's Metrics" title
   - Legend: Heart Rate (red), Noise dB (yellow), Stress (blue)
   - Line chart (8AM - 4PM timeline)
   - X-axis: Time labels
   - Y-axis: 0-100 scale

3. **Summary Cards** (2 columns)
   - **Avg Stress**: 5.3, "-0.8 from yesterday" (green)
   - **Peak Stress**: 7.2, "at 11:15 AM"

4. **Weekly Average Stress**
   - Bar chart for Mon-Sun
   - Color-coded bars (green/yellow/red based on value)
   - Values displayed: 5.2, 6.1, 4.8, 7.2, 5.5, 3.9, 4.5

5. **Notable Events**
   - Section header
   - Event cards with:
     - Time badge (e.g., "11:15 AM")
     - Description text
     - Stress level badge (color-coded)
   - Events:
     - 11:15 AM: High stress spike during presentation (7.2)
     - 2:30 PM: Noise exceeded 75dB (6.5)
     - 4:45 PM: Stress normalized after activity (4.1)

**Bottom Nav**: Dashboard, History (active), Alerts, Settings

---

### 6. Alerts Screen
**File**: `lib/features/alerts/screens/alerts_screen.dart`

**App Bar**: Same as Dashboard

**Content**:
1. **Alert Thresholds Card**
   - Info icon
   - "Alert Thresholds" title
   - "You will be notified when:" list
   - 4 threshold conditions listed

2. **New Alerts Section**
   - "New (3)" header
   - **High Stress Alert** (red icon, unread dot)
     - "Stress level reached 8.5..."
     - "15 minutes ago"
   - **Noise Level Warning** (yellow icon, unread dot)
     - "Ambient noise at 82 dB..."
     - "1 hour ago"
   - **Battery Low** (yellow icon, unread dot)
     - "Wristband battery at 15%..."
     - "2 hours ago"

3. **Earlier Section**
   - "Earlier" header
   - **Stress Normalized** (green icon)
     - "Yesterday, 4:30 PM"
   - **Peak Stress Event** (red icon)
     - "Yesterday, 11:15 AM"
   - **Connection Restored** (green icon)
     - "2 days ago"
   - **Extended High Noise** (yellow icon)
     - "2 days ago"
   - **Daily Summary** (blue icon)
     - "3 days ago"

**Bottom Nav**: Dashboard, History, Alerts (active), Settings

---

### 7. Settings Screen
**File**: `lib/features/settings/screens/settings_screen.dart`

**App Bar**: Same as Dashboard

**Content**:
1. **Monitored Individual**
   - Profile card:
     - Avatar with "A" initial
     - "Alex Johnson"
     - "Age 14"
   - "Edit Profile" menu item (chevron)

2. **Wristband Controls**
   - **Haptic Feedback**: Toggle switch (ON)
   - Divider
   - **Device Status**: "Connected" badge (green)

3. **Alert Thresholds**
   - **Push Notifications**: Toggle switch (ON)
   - Divider
   - **Stress Level Threshold**: Slider (5.0-9.0, default 7.0)
     - Current value display
     - Min/max labels
   - **Noise Level Threshold**: Slider (60-90 dB, default 75 dB)

4. **Data & Privacy**
   - **Export Health Data**
     - Download icon
     - "Download your monitoring data" subtitle
     - Chevron
   - **Privacy Settings**
     - Privacy icon
     - "Manage data sharing preferences" subtitle
     - Chevron
   - **About This App**
     - Info icon
     - "Version 1.0.0" subtitle
     - Opens dialog with app info

5. **Sign Out Button** (bottom)
   - Red outlined button
   - Shows confirmation dialog

**Bottom Nav**: Dashboard, History, Alerts, Settings (active)

---

## 🎨 Design Patterns Used

### Cards
- White background (#FFFFFF)
- 12px border radius
- Subtle shadow (0.05 opacity)
- 16px padding

### Icons
- 24px size (medium)
- Light blue background (#E8F4F8)
- 8px padding
- 8px border radius

### Buttons
- Primary: Blue background, white text
- Secondary: Blue outline, blue text
- Text: Blue text only
- Height: 48px
- Full width on forms

### Color Coding
- **Green**: Success, low stress (0-4), connected
- **Yellow**: Warning, moderate stress (4-7)
- **Red**: Danger, high stress (7-10), critical
- **Blue**: Info, primary actions

### Typography
- Headings: Bold, 20-28px
- Body: Regular, 14-16px
- Captions: Regular, 12px, gray
- Values: Bold, 24-48px

### Spacing
- Small: 8px
- Medium: 16px
- Large: 24px
- XLarge: 32px

---

## 📱 Navigation Flow

```
Login Screen
    ├─→ Sign Up Screen
    ├─→ Forgot Password Screen
    └─→ Dashboard Screen ┐
                         │
        ┌────────────────┴────────────────┐
        │    Bottom Navigation             │
        ├─→ Dashboard Screen (Tab 0)       │
        ├─→ History Screen (Tab 1)         │
        ├─→ Alerts Screen (Tab 2)          │
        └─→ Settings Screen (Tab 3)        │
                └─→ Sign Out → Login Screen
```

---

## 🔧 Interactive Elements

### Toggles/Switches
- Haptic Feedback (Dashboard & Settings)
- Push Notifications (Settings)
- Device connection status (visual only)

### Sliders
- Stress Level Threshold (5.0 - 9.0)
- Noise Level Threshold (60 - 90 dB)
- Real-time value updates
- Visual feedback with labels

### Forms
- Email validation (@ symbol required)
- Password validation (6+ characters)
- Password confirmation match check
- Terms acceptance checkbox
- Show/hide password toggle

### Dialogs
- Date picker (History screen)
- About app info (Settings)
- Sign out confirmation (Settings)

### Snackbars
- Success messages (password reset sent, signed out)
- Error messages (validation failures)
- Info messages (coming soon features)

---

## 📊 Sample Data

### Metrics
- Stress Level: 6.2 (Moderate)
- Heart Rate: 78 BPM
- Motion: Moderate
- Noise Level: 65 dB
- Battery: 68%

### History
- Average Stress: 5.3
- Peak Stress: 7.2 at 11:15 AM
- Weekly values: Mon 5.2, Tue 6.1, Wed 4.8, Thu 7.2, Fri 5.5, Sat 3.9, Sun 4.5

### Alerts
- 3 new alerts (unread)
- 5 earlier alerts (read)
- Various types: stress, noise, battery, connection, daily summary

### User Profile
- Name: Alex Johnson
- Age: 14
- Device: Connected

---

## 🚀 Next Steps (Backend Integration)

When adding backend functionality, replace:

1. **Authentication**
   - Mock validation → Real API calls
   - Local navigation → Token management
   - Static user → Dynamic user data

2. **Real-time Data**
   - Mock metrics → Bluetooth/API streaming
   - Static charts → Live data updates
   - Hardcoded values → Database queries

3. **Notifications**
   - Static alerts → Push notification service
   - Mock timestamps → Real-time events
   - Sample data → Historical records

4. **Settings**
   - UI state only → Persistent storage
   - Mock thresholds → Backend configuration
   - Sample profile → Editable user data

---

**Total Screens**: 7  
**Total Widgets**: 24 custom widgets  
**Navigation Types**: Stack (auth) + Bottom tabs (main app)  
**Interactive Elements**: 15+ (switches, sliders, forms, pickers)
