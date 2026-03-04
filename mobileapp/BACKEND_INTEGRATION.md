# Mobile App - Backend Integration Guide

This guide explains how to connect the Flutter mobile app with the Node.js/Express backend.

## Backend Setup

First, ensure the backend is running. See [QUICK_START.md](backend/QUICK_START.md) for setup instructions.

### Option 1: Docker Compose (Recommended)
```bash
cd backend
docker-compose up -d
```

This starts:
- API Server: `http://localhost:5000/api/v1`
- MongoDB: `mongodb://admin:password@mongodb:27017/campus_management`

### Option 2: Manual Setup
```bash
cd backend
npm install
npm run dev
```

API Server: `http://localhost:5000/api/v1`

## Mobile App Configuration

### 1. Update API Base URL

The API base URL is configured in [lib/services/api_service.dart](lib/services/api_service.dart):

**For Local Development (Android Emulator/iOS Simulator):**
```dart
static const String _baseUrl = 'http://localhost:5000/api/v1';
```

**For Physical Device on Same Network:**
```dart
static const String _baseUrl = 'http://YOUR_MACHINE_IP:5000/api/v1';
// Example: 'http://192.168.1.100:5000/api/v1'
```

**For Production:**
```dart
static const String _baseUrl = 'https://your-production-domain.com/api/v1';
```

### 2. Find Your Machine IP (for Physical Device Testing)

**Windows:**
```bash
ipconfig
# Look for IPv4 Address under your network adapter
```

**Mac/Linux:**
```bash
ifconfig
# Look for inet address
```

### 3. Test the Connection

Run the mobile app and try to login:

```bash
flutter run
```

If using a physical device, update the IP address in `api_service.dart`.

## API Integration Points

The app integrates with the backend through these main services:

### 1. Authentication Service (`lib/services/auth_service.dart`)

Handles:
- `POST /auth/register` - Register users
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `POST /auth/refresh` - Refresh tokens

### 2. Announcements (`/announcements`)
- `GET` - Fetch announcements
- `POST` - Create announcement (AdminFaculty only)
- `PUT` - Update announcement
- `DELETE` - Delete announcement

### 3. Events (`/events`)
- `GET` - List events
- `POST` - Create event
- `POST /:id/register` - Register for event
- `POST /:id/unregister` - Unregister from event
- `DELETE` - Delete event

### 4. Attendance (`/attendance`)
- `GET /user/:userId` - Get user's attendance
- `POST` - Mark attendance (Faculty/Admin only)
- `PUT/:id` - Update attendance record

### 5. Job Postings (`/jobs`)
- `GET` - List jobs
- `POST` - Create job posting
- `POST /:id/apply` - Apply for job
- `GET /:id/applications` - View applications

## Authentication Flow

### 1. Register/Login

The app stores JWT tokens securely:

```dart
// Token is automatically stored after login
// Stored in: FlutterSecureStorage (encrypts on device)
```

### 2. Token Management

Tokens are automatically attached to all API requests:

```dart
// In ApiService interceptor:
options.headers['Authorization'] = 'Bearer $token';
```

### 3. Token Refresh

When a token expires (401 response), it's automatically refreshed:

```dart
// Calls POST /auth/refresh
// Gets new accessToken and refreshToken
```

## Testing the API

### 1. Manual Testing with cURL

**Register:**
```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "password123",
    "name": "John Doe",
    "role": "Student"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "student@example.com",
      "name": "John Doe",
      "role": "Student"
    },
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

**Login:**
```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "password123"
  }'
```

**Get Announcements:**
```bash
curl http://localhost:5000/api/v1/announcements
```

**Create Announcement (requires token):**
```bash
curl -X POST http://localhost:5000/api/v1/announcements \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Important Notification",
    "description": "This is an important announcement",
    "category": "General"
  }'
```

### 2. Using Postman

1. Import the API collection from backend documentation
2. Set environment variables:
   - `baseUrl`: `http://localhost:5000/api/v1`
   - `token`: (will be auto-populated after login)
3. Test each endpoint

### 3. Testing in Flutter App

The app's login screen tests the connection. If it fails:
1. Check that backend is running (`npm run dev`)
2. Verify API URL in `api_service.dart`
3. Check firewall/network restrictions
4. Look at Flutter console output for error messages

## Troubleshooting

### Issue: "Connection refused"

**Solution:**
- Ensure backend is running: `npm run dev`
- Check port 5000 is not blocked
- Verify IP address if using physical device

### Issue: "401 Unauthorized"

**Solution:**
- Token may be expired, app should auto-refresh
- Check token storage in `FlutterSecureStorage`
- Login again to get fresh token

### Issue: "CORS blocked"

**Solution:**
- Backend has CORS enabled for all origins in development
- Check `.env` file `CORS_ORIGIN` setting
- Ensure backend is updated to latest version

### Issue: "Database connection error"

**Solution:**
- Ensure MongoDB is running
- Check connection string in `.env`:
  - Local: `mongodb://localhost:27017/campus_management`
  - Docker: `mongodb://admin:password@mongodb:27017/campus_management`
- Verify credentials match in docker-compose.yml

### Issue: "Physical device can't reach localhost"

**Solution:**
- Don't use `localhost:5000`, use your machine IP
- Find IP: Windows: `ipconfig`, Mac: `ifconfig`
- Update URL: `http://192.168.x.x:5000/api/v1`
- Ensure device is on same network

## Deployment Checklist

Before deploying to production:

### Backend
- [ ] Change JWT secrets in `.env`
- [ ] Update MongoDB URI to production database
- [ ] Set `NODE_ENV=production`
- [ ] Set `CORS_ORIGIN` to your domain
- [ ] Set `API_URL` to production domain
- [ ] Enable HTTPS
- [ ] Set up proper logging
- [ ] Configure backup strategies
- [ ] Test all API endpoints

### Mobile App
- [ ] Update API URL to production domain
- [ ] Ensure HTTPS is enabled
- [ ] Build release APK/IPA
- [ ] Test on multiple devices
- [ ] Check token refresh works
- [ ] Enable debugging disabled
- [ ] Minify code

## API Response Format

All API responses follow this format:

```json
{
  "success": true/false,
  "message": "Response message",
  "data": {
    // Response data here
  }
}
```

## Default User Roles

1. **Student** - Can view announcements, register for events, apply for jobs
2. **Faculty** - Can create announcements/events, mark attendance, post jobs
3. **Admin** - Full access to all features

## Database Indexes

The backend automatically creates indexes on:
- `users.email` (unique)
- `attendance.userId, courseId`
- `announcements.createdAt`
- `events.eventDate`

## Rate Limiting

The backend applies rate limiting:
- **Login:** 5 requests per 15 minutes
- **General:** 100 requests per 15 minutes

## Files Modified for Backend Integration

- `lib/services/api_service.dart` - Updated API base URL
- Other files use the ApiService and don't need modification

## Next Steps

1. Start both backend and frontend
2. Test login/register
3. Test each feature in the app
4. Deploy to production when ready

---

**Version:** 1.0  
**Last Updated:** March 2026
