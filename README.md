# StudentMate

StudentMate is a Flutter-based academic productivity workspace for students, with the main app located in [StudentMate](StudentMate).

## What’s Included

- Student notes and PYQ browsing by branch, semester, and subject
- Admin notes upload with file picking and MongoDB persistence
- Shared subject catalog to keep the notes and upload screens in sync
- Attendance tracking, grade tracking, timetable, announcements, clubs, calendar, and profile flows
- Theme support, including light, dark, and gold-dark modes
- Hive caching and MongoDB-backed data storage for the desktop app

## Main App

The Flutter app lives in [StudentMate/README.md](StudentMate/README.md). Use that folder for running and developing the desktop application.

## Quick Start

```bash
cd StudentMate
flutter pub get
flutter run -d windows
```

## Repository Layout

- `StudentMate/` - Flutter desktop app
- `studentmate-landing/` - landing page project
- `Mobile/`, `SE/`, `Data Structures/` - additional workspace content
