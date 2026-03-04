# Backend Setup Verification Checklist

Use this checklist to verify that the backend is properly set up and running.

## ✅ Files Created

- [x] `backend/package.json` - Dependencies and scripts
- [x] `backend/.env.example` - Environment configuration template
- [x] `backend/.gitignore` - Git ignore rules
- [x] `backend/.eslintrc.json` - Code linting config
- [x] `backend/Dockerfile` - Docker image configuration
- [x] `backend/docker-compose.yml` - Docker Compose setup
- [x] `backend/README.md` - Full documentation
- [x] `backend/QUICK_START.md` - Quick start guide

### Configuration Files
- [x] `backend/src/config/env.js` - Environment variables
- [x] `backend/src/config/database.js` - MongoDB connection

### Models (Database Schemas)
- [x] `backend/src/models/User.js` - User model
- [x] `backend/src/models/Announcement.js` - Announcement model
- [x] `backend/src/models/Event.js` - Event model
- [x] `backend/src/models/Attendance.js` - Attendance model
- [x] `backend/src/models/JobPosting.js` - Job posting model

### Middleware
- [x] `backend/src/middleware/auth.js` - JWT authentication
- [x] `backend/src/middleware/validation.js` - Request validation
- [x] `backend/src/middleware/error.js` - Error handling
- [x] `backend/src/middleware/rateLimiter.js` - Rate limiting

### Controllers (Business Logic)
- [x] `backend/src/controllers/authController.js` - Auth logic
- [x] `backend/src/controllers/userController.js` - User logic
- [x] `backend/src/controllers/announcementController.js` - Announcement logic
- [x] `backend/src/controllers/eventController.js` - Event logic
- [x] `backend/src/controllers/attendanceController.js` - Attendance logic
- [x] `backend/src/controllers/jobController.js` - Job logic

### Routes (API Endpoints)
- [x] `backend/src/routes/authRoutes.js` - Auth endpoints
- [x] `backend/src/routes/userRoutes.js` - User endpoints
- [x] `backend/src/routes/announcementRoutes.js` - Announcement endpoints
- [x] `backend/src/routes/eventRoutes.js` - Event endpoints
- [x] `backend/src/routes/attendanceRoutes.js` - Attendance endpoints
- [x] `backend/src/routes/jobRoutes.js` - Job endpoints

### Utilities
- [x] `backend/src/utils/jwt.js` - JWT tokens
- [x] `backend/src/utils/helpers.js` - Common helpers
- [x] `backend/src/server.js` - Main server file

### Documentation & Scripts
- [x] `BACKEND_INTEGRATION.md` - Mobile app integration guide
- [x] `BACKEND_SETUP_COMPLETE.md` - This setup summary
- [x] `START.bat` - Windows startup script
- [x] `START.sh` - Mac/Linux startup script
- [x] `lib/services/api_service.dart` - Updated API URL

## 📋 Pre-Startup Checklist

Before running the backend, verify:

### System Requirements
- [ ] Node.js 14+ installed (`node --version`)
- [ ] npm 6+ installed (`npm --version`)
- [ ] Docker & Docker Compose installed (if using Docker)
  - [ ] Docker: `docker --version`
  - [ ] Docker Compose: `docker-compose --version`
- [ ] MongoDB 4+ running (local or via Docker)

### Project Structure
- [ ] Navigate to project root with `backend/` folder
- [ ] All backend files present in `backend/src/`
- [ ] `backend/package.json` exists
- [ ] `backend/.env.example` exists

### Configuration
- [ ] Create `.env` file in `backend/` directory:
  ```bash
  cd backend
  cp .env.example .env
  ```
- [ ] Review and update `.env` settings if needed
- [ ] Default settings are fine for local development

### Port Availability
- [ ] Port 5000 is available (check: `lsof -i :5000` on Mac/Linux)
- [ ] Port 27017 (MongoDB) is available if using local MongoDB

## 🚀 Startup Checklist

### Option 1: Docker Compose

```bash
cd backend
docker-compose up -d
```

Verify with:
- [ ] `docker-compose ps` shows all services running
- [ ] API available at `http://localhost:5000/health`
- [ ] MongoDB accessible at `localhost:27017`
- [ ] Mongo Express WebUI at `http://localhost:8081`

### Option 2: Local Node.js

```bash
cd backend
npm install
npm run dev
```

Verify with:
- [ ] No compilation errors
- [ ] Console shows "Server running on port 5000"
- [ ] MongoDB connection successful message

## ✅ API Health Check

Test the API is running:

```bash
# Test health endpoint
curl http://localhost:5000/health

# Response should be:
# {"status":"OK","timestamp":"2026-03-03T..."}
```

## 🔐 Authentication Test

### Register a test user:
```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "name": "Test User",
    "role": "Student"
  }'
```

Expected response:
- [ ] Status: 201 (Created)
- [ ] Contains: `accessToken` and `refreshToken`
- [ ] User data in response

### Login:
```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!"
  }'
```

Expected response:
- [ ] Status: 200 (OK)
- [ ] Contains: `accessToken` and `refreshToken`
- [ ] User info (id, email, name, role)

## 📊 Database Verification

### Check MongoDB connection:

**Using MongoDB Shell:**
```bash
mongosh mongodb://localhost:27017/campus_management
> db.users.find()
```

**Using Mongo Express (web UI):**
- [ ] Open `http://localhost:8081`
- [ ] Check `databases` -> `campus_management`
- [ ] Verify collections are visible:
  - [ ] `users`
  - [ ] `announcements`
  - [ ] `events`
  - [ ] `attendance`
  - [ ] `job_postings`

## 📱 Mobile App Integration Check

### Update API URL:
- [ ] Open `lib/services/api_service.dart`
- [ ] Verify base URL is set correctly:
  - [ ] Local dev: `http://localhost:5000/api/v1`
  - [ ] Physical device: Use your machine IP (e.g., `http://192.168.1.100:5000/api/v1`)

### Test in Flutter:
```bash
flutter run
```

- [ ] App starts without errors
- [ ] Can navigate to login screen
- [ ] Can enter credentials and attempt login

## 🧪 Feature Testing

After backend and app are running, test each feature:

### Authentication
- [ ] Register new user works
- [ ] Login works
- [ ] Logout works
- [ ] Token refresh works

### Announcements
- [ ] Can view announcements list
- [ ] Can view announcement details
- [ ] User with role "Faculty" can create announcement
- [ ] Admin can delete announcements

### Events
- [ ] Can view events list
- [ ] Can view event details
- [ ] Can register for event
- [ ] Can view registered events
- [ ] Can unregister from event

### User Profiles
- [ ] Can view own profile
- [ ] Can update profile information
- [ ] Profile image displays correctly
- [ ] Admin can view all users

### Attendance (Faculty/Admin only)
- [ ] Faculty can mark attendance
- [ ] Student can view their attendance
- [ ] Attendance stats display correctly

### Job Postings
- [ ] Can view job listings
- [ ] Can view job details
- [ ] Student can apply for job
- [ ] Faculty can view applications

## 🔧 Troubleshooting

If something isn't working:

### Backend won't start
- [ ] Check port 5000 is free
- [ ] MongoDB is running
- [ ] No errors in console
- [ ] See `backend/README.md#Troubleshooting`

### API returns 500 error
- [ ] Check backend console for stack trace
- [ ] Verify MongoDB connection
- [ ] Check all environment variables set correctly

### Mobile app can't connect
- [ ] Verify backend is running
- [ ] Check API URL in `api_service.dart`
- [ ] For physical devices, use machine IP not `localhost`
- [ ] Check firewall isn't blocking port 5000

### Database connection error
- [ ] MongoDB service is running
- [ ] Connection string matches your setup
- [ ] Credentials are correct (if auth is enabled)

## 📚 Documentation References

If you need help:
- [ ] Read `backend/README.md` for detailed backend documentation
- [ ] Read `backend/QUICK_START.md` for quick setup guide
- [ ] Read `BACKEND_INTEGRATION.md` for mobile app integration
- [ ] Read `BACKEND_SETUP_COMPLETE.md` for overview

## ✨ Success Indicators

Everything is working correctly if:

- ✅ Backend server starts without errors
- ✅ `http://localhost:5000/health` returns status OK
- ✅ MongoDB is running and accessible
- ✅ Can register and login from mobile app
- ✅ Can view announcements without authentication
- ✅ Can create announcements with authentication
- ✅ Events list loads and pagination works
- ✅ User profile displays correctly
- ✅ All API endpoints respond appropriately

## 🎉 You're All Set!

Once all checks pass:

1. **Backend is ready** - Stop here if you only need backend
2. **Mobile app can connect** - Test features thoroughly
3. **Deploy when ready** - Use documentation for deployment steps

---

## Next Steps

1. Start the backend (Docker or Node.js)
2. Run Flutter app with `flutter run`
3. Test login/registration
4. Test each feature with different user roles
5. Refer to documentation for any questions

---

**Last Updated:** March 2026
**Backend Version:** 1.0.0
