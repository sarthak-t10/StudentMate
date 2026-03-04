# Campus Management API - Quick Start Guide

## Prerequisites

- Node.js >= 14.0.0 (or Docker)
- MongoDB >= 4.0 (local or via Docker)
- npm or yarn

## Option 1: Local Development

### 1. Setup

```bash
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env
```

### 2. Update Environment Variables

Edit `.env` file with your configuration:
```
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/campus_management
JWT_SECRET=your_super_secret_jwt_key
```

### 3. Start MongoDB (if not running)

**On Windows with MongoDB installed:**
```bash
# Or use MongoDB Compass GUI

# If using Docker instead:
docker run -d -p 27017:27017 --name mongodb mongo:7.0
```

### 4. Start the Server

```bash
# Development mode (with hot reload)
npm run dev

# Or production mode
npm start
```

Server will start on `http://localhost:5000`

## Option 2: Docker Compose (Recommended)

### 1. Setup

```bash
cd backend
cp .env.example .env
```

### 2. Start Services

```bash
docker-compose up -d
```

This starts:
- MongoDB on `localhost:27017`
- API on `localhost:5000`
- Mongo Express (GUI) on `localhost:8081`

### 3. View Logs

```bash
docker-compose logs -f api
```

### 4. Stop Services

```bash
docker-compose down
```

## Testing the API

### 1. Register a New User

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

### 2. Login

```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "password123"
  }'
```

### 3. Get Announcements

```bash
curl http://localhost:5000/api/v1/announcements
```

### 4. Create Announcement (Requires Auth Token)

```bash
curl -X POST http://localhost:5000/api/v1/announcements \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "title": "New Academic Year",
    "description": "Welcome to the new academic year...",
    "category": "General"
  }'
```

## Database

### MongoDB Connection

- **Local:** `mongodb://localhost:27017/campus_management`
- **Docker:** `mongodb://admin:password@mongodb:27017/campus_management`

### Collections

The following collections will be created automatically:
- `users` - User accounts
- `announcements` - Campus announcements
- `events` - Campus events
- `attendance` - Student attendance records
- `job_postings` - Job recruitment postings

### View Database (via Mongo Express)

Open browser: `http://localhost:8081`
- Username: admin
- Password: (see docker-compose.yml)

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user
- `POST /api/v1/auth/logout` - Logout user
- `POST /api/v1/auth/refresh` - Refresh token

### Users
- `GET /api/v1/users/profile` - Get current user profile
- `PUT /api/v1/users/profile` - Update profile
- `GET /api/v1/users` - Get all users (admin)

### Announcements
- `GET /api/v1/announcements` - Get all announcements
- `POST /api/v1/announcements` - Create announcement
- `PUT /api/v1/announcements/:id` - Update announcement
- `DELETE /api/v1/announcements/:id` - Delete announcement

### Events
- `GET /api/v1/events` - Get all events
- `POST /api/v1/events` - Create event
- `POST /api/v1/events/:id/register` - Register for event
- `DELETE /api/v1/events/:id` - Delete event

### Attendance
- `GET /api/v1/attendance` - Get attendance records
- `GET /api/v1/attendance/user/:userId` - Get user attendance
- `POST /api/v1/attendance` - Mark attendance

### Job Postings
- `GET /api/v1/jobs` - Get job postings
- `POST /api/v1/jobs` - Create job posting
- `POST /api/v1/jobs/:id/apply` - Apply for job
- `GET /api/v1/jobs/:id/applications` - View applications

## Environment Variables

```
# Server
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/campus_management
MONGODB_USER=admin
MONGODB_PASSWORD=password

# JWT
JWT_SECRET=your_secret_key_here
JWT_EXPIRE=7d
JWT_REFRESH_SECRET=your_refresh_secret
JWT_REFRESH_EXPIRE=30d

# API
API_URL=http://localhost:5000
API_VERSION=v1

# CORS
CORS_ORIGIN=localhost:3000,localhost:8080

# File Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880
```

## Code Quality

### Linting
```bash
npm run lint
```

### Fix Linting Issues
```bash
npm run lint:fix
```

## Troubleshooting

### MongoDB Connection Error
- Ensure MongoDB is running
- Check `MONGODB_URI` in `.env`
- If using Docker, check `docker ps`

### Port Already in Use
```bash
# Linux/Mac
lsof -i :5000
kill -9 <PID>

# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

### Docker Issues
```bash
# Remove and rebuild containers
docker-compose down -v
docker-compose up -d --build
```

## Next Steps

1. Update the mobile app's `api_service.dart` to point to your backend URL
2. Configure JWT secrets properly in production
3. Set up email service for user notifications
4. Implement file upload handling for profile images
5. Set up logging and monitoring

## Support

For issues or questions, please refer to:
- Backend README.md
- API endpoint documentation
- MongoDB documentation

---

**Last Updated:** March 2026
