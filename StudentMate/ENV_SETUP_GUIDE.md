# ENVIRONMENT SETUP & DATA IMPORT GUIDE
# For Setting Up StudentMate on a New Machine

## Quick Start Checklist

- [ ] Clone the repository
- [ ] Copy `.env` file to project root
- [ ] Update MongoDB connection string in `.env`
- [ ] Run `flutter pub get`
- [ ] Set up MongoDB locally or provide remote connection string
- [ ] Export Hive data from original installation
- [ ] Import Hive data on new machine
- [ ] Run the app

## 1. ENVIRONMENT SETUP

### 1.1 Create .env File
Copy the `.env.example` file to `.env`:
```bash
cp .env.example .env
```

### 1.2 Update MongoDB Connection
Edit `.env` and set your MongoDB URI:

**For Local Development:**
```
MONGODB_URI=mongodb://localhost:27017/studentmate
```

**For Android Emulator:**
```
MONGODB_URI=mongodb://10.0.2.2:27017/studentmate
```

**For Physical Android Device (replace with your PC's LAN IP):**
```
MONGODB_URI=mongodb://192.168.29.118:27017/studentmate
```

**For MongoDB Atlas (Cloud):**
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/studentmate
```

### 1.3 Verify MongoDB Connection
Before running the app, ensure MongoDB is running:

**Windows:**
```bash
mongod --dbpath C:\data\db
```

**Docker (Recommended):**
```bash
docker run -d -p 27017:27017 --name studentmate-mongo mongo
```

## 2. PROJECT SETUP

```bash
cd StudentMate
flutter pub get
flutter analyze
```

## 3. DATA IMPORT/EXPORT

### 3.1 Exporting Data from Original Installation

The app includes a database export/import feature in Admin Settings. Follow these steps:

1. Open StudentMate app
2. Go to **Profile** → **Admin Settings**
3. Find **Database Management** section
4. Click **Export Database**
5. Choose location to save `studentmate_backup.json`
6. Share this file with your friend

### 3.2 Importing Data on New Machine

On the new machine:

1. Install and run StudentMate
2. Go to **Profile** → **Admin Settings**
3. Find **Database Management** section
4. Click **Import Database**
5. Select the `studentmate_backup.json` file
6. Data will be imported into:
   - **user_box** - User accounts and profiles
   - **attendance_box** - Attendance records
   - **grades_box** - Grade/marks data
   - **timetable_box** - Class schedules
   - **announcement_box** - Announcements
   - **club_event_box** - Club events

### 3.3 Manual Data Export (Advanced)

If UI export fails, export data directory:

**Windows:**
```powershell
# Hive data location
$HiveDataPath = "$env:APPDATA\StudentMate"

# Backup all Hive boxes
Copy-Item -Path $HiveDataPath -Destination "$HOME\Desktop\studentmate_backup" -Recurse
```

**Android:**
```bash
adb pull /data/data/com.example.student_mate/ studentmate_backup/
```

## 4. HIVE LOCAL STORAGE LOCATIONS

### Data Storage Paths

**Windows Desktop:**
```
%APPDATA%\StudentMate\
├── user_box.hive
├── attendance_box.hive
├── grades_box.hive
├── timetable_box.hive
├── theme_box.hive
├── announcement_box.hive
├── club_event_box.hive
└── offline_cache_box.hive
```

**Android:**
```
/data/data/com.example.student_mate/
└── hive/
    ├── user_box.hive
    ├── attendance_box.hive
    └── ...
```

**iOS:**
```
~/Library/Preferences/com.example.student_mate/hive/
```

## 5. DATABASE STRUCTURE REFERENCE

### Users Collection
```json
{
  "_id": ObjectId,
  "email": "student@college.ac.in",
  "password": "hashed_password",
  "userType": "student",
  "branch": "CSE",
  "section": "A1",
  "name": "John Doe",
  "rollNo": "CSE001",
  "semester": 4,
  "createdAt": ISODate
}
```

### Attendance Collection
```json
{
  "_id": ObjectId,
  "userId": ObjectId,
  "subject": "Data Structures",
  "presentDays": 35,
  "totalDays": 45,
  "percentage": 77.8,
  "semester": 4,
  "academicYear": "2025-2026",
  "date": ISODate
}
```

### Grades Collection
```json
{
  "_id": ObjectId,
  "userId": ObjectId,
  "subject": "Data Structures",
  "marks": 85,
  "credits": 4,
  "semester": 4,
  "grade": "A",
  "academicYear": "2025-2026"
}
```

### Announcements Collection
```json
{
  "_id": ObjectId,
  "announcementType": "class",
  "branch": "CSE",
  "section": "A1",
  "subject": "Data Structures",
  "title": "Assignment 2 Released",
  "content": "New assignment available...",
  "authorId": ObjectId,
  "createdAt": ISODate,
  "isActive": true,
  "priority": "normal"
}
```

## 6. TROUBLESHOOTING

### MongoDB Connection Failed
```
✗ MongoDB connection failed: Connection refused
```
**Solution:** Ensure MongoDB is running. Start MongoDB service:
```bash
# Windows Service
net start MongoDB

# Or using Docker
docker start studentmate-mongo
```

### Hive Initialization Failed
```
✗ Hive initialization failed: DatabaseCorrupted
```
**Solution:** Delete Hive box files and restart app (data will be lost).

### Android Build Issues with Kotlin
```
Execution failed for task ':app:compileDebugKotlin'
```
**Solution:** The `.env` file includes Kotlin settings. These are already set in `android/gradle.properties`:
- `kotlin.incremental=false`
- `kotlin.compiler.execution.strategy=in-process`

## 7. SECURITY NOTES

⚠️ **Important:**
- The `.env` file contains sensitive configuration
- **Never commit `.env` to Git** - use `.env.example` instead
- Store passwords securely using platform-specific mechanisms
- For production, use environment variables or secure vaults
- Database exports contain all user data - keep backups secure

## 8. PLATFORM-SPECIFIC SETUP

### Windows Desktop
```bash
flutter run -d windows
```

### Android Emulator
```bash
flutter emulators --launch Pixel_4_API_30
flutter run
```

### Physical Android Device
```bash
adb devices  # Verify device is connected
flutter run
```

### Web (Experimental)
```bash
flutter run -d chrome
```

## 9. DEPENDENCIES SUMMARY

Key packages configured in `pubspec.yaml`:
- **mongo_dart** - MongoDB client
- **hive** - Local NoSQL database
- **hive_flutter** - Hive Flutter integration
- **shared_preferences** - Simple key-value storage
- **file_picker** - File selection for import/export
- **image_picker** - Image handling
- **syncfusion_flutter_pdfviewer** - PDF viewing
- **intl** - Internationalization

Install dependencies:
```bash
flutter pub get
pub run build_runner build  # Generate Hive type adapters
```

## 10. RUNNING THE APP

Development Mode:
```bash
flutter run
```

Release Build (APK):
```bash
flutter build apk --release
```

Web Build:
```bash
flutter build web
```

## Contact & Support

For issues or questions:
1. Check error logs in Debug Console
2. Review MongoDB connection string
3. Verify all dependencies are installed
4. Clear Flutter build cache: `flutter clean`
