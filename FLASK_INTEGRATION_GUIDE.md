# Flask Backend Integration Guide

This guide explains how to run the CareLink Wristband app with the new Flask backend.

## Overview

The app now uses a **Flask REST API backend** with **SQLite database** instead of Supabase. This provides:

- Full control over the backend
- No external dependencies
- Easy local development
- JWT-based authentication
- Ready for BLE integration

## Quick Start

### Step 1: Start the Backend

```bash
# Navigate to backend directory
cd backend

# Install dependencies (first time only)
pip3 install -r requirements.txt

# Start the Flask server
python3 app.py
```

The backend will start on `http://127.0.0.1:5000`

### Step 2: Run the Flutter App

```bash
# From the project root
flutter pub get

# Run on Android emulator
flutter run
```

## Architecture Changes

### Before (Supabase)
```
Flutter App → Supabase Cloud → Database
```

### After (Flask)
```
Flutter App → Flask API → SQLite Database
```

## What Changed

### Backend (NEW)
- ✅ **Flask REST API** at `backend/app.py`
- ✅ **SQLite Database** (`backend/carelink.db` - auto-created)
- ✅ **JWT Authentication** for secure API access
- ✅ **CORS Enabled** to allow Flutter to connect
- ✅ **4 Route Modules**:
  - `auth.py` - Signup, login, logout, user info
  - `dashboard.py` - Metrics and sensor readings
  - `profile.py` - User profile management
  - `alerts.py` - Alert management

### Flutter Changes
- ✅ **ApiService** (`lib/core/services/api_service.dart`) - Handles all API calls
- ✅ **Connection Test Screen** - New screen after login/signup
- ✅ **Token Storage** - Uses SharedPreferences to save JWT token
- ✅ **Auto Login** - Checks for saved token on app startup
- ✅ **Logout** - Clears token and returns to login

### New User Flow
```
1. Login/Signup → ApiService calls Flask API
2. Success → Navigate to Connection Test Screen
3. Connection Test → Simulates searching for wristband
4. Skip for Now → Navigate to Dashboard
5. Dashboard → Loads data from Flask API
```

## API Base URL Configuration

The Flutter app needs to use different URLs depending on where it's running:

### Android Emulator (Default)
```dart
// In lib/core/services/api_service.dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```
`10.0.2.2` is a special IP that maps to the host machine's `localhost`.

### iOS Simulator
```dart
static const String baseUrl = 'http://127.0.0.1:5000/api';
```

### Physical Device
```dart
static const String baseUrl = 'http://192.168.1.100:5000/api';
```
Replace `192.168.1.100` with your computer's actual IP address.

**To find your IP:**
- **macOS/Linux**: `ifconfig | grep "inet "`
- **Windows**: `ipconfig`

## Testing the Backend

### Test API Root
```bash
curl http://127.0.0.1:5000/
```

Expected response:
```json
{
  "message": "CareLink Wristband API",
  "status": "running",
  "version": "1.0.0"
}
```

### Test Signup
```bash
curl -X POST http://127.0.0.1:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","full_name":"Test User"}'
```

### Test Login
```bash
curl -X POST http://127.0.0.1:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

Save the `access_token` from the response.

### Test Dashboard Metrics
```bash
curl http://127.0.0.1:5000/api/dashboard/metrics \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Database

The SQLite database (`backend/carelink.db`) contains 4 tables:

### users
- Stores user accounts (email, password hash, name)

### profiles
- Stores monitored person details (name, age, relationship)
- Each user has one profile created on signup

### wristband_readings
- Stores sensor data (heart rate, motion, noise, stress, battery)
- Will be populated when BLE is integrated

### alerts
- Stores user notifications

## Connection Test Screen

The new **Connection Test Screen** appears after login/signup.

### Current Behavior (No BLE Yet)
1. Shows "Searching for Wristband..." with loading indicator
2. After 2 seconds, shows "Wristband Not Found"
3. User can:
   - Click "Try Again" to retry
   - Click "Skip for Now" to go to dashboard

### Future Behavior (With BLE)
1. Actually scans for Bluetooth devices
2. Connects to CareLink wristband
3. Shows connection status with device info

## Authentication Flow

### Signup
```
1. User enters email, password, name
2. Flutter calls ApiService.signup()
3. ApiService sends POST /api/auth/signup
4. Backend validates and creates user
5. Backend creates default profile
6. Backend returns JWT token
7. Flutter saves token to SharedPreferences
8. Flutter navigates to Connection Test Screen
```

### Login
```
1. User enters email, password
2. Flutter calls ApiService.login()
3. ApiService sends POST /api/auth/login
4. Backend validates credentials
5. Backend returns JWT token
6. Flutter saves token to SharedPreferences
7. Flutter navigates to Connection Test Screen
```

### Logout
```
1. User clicks Sign Out in Settings
2. Flutter calls ApiService.logout()
3. ApiService sends POST /api/auth/logout (optional)
4. ApiService clears token from SharedPreferences
5. Flutter navigates to Login Screen
```

### Auto-Login on Startup
```
1. App starts
2. main.dart checks ApiService.isLoggedIn()
3. If token exists → Go to Dashboard
4. If no token → Go to Login Screen
```

## Token Management

JWT tokens are stored in two places:

1. **Memory** - In `ApiService._token` for quick access
2. **SharedPreferences** - For persistence across app restarts

Token lifetime: **7 days** (configured in `backend/config.py`)

## Troubleshooting

### "Failed to connect to server"

**Problem**: Flutter can't reach Flask backend

**Solutions**:
1. Make sure Flask is running (`python3 app.py`)
2. Check the API base URL in `api_service.dart`
3. For physical devices, use your computer's IP
4. For Android emulator, use `10.0.2.2`
5. Make sure firewall allows connections

### "Invalid email or password"

**Problem**: Credentials don't match

**Solutions**:
1. Create a new account with signup
2. Check if email/password are correct
3. Email is case-insensitive (automatically lowercased)

### Port 5000 Already in Use

**Problem**: Another app is using port 5000

**Solution**: Change port in `backend/app.py`:
```python
app.run(host='127.0.0.1', port=5001, debug=True)
```

Then update Flutter's `api_service.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:5001/api';
```

## Development Tips

### See Backend Logs
The Flask server shows all API requests in the terminal:
```
127.0.0.1 - - [05/Dec/2024 20:00:00] "POST /api/auth/login HTTP/1.1" 200 -
```

### Inspect Database
```bash
cd backend
sqlite3 carelink.db

# Show all tables
.tables

# View users
SELECT * FROM users;

# View profiles
SELECT * FROM profiles;

# Exit
.quit
```

### Reset Database
```bash
cd backend
rm carelink.db
python3 app.py  # Will recreate fresh database
```

### Test Different Scenarios

**Create multiple users:**
```bash
curl -X POST http://127.0.0.1:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"user1@example.com","password":"pass123"}'

curl -X POST http://127.0.0.1:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"user2@example.com","password":"pass123"}'
```

**Save mock sensor readings:**
```bash
# Login first to get token
TOKEN="your_token_here"

curl -X POST http://127.0.0.1:5000/api/dashboard/readings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"heart_rate":75,"motion":"Low","noise_level":60,"stress_level":5.5,"battery":85}'
```

## Next Steps

### Ready for BLE Integration

The backend is ready to receive sensor data from the wristband:

```dart
// In your BLE service (future implementation)
Future<void> sendSensorData(Map<String, dynamic> data) async {
  final apiService = ApiService();
  await apiService.saveReading(data);
}
```

### Add Features

The backend supports:
- ✅ User authentication
- ✅ Profile management
- ✅ Sensor data storage
- ✅ Alert system

Ready to add:
- [ ] BLE wristband connection
- [ ] Real-time sensor streaming
- [ ] Alert triggers based on thresholds
- [ ] Data export
- [ ] Push notifications

## Security Notes

### For Development
- JWT secret keys are hardcoded (okay for development)
- CORS allows all origins (okay for development)
- HTTP (not HTTPS) is used (okay for development)

### For Production
You should:
1. Use environment variables for secrets
2. Restrict CORS to your app's domain
3. Use HTTPS instead of HTTP
4. Use a production database (PostgreSQL, MySQL)
5. Add rate limiting
6. Implement token refresh
7. Add proper logging and monitoring

## File Structure

```
carelink-wristband/
├── backend/
│   ├── app.py              # Main Flask application
│   ├── config.py           # Configuration
│   ├── database.py         # Database utilities
│   ├── requirements.txt    # Python dependencies
│   ├── carelink.db         # SQLite database (auto-created)
│   └── routes/
│       ├── auth.py         # Authentication routes
│       ├── dashboard.py    # Dashboard routes
│       ├── profile.py      # Profile routes
│       └── alerts.py       # Alerts routes
│
├── lib/
│   ├── main.dart           # Updated with auth check
│   ├── core/
│   │   └── services/
│   │       └── api_service.dart  # NEW: API client
│   ├── features/
│   │   ├── auth/
│   │   │   └── screens/
│   │   │       ├── login_screen.dart   # Updated
│   │   │       └── signup_screen.dart  # Updated
│   │   ├── connection/         # NEW feature
│   │   │   └── screens/
│   │   │       └── connection_test_screen.dart
│   │   └── settings/
│   │       └── screens/
│   │           └── settings_screen.dart  # Updated
│   └── navigation/
│       └── app_router.dart  # Updated with new route
│
└── pubspec.yaml  # Updated with http & shared_preferences
```

## Support

For issues or questions:
- Backend: See `backend/README.md`
- Frontend: See `QUICK_START.md`
- This guide: `FLASK_INTEGRATION_GUIDE.md`

---

**Happy Coding! 🚀**

The app is now ready with a full-stack setup and prepared for BLE wristband integration!
