# Backend Setup Complete! 🎉

A complete Node.js/Express backend for your Flutter Campus Management mobile app has been created.

## What Was Created

### Backend Structure (`/backend/`)

```
backend/
├── src/
│   ├── config/              # Configuration files
│   │   ├── env.js           # Environment variables
│   │   └── database.js      # MongoDB connection
│   ├── controllers/         # Business logic (6 files)
│   │   ├── authController.js
│   │   ├── userController.js
│   │   ├── announcementController.js
│   │   ├── eventController.js
│   │   ├── attendanceController.js
│   │   └── jobController.js
│   ├── models/              # Database schemas (4 files)
│   │   ├── User.js
│   │   ├── Announcement.js
│   │   ├── Event.js
│   │   ├── Attendance.js
│   │   └── JobPosting.js
│   ├── routes/              # API endpoints (6 files)
│   │   ├── authRoutes.js
│   │   ├── userRoutes.js
│   │   ├── announcementRoutes.js
│   │   ├── eventRoutes.js
│   │   ├── attendanceRoutes.js
│   │   └── jobRoutes.js
│   ├── middleware/          # Express middleware (4 files)
│   │   ├── auth.js          # JWT authentication
│   │   ├── validation.js    # Request validation
│   │   ├── error.js         # Error handling
│   │   └── rateLimiter.js   # Rate limiting
│   ├── utils/               # Helper functions
│   │   ├── jwt.js           # JWT utilities
│   │   └── helpers.js       # Common helpers
│   └── server.js            # Main server file
├── package.json             # Dependencies and scripts
├── .env.example             # Environment variables template
├── .gitignore               # Git ignore rules
├── .eslintrc.json           # Code style configuration
├── Dockerfile               # Docker image configuration
├── docker-compose.yml       # Docker Compose setup
├── README.md                # Backend documentation
└── QUICK_START.md           # Quick start guide
```

### Root Level Files

- **BACKEND_INTEGRATION.md** - Integration guide for mobile app
- **START.bat** - Windows startup script
- **START.sh** - Mac/Linux startup script
- **lib/services/api_service.dart** - Updated with correct API URL

## Quick Start

### Option 1: Docker Compose (Recommended ✅)

```bash
# 1. Navigate to backend directory
cd backend

# 2. Start all services
docker-compose up -d

# Services will be running:
# - API: http://localhost:5000/api/v1
# - MongoDB: localhost:27017
# - Mongo Express: http://localhost:8081
```

### Option 2: Local Development

```bash
# 1. Install dependencies
cd backend
npm install

# 2. Create .env file
cp .env.example .env

# 3. Start MongoDB (if not already running)
# Install MongoDB or use a local MongoDB service

# 4. Start the server
npm run dev

# Server runs on: http://localhost:5000/api/v1
```

### Option 3: Using Startup Scripts

**Windows:**
```bash
START.bat
# Then select option 1 or 2
```

**Mac/Linux:**
```bash
chmod +x START.sh
./START.sh
```

## Next Steps

### 1. Start the Backend
```bash
cd backend
docker-compose up -d
```

### 2. Run the Mobile App
```bash
flutter run
```

The app will connect to the backend at `http://localhost:5000/api/v1`

### 3. Test the Integration
- Open the app
- Create an account (Register)
- Login with your credentials
- Browse announcements, events, etc.

## Key Features Implemented

### Authentication
- ✅ User registration with email
- ✅ Login with JWT tokens
- ✅ Token refresh mechanism
- ✅ Secure password hashing (bcryptjs)
- ✅ Token storage in MongoDB

### User Management
- ✅ User profiles with roles (Student, Faculty, Admin)
- ✅ Profile updates
- ✅ User listing (Admin only)

### Announcements
- ✅ Create, read, update, delete
- ✅ Categories: General, Department, Event, Emergency
- ✅ Priority levels
- ✅ Filtering and pagination

### Events
- ✅ Create and manage events
- ✅ Register/unregister for events
- ✅ Event categories
- ✅ Capacity management

### Attendance
- ✅ Mark attendance (Faculty/Admin)
- ✅ Track attendance records
- ✅ Calculate attendance percentage
- ✅ Course-wise tracking

### Job Postings
- ✅ Create job postings
- ✅ Apply for jobs
- ✅ Track applications
- ✅ Filter by job type

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register user
- `POST /api/v1/auth/login` - Login user
- `POST /api/v1/auth/logout` - Logout user
- `POST /api/v1/auth/refresh` - Refresh token

### Users
- `GET /api/v1/users/profile` - Get profile
- `PUT /api/v1/users/profile` - Update profile
- `GET /api/v1/users` - List users (Admin)

### Announcements
- `GET /api/v1/announcements` - List announcements
- `POST /api/v1/announcements` - Create announcement
- `PUT /api/v1/announcements/:id` - Update
- `DELETE /api/v1/announcements/:id` - Delete

### Events
- `GET /api/v1/events` - List events
- `POST /api/v1/events` - Create event
- `POST /api/v1/events/:id/register` - Register
- `POST /api/v1/events/:id/unregister` - Unregister
- `DELETE /api/v1/events/:id` - Delete

### Attendance
- `GET /api/v1/attendance` - List attendance
- `GET /api/v1/attendance/user/:userId` - User attendance
- `POST /api/v1/attendance` - Mark attendance
- `PUT /api/v1/attendance/:id` - Update
- `DELETE /api/v1/attendance/:id` - Delete

### Jobs
- `GET /api/v1/jobs` - List jobs
- `POST /api/v1/jobs` - Create job
- `POST /api/v1/jobs/:id/apply` - Apply for job
- `GET /api/v1/jobs/:id/applications` - View applications
- `DELETE /api/v1/jobs/:id` - Delete

## Environment Variables

Edit `backend/.env` to configure:

```env
PORT=5000                                           # Server port
NODE_ENV=development                               # Environment
MONGODB_URI=mongodb://localhost:27017/campus_mgmt # Database URL
JWT_SECRET=your_secret_key                        # JWT secret key
CORS_ORIGIN=localhost:3000                        # CORS allowed origins
```

## Important Notes

### For Physical Device Testing
If testing on a physical device, update the API URL:

```dart
// lib/services/api_service.dart
static const String _baseUrl = 'http://YOUR_IP:5000/api/v1';
// Example: static const String _baseUrl = 'http://192.168.1.100:5000/api/v1';
```

### Database Location
- **Development**: MongoDB runs in docker container
- **Connection**: `mongodb://admin:password@mongodb:27017/campus_management`
- **View data**: http://localhost:8081 (Mongo Express)

### Production Deployment
Before deploying:
1. Change JWT_SECRET to a secure random string
2. Update MONGODB_URI to production database
3. Set NODE_ENV=production
4. Disable MongoDB auth or use strong passwords
5. Enable HTTPS (SSL certificates)
6. Set proper CORS_ORIGIN
7. Configure backups and monitoring

## Troubleshooting

### Port 5000 Already in Use
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Mac/Linux
lsof -i :5000
kill -9 <PID>
```

### MongoDB Connection Failed
```bash
# Check if MongoDB is running
docker-compose ps

# Restart services
docker-compose down
docker-compose up -d
```

### CORS or Connection Errors
- Ensure backend is running
- Check API URL in `api_service.dart`
- Verify no firewall blocking port 5000
- Check app logs in Flutter console

## Testing the API

### Using cURL
```bash
# Register user
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "pass123",
    "name": "Test User",
    "role": "Student"
  }'

# Login
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "pass123"
  }'
```

### Using Postman
1. Create new collection
2. Import API endpoints
3. Set up environment variables
4. Execute requests

## File Structure Overview

```
mobileapp/
├── backend/              # NEW - All backend code here
├── lib/                  # Flutter app code
│   ├── services/
│   │   └── api_service.dart (UPDATED)
│   ├── models/
│   ├── providers/
│   ├── screens/
│   └── utils/
├── BACKEND_INTEGRATION.md (NEW)
├── START.bat (NEW)
├── START.sh (NEW)
└── ... other files
```

## Code Quality

### Linting
```bash
cd backend
npm run lint
npm run lint:fix
```

### Testing
```bash
npm test
```

## Support & Documentation

- **Backend README**: `backend/README.md`
- **Quick Start**: `backend/QUICK_START.md`
- **Integration Guide**: `BACKEND_INTEGRATION.md`
- **API Documentation**: See endpoint descriptions above

## Technologies Used

- **Runtime**: Node.js 18+
- **Framework**: Express.js 4.18
- **Database**: MongoDB 7.0
- **Authentication**: JWT (JSON Web Tokens)
- **Validation**: Joi
- **Security**: Helmet, bcryptjs, CORS
- **Rate Limiting**: express-rate-limit
- **Containerization**: Docker & Docker Compose

## Security Features

- ✅ Password hashing with bcryptjs
- ✅ JWT-based authentication
- ✅ Token refresh mechanism
- ✅ Rate limiting on login attempts
- ✅ CORS protection
- ✅ Helmet security headers
- ✅ Request validation with Joi
- ✅ Role-based access control

## What's Next?

1. **Test Everything**: Run both app and backend, test all features
2. **Customize**: Modify as needed for your specific requirements
3. **Deploy**: Use Docker or deploy to cloud services (AWS, GCP, Heroku, etc.)
4. **Monitor**: Set up logging, error tracking, and monitoring
5. **Scale**: Add caching, optimize database queries as usage grows

## Questions?

Refer to the documentation files:
- `backend/README.md` - Complete backend documentation
- `backend/QUICK_START.md` - Quick start guide
- `BACKEND_INTEGRATION.md` - Mobile app integration guide

---

**Happy coding!** 🚀

*Backend setup completed: March 2026*
