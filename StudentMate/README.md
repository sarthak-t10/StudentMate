# StudentMate

A comprehensive Flutter-based academic productivity application designed to assist students in managing their academic activities efficiently.

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
- Room Database (SQLite) Integration
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

## Technical Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider / Riverpod
- **Local Storage**: Hive / SQLite
- **Backend**: Firebase (Firestore, Authentication)
- **UI Components**: Material Design, Custom Widgets
- **Analytics**: fl_chart
- **Notifications**: Firebase Cloud Messaging

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
└── main.dart         # Application entry point
```

## Getting Started

### Prerequisites

- Flutter 3.0.0 or higher
- Dart 3.0.0 or higher
- Android SDK 21 or higher (for Android)
- Xcode 13 or higher (for iOS)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd StudentMate
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Architecture Overview

StudentMate follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures representing entities
- **Views**: UI screens and widgets
- **ViewModels**: Business logic and state management
- **Repositories**: Abstraction layer for data access
- **Services**: Low-level data operations (API calls, database)

## Key Features

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
   - Check device connection: `adb devices`

3. **Build errors for Android**
   - Clean build: `flutter clean`
   - Run: `flutter run`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please reach out to the development team.

---

**Note**: This is an academic project designed to demonstrate professional Android/Flutter development practices.
