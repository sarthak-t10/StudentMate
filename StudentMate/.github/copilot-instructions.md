# StudentMate Flutter Project - Copilot Instructions

## Project Overview
StudentMate is a comprehensive Flutter-based academic productivity application designed to assist students in managing their academic activities efficiently.

### Development Phases
- **Phase 1**: Foundation & Core UI (Screen design, navigation, basic functionality)
- **Phase 2**: Industry-Level Architecture & Logic (MVVM, Firebase, business logic)
- **Phase 3**: Advanced Features & Product-Level Enhancement (Analytics, AI assistant, themes)

## Technical Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider / Riverpod
- **Local Storage**: Hive / SQLite
- **Backend**: Firebase (Firestore, Authentication)
- **UI Components**: Material Design, Custom Widgets
- **Analytics**: Charts (fl_chart)
- **Notifications**: Firebase Cloud Messaging
- **Architecture**: MVVM Pattern

## Project Structure
```
lib/
├── models/           # Data models
├── views/            # UI screens
├── viewmodels/       # Business logic
├── services/         # API & local services
├── repositories/     # Data access layer
├── widgets/          # Reusable widgets
├── utils/            # Utilities & constants
└── main.dart         # Entry point
```

## Development Checklist

- [x] Project scaffolding complete
- [ ] Core UI screens created (Home, Attendance, Grades, Timetable, Profile)
- [ ] Navigation implemented (Basic structure in place)
- [ ] State management setup
- [ ] Database integration
- [ ] Business logic implementation
- [ ] Notifications configured
- [ ] Analytics integrated
- [ ] Dark mode support
- [ ] Testing completed
- [x] Documentation updated

## Key Features to Implement

### Phase 1
- Splash Screen
- Auth Screens (Login/Registration)
- Home Dashboard
- Attendance Tracker
- CGPA/Grade Calculator
- Timetable View
- Profile Screen

### Phase 2
- Database persistence
- MVVM architecture
- Repository pattern
- Business logic implementation
- Attendance analytics
- Grade tracking

### Phase 3
- Charts and graphs
- Dark mode
- Notifications
- AI Study Assistant (optional)
- Advanced analytics
- Export functionality

## Notes
- Follow Dart/Flutter naming conventions
- Maintain clean architecture
- Implement error handling
- Write meaningful comments
- Test all features thoroughly

# database requirements
- Use Hive for local storage of user accounts, user type (student/faculty/admin) branch, section, subjects, credits, marks, club events, claender events, announcements and timetable information (based on section).
- Ensure data models are properly defined with Hive annotations for code generation.
- Implement CRUD operations for all data entities (User, Attendance, Grade, TimeTable).
- Consider data relationships (e.g., User has many Attendance records) and implement accordingly.
- Ensure data persistence across app sessions and handle data migrations if necessary.
- Implement secure storage for sensitive information (e.g., user credentials) if needed.
- Optimize database queries for performance, especially when dealing with large datasets (e.g., attendance history).
- Regularly back up data to prevent loss and consider implementing a sync mechanism with Firebase for cloud
- ensure that all data is permanently recorded and retrievable

