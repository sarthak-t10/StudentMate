# StudentMate

StudentMate is a comprehensive Flutter-based academic productivity application designed to help students manage academic work efficiently on desktop and mobile-friendly targets.

## Overview

StudentMate is structured in three progressive development phases:

### Phase 1 – Foundation & Core UI
- Splash Screen
- Authentication Screens (Login/Registration)
- Home Dashboard
- Attendance Tracker
- CGPA/Grade Calculator
- Timetable View
- Profile Screen

### Phase 2 – Industry-Level Architecture & Logic
- MVVM Architecture Implementation
- MongoDB and Hive persistence
- Repository Pattern
- Business Logic Implementation
- Attendance Analytics
- Grade Tracking

### Phase 3 – Advanced Features & Product-Level Enhancement
- Charts and Analytics Visualizations
- Dark Mode Support
- Push Notifications
- AI Study Assistant (Optional)
- Advanced Analytics
- Export Functionality

### Recently Added Features
- Notes and PYQ module with branch and semester filtering
- Subject catalog synced across the notes page and admin upload page
- Admin notes upload panel with real file selection
- Stored notes uploads loaded back into the student notes screen
- File opening support for uploaded local or remote files
- Intro screen and animated gradient-backed UI sections
- Light, dark, and gold-dark themes with persistent theme selection
- MongoDB-backed announcements, clubs, calendar, grades, and attendance flows

## Technical Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider / Riverpod
- **Local Storage**: Hive
- **Backend**: MongoDB
- **UI Components**: Material Design, Custom Widgets
- **Analytics**: fl_chart
- **File Handling**: file_picker, url_launcher, syncfusion_flutter_pdfviewer
- **Typography**: google_fonts

## Project Structure

```
lib/
├── models/           # Data models (User, Attendance, Grade, etc.)
├── views/            # UI screens (Home, Attendance, Grades, etc.)
├── viewmodels/       # Business logic and state management
├── services/         # API and local database services
├── repositories/     # Data access layer
├── widgets/          # Reusable components
├── utils/            # Constants, helpers, and utilities
├── views/            # Screens including notes, admin upload, intro, auth, home
└── main.dart         # Application entry point
```

## Getting Started

### Prerequisites

- Flutter 3.0.0 or higher
- Dart 3.0.0 or higher
- Visual Studio with Desktop development with C++ workload for Windows builds
- MongoDB running locally or configured through `MONGODB_URI`

### Installation

1. Clone the repository:
   ```bash
   git clone git@github.com:sarthak-t10/StudentMate.git
   cd StudentMate
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run -d windows
   ```

## Building for Release

### Windows
```bash
flutter build windows --release
```

### Android
```bash
flutter build apk --release
```

## Architecture Overview

StudentMate follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures representing entities
- **Views**: UI screens and widgets
- **ViewModels**: Business logic and state management
- **Repositories**: Abstraction layer for data access
- **Services**: Low-level data operations (API calls, database)

## Key Features

### Notes and PYQs
- Subject lists are shared across the notes screen and admin upload screen
- Uploaded notes can be selected from the student notes page by branch, semester, and subject
- Student taps open the stored file URL from MongoDB

### Attendance Module
- Track daily attendance
- Dynamic percentage calculation
- Conditional UI indicators (red for <75%, green for ≥75%)

### CGPA Calculator
- Credit-based weighted grade calculation
- SGPA formula logic
- Semester-wise CGPA tracking

### Notification System
- AlarmManager for scheduled notifications
- Time-based event triggering
- Real-world productivity enhancement

### Analytics Dashboard
- Attendance trends visualization
- Study hour progress tracking
- Interactive charts using fl_chart

### Admin Upload Panel
- Pick PDF and document files from the file system
- Save upload metadata to MongoDB
- Validate branch, semester, subject, upload type, and selected file before saving

## Development Practices

- Follow Dart/Flutter naming conventions
- Maintain clean architecture principles
- Implement proper error handling
- Write meaningful comments and documentation
- Test all features thoroughly
- Use consistent code formatting

## Contributing

1. Create a feature branch from `main`
2. Commit changes with clear messages
3. Push to the branch
4. Submit a pull request with description

## Code Style

All code should follow:
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- Project-specific linting rules in `analysis_options.yaml`

## Testing

Run tests with:
```bash
flutter test
```

## Troubleshooting

### Common Issues

1. **Build fails with "flutter pub get" error**
   - Clear pub cache: `flutter pub cache clean`
   - Get dependencies again: `flutter pub get`

2. **Device not found**
   - List connected devices: `flutter devices`
   - For desktop, verify that Windows desktop support is enabled in Flutter

3. **MongoDB connection issues**
   - Make sure MongoDB is running locally on port 27017, or set `MONGODB_URI`
   - On Windows desktop, direct MongoDB access is supported; web builds skip direct DB connections

4. **Build errors for Windows**
   - Install Visual Studio with C++ desktop workload
   - Clean build: `flutter clean`
   - Run: `flutter run -d windows`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please reach out to the development team.

---

**Note**: This is an academic project designed to demonstrate professional Android/Flutter development practices.
