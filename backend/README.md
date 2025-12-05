# CareLink Wristband Backend API

This is the Flask backend for the CareLink Wristband mobile application. It provides a REST API for user authentication, profile management, sensor data storage, and alerts.

## Tech Stack

- **Flask 3.0.0** - Web framework
- **SQLite** - Database
- **Flask-JWT-Extended** - JWT authentication
- **Flask-CORS** - Cross-origin request handling
- **bcrypt** - Password hashing

## Setup Instructions

### Prerequisites

- Python 3.8 or higher
- pip (Python package installer)

### Installation

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Create a virtual environment (recommended):**
   ```bash
   # On macOS/Linux:
   python3 -m venv venv
   source venv/bin/activate

   # On Windows:
   python -m venv venv
   venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

### Running the Server

1. **Start the Flask development server:**
   ```bash
   python app.py
   ```

2. The server will start on `http://127.0.0.1:5000`

3. You should see output like:
   ```
   * Running on http://127.0.0.1:5000
   * Debug mode: on
   ```

### Database

The SQLite database (`carelink.db`) will be automatically created when you first run the application. It includes the following tables:

- **users** - User accounts (email, password hash, name)
- **profiles** - Monitored person details (name, age, relationship, etc.)
- **wristband_readings** - Sensor data (heart rate, motion, stress, etc.)
- **alerts** - User notifications

## API Endpoints

### Authentication (`/api/auth`)

#### Sign Up
- **POST** `/api/auth/signup`
- Body: `{ "email": "user@example.com", "password": "password123", "full_name": "John Doe" }`
- Returns: JWT token and user info

#### Log In
- **POST** `/api/auth/login`
- Body: `{ "email": "user@example.com", "password": "password123" }`
- Returns: JWT token and user info

#### Get Current User
- **GET** `/api/auth/me`
- Headers: `Authorization: Bearer <token>`
- Returns: Current user info

#### Log Out
- **POST** `/api/auth/logout`
- Headers: `Authorization: Bearer <token>`
- Returns: Success message

### Dashboard (`/api/dashboard`)

#### Get Metrics
- **GET** `/api/dashboard/metrics`
- Headers: `Authorization: Bearer <token>`
- Returns: Latest sensor readings or mock data

#### Save Reading
- **POST** `/api/dashboard/readings`
- Headers: `Authorization: Bearer <token>`
- Body: `{ "heart_rate": 78, "motion": "Moderate", "noise_level": 65, "stress_level": 6.2, "battery": 68 }`
- Returns: Saved reading ID

### Profile (`/api/profile`)

#### Get Profile
- **GET** `/api/profile`
- Headers: `Authorization: Bearer <token>`
- Returns: Profile information

#### Update Profile
- **PUT** `/api/profile`
- Headers: `Authorization: Bearer <token>`
- Body: `{ "name": "Alex Johnson", "age": 14, "relationship": "Parent" }`
- Returns: Updated profile

### Alerts (`/api/alerts`)

#### Get All Alerts
- **GET** `/api/alerts`
- Headers: `Authorization: Bearer <token>`
- Returns: List of alerts

#### Create Alert
- **POST** `/api/alerts`
- Headers: `Authorization: Bearer <token>`
- Body: `{ "type": "stress", "title": "High Stress Detected", "message": "Stress level exceeded threshold" }`
- Returns: Created alert

#### Mark Alert as Read
- **PUT** `/api/alerts/<id>/read`
- Headers: `Authorization: Bearer <token>`
- Returns: Success message

## Testing with cURL

### Sign Up
```bash
curl -X POST http://127.0.0.1:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","full_name":"Test User"}'
```

### Log In
```bash
curl -X POST http://127.0.0.1:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Get Metrics (replace YOUR_TOKEN with the token from login)
```bash
curl -X GET http://127.0.0.1:5000/api/dashboard/metrics \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Connecting from Flutter App

When running the Flutter app:

- **Android Emulator**: Use `http://10.0.2.2:5000/api` (maps to host's localhost)
- **iOS Simulator**: Use `http://127.0.0.1:5000/api`
- **Physical Device**: Use your computer's IP address, e.g., `http://192.168.1.100:5000/api`

To find your computer's IP:
- **macOS/Linux**: `ifconfig | grep "inet "`
- **Windows**: `ipconfig`

## Development Notes

- The database file (`carelink.db`) is created in the backend directory
- JWT tokens are valid for 7 days (configurable in `config.py`)
- Debug mode is enabled by default (disable for production)
- CORS is enabled for all origins (restrict in production)

## Security Considerations

For production deployment:

1. **Change secret keys** in `config.py` or use environment variables
2. **Disable debug mode** in `app.py`
3. **Restrict CORS origins** to only allow your app
4. **Use HTTPS** instead of HTTP
5. **Use a production database** (PostgreSQL, MySQL) instead of SQLite
6. **Add rate limiting** to prevent abuse
7. **Implement proper logging** and monitoring

## Troubleshooting

### Port Already in Use
If port 5000 is already in use, change it in `app.py`:
```python
app.run(host='127.0.0.1', port=5001, debug=True)
```

### Database Locked Error
If you get a "database is locked" error, ensure only one instance of the server is running.

### Import Errors
Make sure you're in the virtual environment and all dependencies are installed:
```bash
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
```

## Project Structure

```
backend/
├── app.py              # Main Flask application
├── config.py           # Configuration settings
├── requirements.txt    # Python dependencies
├── routes/             # API route handlers
│   ├── __init__.py
│   ├── auth.py        # Authentication endpoints
│   ├── dashboard.py   # Dashboard endpoints
│   ├── profile.py     # Profile endpoints
│   └── alerts.py      # Alerts endpoints
└── carelink.db        # SQLite database (created on first run)
```

## Next Steps

- Add data validation and sanitization
- Implement refresh tokens for better security
- Add unit tests
- Set up proper logging
- Deploy to a production server (e.g., Heroku, AWS, DigitalOcean)
- Add API documentation (Swagger/OpenAPI)
