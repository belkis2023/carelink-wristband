# Changelog

## [Unreleased] - 2024-12-05

### Added - Flask Backend

#### Backend Infrastructure
- **Flask REST API** (`backend/app.py`)
  - RESTful API server on `http://127.0.0.1:5000`
  - CORS enabled for Flutter connectivity
  - JWT authentication with 7-day token expiration
  - Auto-initializes SQLite database on startup

- **SQLite Database** (`backend/database.py`)
  - 4 tables: users, profiles, wristband_readings, alerts
  - Row-factory for dictionary-style access
  - Automatic connection management

- **Configuration** (`backend/config.py`)
  - JWT secret key configuration
  - Database path configuration
  - Environment variable support

#### API Routes

- **Authentication Routes** (`backend/routes/auth.py`)
  - `POST /api/auth/signup` - Create new user account
  - `POST /api/auth/login` - Authenticate user
  - `POST /api/auth/logout` - Sign out user
  - `GET /api/auth/me` - Get current user info
  - Email validation and password hashing with bcrypt

- **Dashboard Routes** (`backend/routes/dashboard.py`)
  - `GET /api/dashboard/metrics` - Get latest sensor readings
  - `POST /api/dashboard/readings` - Save new sensor data
  - Returns mock data when no readings exist

- **Profile Routes** (`backend/routes/profile.py`)
  - `GET /api/profile` - Get user profile
  - `PUT /api/profile` - Update profile information
  - Default profile created on signup

- **Alert Routes** (`backend/routes/alerts.py`)
  - `GET /api/alerts` - List all user alerts
  - `POST /api/alerts` - Create new alert
  - `PUT /api/alerts/<id>/read` - Mark alert as read

#### Documentation
- **Backend README** (`backend/README.md`)
  - Installation instructions
  - API endpoint documentation
  - cURL examples for testing
  - Troubleshooting guide

### Added - Flutter API Integration

#### Core Services
- **ApiService** (`lib/core/services/api_service.dart`)
  - Complete API client for Flask backend
  - JWT token management with SharedPreferences
  - Auto-retry logic and error handling
  - Methods for all backend endpoints
  - Configurable base URL for different environments

#### New Features
- **Connection Test Screen** (`lib/features/connection/screens/connection_test_screen.dart`)
  - Appears after successful login/signup
  - Simulates wristband connection search
  - Three states: searching, connected, not found
  - "Skip for Now" option to proceed to dashboard
  - "Try Again" button for retry
  - Ready for future BLE integration

#### Updated Screens
- **Login Screen** (`lib/features/auth/screens/login_screen.dart`)
  - Integrated with ApiService
  - Shows loading state during login
  - Displays error messages from API
  - Navigates to Connection Test on success

- **Signup Screen** (`lib/features/auth/screens/signup_screen.dart`)
  - Integrated with ApiService
  - Shows loading state during signup
  - Displays error messages from API
  - Navigates to Connection Test on success

- **Settings Screen** (`lib/features/settings/screens/settings_screen.dart`)
  - Added logout functionality
  - Clears JWT token on logout
  - Navigates to login screen
  - Shows success message

- **Main App** (`lib/main.dart`)
  - Checks authentication status on startup
  - Auto-navigates to Dashboard if logged in
  - Shows login screen if not authenticated
  - Loading indicator during auth check

- **App Router** (`lib/navigation/app_router.dart`)
  - Added `/connection-test` route
  - Imports ConnectionTestScreen

#### Dependencies
- **pubspec.yaml**
  - Added `http: ^1.1.0` - HTTP requests
  - Added `shared_preferences: ^2.2.2` - Local storage

### Changed

#### Configuration
- **Removed** Supabase dependency (was not in use)
- **Added** Python backend as alternative
- **Updated** .gitignore to exclude:
  - `backend/__pycache__/`
  - `backend/*.db`
  - `backend/venv/`
  - `backend/.env`

#### Architecture
- Shifted from cloud-based (Supabase) to local backend
- JWT token-based authentication
- RESTful API communication
- Local SQLite database storage

### Documentation

- **Flask Integration Guide** (`FLASK_INTEGRATION_GUIDE.md`)
  - Comprehensive setup instructions
  - Architecture explanation
  - API configuration guide
  - Testing procedures
  - Troubleshooting tips
  - Development best practices

- **Changelog** (`CHANGELOG.md`)
  - Detailed list of all changes
  - Organized by category

## Technical Details

### Backend Stack
- Flask 3.0.0
- Flask-CORS 4.0.0
- Flask-JWT-Extended 4.6.0
- bcrypt 4.1.2
- python-dotenv 1.0.0
- SQLite (built-in)

### Flutter Stack
- Flutter SDK ^3.10.1
- http ^1.1.0 (NEW)
- shared_preferences ^2.2.2 (NEW)
- fl_chart ^0.68.0
- cupertino_icons ^1.0.8

### Database Schema

#### users table
```sql
- id: INTEGER PRIMARY KEY
- email: TEXT UNIQUE NOT NULL
- password_hash: TEXT NOT NULL
- full_name: TEXT
- created_at: TIMESTAMP
```

#### profiles table
```sql
- id: INTEGER PRIMARY KEY
- user_id: INTEGER FOREIGN KEY
- name: TEXT (default: 'Alex Johnson')
- age: INTEGER (default: 14)
- date_of_birth: TEXT
- relationship: TEXT (default: 'Parent')
- emergency_contact_name: TEXT
- emergency_contact_phone: TEXT
```

#### wristband_readings table
```sql
- id: INTEGER PRIMARY KEY
- user_id: INTEGER FOREIGN KEY
- heart_rate: INTEGER
- motion: TEXT
- noise_level: INTEGER
- stress_level: REAL
- battery: INTEGER
- timestamp: TIMESTAMP
```

#### alerts table
```sql
- id: INTEGER PRIMARY KEY
- user_id: INTEGER FOREIGN KEY
- type: TEXT NOT NULL
- title: TEXT NOT NULL
- message: TEXT
- is_read: INTEGER (0 or 1)
- created_at: TIMESTAMP
```

### API Authentication

All protected endpoints require:
```
Authorization: Bearer <jwt_token>
```

Token is obtained from login/signup and stored in SharedPreferences.

### Base URL Configuration

| Environment | Base URL |
|------------|----------|
| Android Emulator | `http://10.0.2.2:5000/api` |
| iOS Simulator | `http://127.0.0.1:5000/api` |
| Physical Device | `http://YOUR_IP:5000/api` |

## Migration Notes

### For Developers

1. **Install Python dependencies**:
   ```bash
   cd backend && pip3 install -r requirements.txt
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Start backend server**:
   ```bash
   cd backend && python3 app.py
   ```

4. **Configure API URL** in `lib/core/services/api_service.dart` based on your environment

5. **Run Flutter app**:
   ```bash
   flutter run
   ```

### Breaking Changes

- **Removed** Supabase integration (was not implemented)
- **Changed** authentication flow to use Flask API
- **Added** new Connection Test Screen in user flow
- **Changed** initial route logic in main.dart

## Future Enhancements

Ready for implementation:

- [ ] **BLE Integration**
  - Scan for wristband devices
  - Connect and pair with wristband
  - Receive real-time sensor data
  - Update Connection Test Screen with actual connection

- [ ] **Real-time Updates**
  - WebSocket support for live data
  - Push sensor readings to dashboard
  - Alert notifications

- [ ] **Data Visualization**
  - Historical data charts
  - Trends and analytics
  - Export functionality

- [ ] **Production Deployment**
  - Environment-based configuration
  - HTTPS support
  - Token refresh mechanism
  - Rate limiting
  - Proper logging

- [ ] **Testing**
  - Backend unit tests
  - Integration tests
  - Flutter widget tests
  - End-to-end tests

## Known Issues

None at this time. This is a fresh implementation.

## Notes

- Backend runs on `http://127.0.0.1:5000` by default
- JWT tokens expire after 7 days
- SQLite database is created automatically on first run
- Connection Test Screen currently simulates connection (BLE not yet implemented)
- All data is stored locally in SQLite

---

For more information, see:
- `backend/README.md` - Backend setup and API documentation
- `FLASK_INTEGRATION_GUIDE.md` - Integration guide and troubleshooting
- `QUICK_START.md` - Flutter app setup guide
