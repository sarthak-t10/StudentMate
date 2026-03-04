# STUDENTMATE - COMPLETE ENV & DATA SHARING PACKAGE
# Share this entire folder with your friend

## 📦 PACKAGE CONTENTS

This folder contains everything needed to set up StudentMate on a new machine with all data and configuration.

### Files Included:

1. **`.env.example`** - Template environment configuration
   - MongoDB connection settings
   - Hive local storage configuration
   - Feature flags and app constants
   - Database collection schema reference

2. **`ENV_SETUP_GUIDE.md`** - Complete setup instructions
   - Environment configuration steps
   - MongoDB setup guide
   - Data import/export procedures
   - Troubleshooting guide

3. **`CONFIGURATION_REFERENCE.md`** - This file
   - Technical configuration details
   - All supported settings
   - Default values and ranges

4. **`studentmate_backup.json`** (Optional) - Database export
   - All Hive box data exported
   - User accounts, attendance, grades, timetable, etc.
   - Generated from Admin Settings → Export Database

5. **`pubspec.yaml`** - Flutter dependencies (auto-managed by `flutter pub get`)

6. **`.gitignore`** - Git configuration (already in repo)

## 🔧 SETUP QUICK START (5 minutes)

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd StudentMate

# 2. Copy environment file
cp .env.example .env

# 3. Edit .env with your MongoDB connection
# On Windows: Edit with Notepad or VS Code
# MongoDB Local: mongodb://localhost:27017/studentmate

# 4. Install Flutter dependencies
flutter pub get

# 5. Run the app
flutter run
```

## 🗄️ COMPLETE ENVIRONMENT REFERENCE

### APPLICATION CREDENTIALS

```
APP_NAME=StudentMate
APP_VERSION=1.0.0
```

### MONGODB CONNECTION STRINGS

| Environment | Connection String | Use Case |
|-------------|-------------------|----------|
| Local Dev | `mongodb://localhost:27017/studentmate` | Windows/Mac/Linux |
| Android Emulator | `mongodb://10.0.2.2:27017/studentmate` | Android Emulator |
| Physical Android | `mongodb://192.168.x.x:27017/studentmate` | Same WiFi Network |
| MongoDB Atlas | `mongodb+srv://user:pass@cluster.mongodb.net/studentmate` | Cloud (Production) |

**How to find your PC's IP for Android:**
```bash
# Windows
ipconfig

# Look for "IPv4 Address" under your WiFi connection
# Example: 192.168.29.118
```

### HIVE LOCAL STORAGE BOXES

| Box Name | Purpose | Auto-sync |
|----------|---------|-----------|
| `user_box` | User accounts & profiles | No |
| `attendance_box` | Attendance records | No |
| `grades_box` | Marks and grades | No |
| `timetable_box` | Class schedules | No |
| `theme_box` | App theme settings | Yes |
| `announcement_box` | Announcements cache | No |
| `club_event_box` | Club events | No |
| `offline_cache_box` | Offline mode data | Yes |

### FEATURE FLAGS

```env
# Enable/disable features
ENABLE_MONGODB=true              # Remote database
ENABLE_HIVE_LOCAL_STORAGE=true   # Local storage
ENABLE_ATTENDANCE_TRACKING=true  # Attendance feature
ENABLE_GRADE_TRACKING=true       # Grades feature
ENABLE_TIMETABLE=true            # Timetable feature
ENABLE_CLUB_EVENTS=true          # Club events
ENABLE_ANNOUNCEMENTS=true        # Announcements
ENABLE_DARK_MODE=true            # Dark theme
```

### SECURITY SETTINGS

```env
PASSWORD_MIN_LENGTH=6
SESSION_TIMEOUT_MINUTES=30
ENABLE_BIOMETRIC_AUTH=false
```

### LOGGING

```env
LOG_LEVEL=debug                     # debug, info, warning, error
ENABLE_CONSOLE_LOGGING=true
ENABLE_FILE_LOGGING=false
```

## 📊 DATA STRUCTURE SCHEMA

### Users Table
```javascript
{
  "_id": ObjectId,
  "email": "student@college.ac.in",        // Unique
  "password": "bcrypt_hash",
  "userType": "student",                   // student|faculty|admin
  "branch": "CSE",                         // Computer Science, etc.
  "section": "A1",
  "name": "John Doe",
  "rollNo": "CSE20012",
  "semester": 4,                           // Current semester (1-8)
  "phoneNumber": "+91XXXXXXXXXX",
  "profileImage": "base64_or_url",
  "createdAt": ISODate,
  "updatedAt": ISODate
}
```

### Attendance Table
```javascript
{
  "_id": ObjectId,
  "userId": ObjectId,                      // Foreign Key
  "subject": "Data Structures",
  "presentDays": 35,
  "totalDays": 45,
  "percentage": 77.78,
  "semester": 4,
  "academicYear": "2025-2026",
  "lastUpdated": ISODate
}
```

### Grades Table
```javascript
{
  "_id": ObjectId,
  "userId": ObjectId,                      // Foreign Key
  "subject": "Data Structures",
  "internalMarks": 20,
  "externalMarks": 65,
  "totalMarks": 85,
  "credits": 4,
  "gradePoint": 4.0,
  "grade": "A",
  "semester": 4,
  "academicYear": "2025-2026"
}
```

### Timetable Table
```javascript
{
  "_id": ObjectId,
  "branch": "CSE",
  "section": "A1",
  "scheduleData": {
    "monday": [
      {
        "time": "09:00-10:00",
        "subject": "Data Structures",
        "room": "L1",
        "faculty": "Dr. Smith"
      }
    ],
    "tuesday": [...],
    "wednesday": [...],
    "thursday": [...],
    "friday": [...]
  },
  "academicYear": "2025-2026",
  "semester": 4
}
```

### Announcements Table
```javascript
{
  "_id": ObjectId,
  "announcementType": "class",             // class|subject|general
  "branch": "CSE",
  "section": "A1",                         // Optional
  "subject": "Data Structures",            // Optional
  "title": "Assignment 2 Released",
  "content": "New assignment details...",
  "authorId": ObjectId,
  "createdAt": ISODate,
  "isActive": true,
  "priority": "normal",                    // low|normal|high|urgent
  "attachments": ["url1", "url2"]
}
```

### Club Events Table
```javascript
{
  "_id": ObjectId,
  "eventName": "Coding Competition",
  "eventDate": ISODate,
  "eventDescription": "Inter-college coding competition...",
  "location": "Auditorium",
  "organizer": "ObjectId",
  "registrations": [ObjectId],
  "status": "upcoming",                    // upcoming|ongoing|completed
  "createdAt": ISODate,
  "updatedAt": ISODate
}
```

## 🔐 SENSITIVE DATA

⚠️ **IMPORTANT SECURITY NOTES:**

1. **Never commit `.env` file to Git** - Use `.env.example` for template
2. **Don't share passwords** - Each user sets their own
3. **Database exports contain all data** - Keep backups secure
4. **Hive data files are unencrypted** - Use platform security for sensitive info
5. **Firebase keys should not be in `.env`** - Use Firebase Console instead

### Secure Storage Recommendations:
- User passwords: Use bcrypt hashing (already implemented)
- API keys: Use environment variables
- Database credentials: Use MongoDB Atlas with network access control
- Biometric auth: Use Flutter's `local_auth` package

## 📱 PLATFORM CONFIGURATION

### Android (android/gradle.properties)
```gradle
# Kotlin incremental compilation fix
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process

# Minimum SDK
android.targetSdkVersion=34
android.minSdkVersion=21
```

### iOS (Not specifically configured)
- Minimum iOS version: 11.0+
- Requires CocoaPods

### Windows Desktop
- Requires Visual Studio C++ build tools
- CMake 3.10+
- Windows 10+

### Web
- Requires Chrome for testing
- Requires web dependencies configuration

## 🌐 MONGODB SETUP METHODS

### Option 1: Local MongoDB (Windows)
```bash
# Download MongoDB Community Edition
# https://www.mongodb.com/try/download/community

# Start MongoDB service
mongod --dbpath C:\data\db
```

### Option 2: Docker (Recommended)
```bash
# Install Docker from https://www.docker.com

# Setup MongoDB container
docker run -d \
  -p 27017:27017 \
  --name studentmate-mongo \
  mongo:latest

# Check logs
docker logs studentmate-mongo

# Stop container
docker stop studentmate-mongo

# Start container again
docker start studentmate-mongo
```

### Option 3: MongoDB Atlas (Cloud - Free)
1. Create account: https://www.mongodb.com/cloud/atlas
2. Create free cluster (M0 tier)
3. Get connection string: `mongodb+srv://user:pass@cluster.mongodb.net/studentmate`
4. Add IP whitelist: 0.0.0.0/0 (for development only)
5. Use connection string in `.env`

## 📦 FLUTTER DEPENDENCIES

All managed in `pubspec.yaml`. Key packages:

```yaml
dependencies:
  flutter: sdk: flutter
  mongo_dart: ^0.10.8          # MongoDB client
  hive: ^2.2.3                 # Local database
  hive_flutter: ^1.1.0         # Hive for Flutter
  shared_preferences: ^2.2.0   # Key-value storage
  file_picker: ^10.3.10        # File selection
  image_picker: ^1.1.2         # Image handling
  intl: ^0.20.2               # Localization
  uuid: ^4.0.0                # ID generation
  
dev_dependencies:
  build_runner: ^2.4.7        # Code generation
  flutter_test: sdk: flutter
```

Install with: `flutter pub get`

## 🚀 BUILD & RUN

```bash
# Development
flutter run

# Analysis
flutter analyze

# Release Build (Android APK)
flutter build apk --release

# Release Build (Windows)
flutter build windows --release

# Web Build
flutter build web
```

## 🐛 DEBUGGING

Enable debug mode:
```bash
flutter run -v  # Verbose mode
```

Check MongoDB logs:
```bash
# Docker
docker logs studentmate-mongo

# Local
# Check MongoDB service logs in Event Viewer (Windows)
```

View app logs:
```bash
flutter logs
```

## 📋 COMMON CONFIGURATION ISSUES

### Issue: MongoDB Connection Refused
```
✗ MongoDB connection failed: Connection refused (OS Error: 10061)
```
**Fix:** Start MongoDB service or Docker container

### Issue: Hive Box Already Open
```
Error: The box already exists in the Hive
```
**Fix:** Run `flutter clean` and rebuild

### Issue: Kotlin Compilation Error
```
Execution failed for task ':app:compileDebugKotlin'
```
**Fix:** Ensure these are in `android/gradle.properties`:
```gradle
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process
```

### Issue: Different Drives Cause Build Failure
**Solution:** Already configured - see `android/gradle.properties`

## 📞 SUPPORT CHECKLIST

Before asking for help, verify:
- [ ] `.env` file exists and configured
- [ ] MongoDB is running and accessible
- [ ] `flutter pub get` completed successfully
- [ ] `flutter analyze` shows 0 issues
- [ ] Console shows no error messages
- [ ] All required SDKs installed (Flutter, Android tools, etc.)

## 🔄 DATA SYNC WORKFLOW

For sharing data between machines:

1. **On Original Machine:**
   - Open app
   - Go to Profile → Admin Settings
   - Click "Export Database"
   - Save `studentmate_backup.json`

2. **Transfer File:**
   - Email, cloud drive, or USB
   - Share JSON file with friend

3. **On New Machine:**
   - Install StudentMate
   - Run app once (initializes Hive boxes)
   - Go to Profile → Admin Settings
   - Click "Import Database"
   - Select received `studentmate_backup.json`
   - Data syncs to all Hive boxes

## ✅ VERIFICATION CHECKLIST

After setup, verify everything works:

- [ ] App launches without errors
- [ ] MongoDB connection successful
- [ ] Can log in to existing account
- [ ] Attendance data displays correctly
- [ ] Grades/marks show correct calculations
- [ ] Timetable loads for your section
- [ ] Announcements visible
- [ ] Dark mode toggle works
- [ ] Export/Import function accessible
- [ ] All screens are responsive

## 📚 ADDITIONAL RESOURCES

- **Flutter Docs:** https://flutter.dev/docs
- **Dart Docs:** https://dart.dev/guides
- **MongoDB Docs:** https://docs.mongodb.com
- **Hive Docs:** https://docs.hivedb.dev

---

**Created:** April 2026
**Version:** 1.0.0
**Last Updated:** April 2026
