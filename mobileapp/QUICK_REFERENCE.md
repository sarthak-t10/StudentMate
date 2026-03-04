# 🎯 Backend Setup - Quick Reference Card

## Get Started in 3 Steps

### Step 1: Start the Backend
```bash
cd backend
docker-compose up -d
```

### Step 2: Run the Mobile App
```bash
flutter run
```

### Step 3: Test
- Open app → Register → Login → Done! 🎉

---

## Important URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| **API Server** | `http://localhost:5000/api/v1` | - |
| **Health Check** | `http://localhost:5000/health` | - |
| **MongoDB** | `localhost:27017` | admin/password |
| **Mongo Express** | `http://localhost:8081` | - |

---

## File Locations

```
mobileapp/
├── backend/                           ← ALL BACKEND CODE HERE
│   ├── src/
│   │   ├── config/                   ← Database config
│   │   ├── controllers/              ← Business logic (6 files)
│   │   ├── models/                   ← Database schemas (5 files)
│   │   ├── routes/                   ← API endpoints (6 files)
│   │   ├── middleware/               ← Auth, validation, errors
│   │   ├── utils/                    ← JWT, helpers
│   │   └── server.js                 ← Main server
│   ├── package.json                  ← Dependencies
│   ├── .env.example                  ← Config template
│   ├── docker-compose.yml            ← Docker setup
│   ├── Dockerfile                    ← Docker image
│   ├── README.md                     ← Full docs
│   └── QUICK_START.md               ← Quick setup
│
├── SETUP_SUMMARY.md                 ← Read this first!
├── BACKEND_INTEGRATION.md           ← Mobile app guide
├── BACKEND_SETUP_COMPLETE.md        ← Setup overview
├── BACKEND_VERIFICATION_CHECKLIST.md ← Verification
│
├── lib/
│   └── services/
│       └── api_service.dart         ← UPDATED with backend URL
```

---

## Most Useful Commands

```bash
# Start backend (easiest)
cd backend && docker-compose up -d

# View logs
docker-compose logs -f api

# Stop backend
docker-compose down

# Restart everything fresh
docker-compose down -v && docker-compose up -d

# Test API
curl http://localhost:5000/health

# Access database web UI
# Open: http://localhost:8081
```

---

## API Quick Test

### Register
```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123","name":"Test","role":"Student"}'
```

### Login
```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123"}'
```

### Get Announcements
```bash
curl http://localhost:5000/api/v1/announcements
```

---

## API Endpoints (32 Total)

### Auth (4)
- `POST /auth/register` - Register
- `POST /auth/login` - Login
- `POST /auth/logout` - Logout
- `POST /auth/refresh` - Refresh token

### Users (4)
- `GET /users/profile` - Get profile
- `PUT /users/profile` - Update profile
- `GET /users` - List users (admin)
- `DELETE /users/:id` - Delete user

### Announcements (5)
- `GET /announcements` - List
- `GET /announcements/:id` - Get one
- `POST /announcements` - Create
- `PUT /announcements/:id` - Update
- `DELETE /announcements/:id` - Delete

### Events (7)
- `GET /events` - List
- `GET /events/:id` - Get one
- `POST /events` - Create
- `PUT /events/:id` - Update
- `DELETE /events/:id` - Delete
- `POST /events/:id/register` - Register
- `POST /events/:id/unregister` - Unregister

### Attendance (5)
- `GET /attendance` - List (faculty/admin)
- `GET /attendance/user/:userId` - Get user's
- `POST /attendance` - Mark (faculty/admin)
- `PUT /attendance/:id` - Update
- `DELETE /attendance/:id` - Delete

### Jobs (7)
- `GET /jobs` - List
- `GET /jobs/:id` - Get one
- `POST /jobs` - Create (faculty/admin)
- `PUT /jobs/:id` - Update
- `DELETE /jobs/:id` - Delete
- `POST /jobs/:id/apply` - Apply
- `GET /jobs/:id/applications` - View apps

---

## Configuration

**Default .env values:**
```
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/campus_management
JWT_SECRET=your_secret_key_here
CORS_ORIGIN=localhost:3000,localhost:8080
```

Use as-is for local development.

---

## User Roles

| Role | Permissions |
|------|-------------|
| **Student** | View content, apply jobs, register events |
| **Faculty** | Create announcements, mark attendance, post jobs |
| **Admin** | Access everything |

---

## Database Models

1. **User** - Accounts with roles
2. **Announcement** - News/updates
3. **Event** - Campus events
4. **Attendance** - Student attendance
5. **JobPosting** - Job listings

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Port 5000 in use | `taskkill /PID <PID> /F` (Windows) |
| MongoDB error | `docker-compose down && docker-compose up -d` |
| Can't connect | Verify API URL in `api_service.dart` |
| App won't start | Backend might be down, check `docker-compose logs -f` |
| Permission denied | Run with `sudo` (Mac/Linux) or as admin (Windows) |

---

## Documentation

| File | Read When |
|------|-----------|
| `SETUP_SUMMARY.md` | Want full overview |
| `backend/README.md` | Need detailed docs |
| `backend/QUICK_START.md` | Want quick setup |
| `BACKEND_INTEGRATION.md` | Integrating with app |
| `BACKEND_VERIFICATION_CHECKLIST.md` | Verifying setup |

---

## For Physical Device Testing

Replace `localhost` with your machine IP in `lib/services/api_service.dart`:

```dart
// Windows: ipconfig
// Mac/Linux: ifconfig
// Get IP like: 192.168.1.100

static const String _baseUrl = 'http://192.168.1.100:5000/api/v1';
```

---

## What's Included

✅ Complete Express API server  
✅ MongoDB database setup  
✅ JWT authentication  
✅ 5 database models  
✅ 32+ API endpoints  
✅ Docker containerization  
✅ Comprehensive documentation  
✅ Mobile app integration ready  
✅ Security features (CORS, rate limiting, etc.)  
✅ Code linting configuration  

---

## Version Info

- **Node.js:** 14+
- **MongoDB:** 4.0+
- **Express:** 4.18+
- **Backend Version:** 1.0.0
- **Created:** March 3, 2026

---

## Need Help?

1. **Check logs:** `docker-compose logs -f api`
2. **Read docs:** See files above
3. **Test API:** Use curl examples above
4. **Verify setup:** Run BACKEND_VERIFICATION_CHECKLIST.md

---

**You're all set! 🚀**

Start with: `cd backend && docker-compose up -d`

Then: `flutter run`

---
