# 🎓 StudentMate - Academic Productivity Platform

> A comprehensive Flutter-based academic management system designed to empower students with intelligent tools for managing attendance, grades, notes, timetables, announcements, and more.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2)](https://dart.dev/)
[![MongoDB](https://img.shields.io/badge/MongoDB-Supported-green)](https://www.mongodb.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

---

## 📋 Table of Contents

- [Features](#-features)
- [Modules & Functions](#-modules--functions)
- [Technology Stack](#-technology-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Key Modules](#-key-modules)
- [Architecture](#-architecture)
- [Contributing](#-contributing)

---

## ✨ Features

### 📚 **Academic Management**
- ✅ **Notes & PYQ Repository** - Browse and download notes and previous year questions by branch, semester, and subject
- ✅ **Attendance Tracking** - Real-time attendance monitoring with percentage calculations and analytics
- ✅ **Grade Management** - Complete grade tracking with CGPA calculation and semester-wise analytics
- ✅ **Timetable** - Dynamic timetable view with branch and section filtering
- ✅ **Subject Details** - Comprehensive subject information with credits and marks breakdown

### 👥 **Role-Based Access Control**
- ✅ **Student Portal** - View grades, attendance, timetable, notes, announcements, and club events
- ✅ **Faculty Dashboard** - Manage grades, mark attendance, create announcements, organize club events
- ✅ **Admin Panel** - System-wide management, user administration, content upload, announcements

### 📢 **Communication & Events**
- ✅ **Announcements** - College-wide and faculty-specific announcements with filtering by branch, section, and subject
- ✅ **Club Events** - Browse and manage club events, RSVPs, and event details
- ✅ **Calendar Integration** - Event calendar with date-based filtering and notifications

### 📁 **File Management**
- ✅ **File Upload & Download** - Admin notes upload with file picker integration
- ✅ **Multiple Format Support** - PDF, DOCX, DOC, PPT, XLS, and more
- ✅ **File Opening** - Direct file viewing from MongoDB storage
- ✅ **Database Export/Import** - Backup and restore functionality for all data

### 🎨 **User Experience**
- ✅ **Theme Support** - Light, Dark, and Gold-Dark themes with persistent selection
- ✅ **Responsive Design** - Optimized for desktop and tablet views
- ✅ **Animated UI** - Gradient backgrounds, smooth transitions, and interactive widgets
- ✅ **Offline Caching** - Fallback data access when MongoDB is unavailable

### 🔒 **Security & Data**
- ✅ **MongoDB Persistence** - Secure data storage and retrieval
- ✅ **Hive Local Cache** - Fast local data caching for offline access
- ✅ **Role-Based Permissions** - Granular access control for different user types
- ✅ **Session Management** - Secure login/logout with token-based authentication

---

## 📦 Modules & Functions

### **🔐 Authentication Module**
| Component | Function |
|-----------|----------|
| `AuthService` | User login, registration, token management, session validation |
| `SignInScreen` | Login UI with email/password validation |
| `SignUpScreen` | Registration form with branch, section, and role selection |
| `IntroScreen` | Onboarding and welcome interface |

### **👨‍🎓 User & Profile Module**
| Component | Function |
|-----------|----------|
| `UserModel` | User data structure (name, email, branch, section, role) |
| `UserRepository` | CRUD operations for user data |
| `ProfileScreen` | User profile view, settings, theme selection, logout |

### **📚 Academic Module**
| Component | Function |
|-----------|----------|
| `AttendanceModel` | Attendance record structure |
| `AttendanceRepository` | Store, retrieve, and analyze attendance data |
| `StudentAttendanceScreen` | View personal attendance and trends |
| `FacultyAttendanceScreen` | Mark and manage student attendance |
| `GradeModel` | Grade and marks structure with components |
| `GradeRepository` | Grade storage, retrieval, CGPA calculations |
| `AcademicsScreen` | Display grades, CGPA, subject details |
| `AdminAcademicsScreen` | Manage grades and student marks |
| `FacultyAcademicScreen` | Enter marks and manage grades |

### **📅 Timetable & Calendar Module**
| Component | Function |
|-----------|----------|
| `TimetableModel` | Class schedule structure |
| `TimetableRepository` | Store and retrieve timetables |
| `TimetableScreen` | View schedule by branch, section, semester |
| `EventModel` | Event data structure |
| `EventRepository` | Event storage and retrieval |
| `CalendarScreen` | Event calendar view and management |
| `AdminCalendarScreen` | Create and manage calendar events |
| `FacultyCalendarScreen` | Faculty event management |

### **📢 Announcements Module**
| Component | Function |
|-----------|----------|
| `AnnouncementModel` | Announcement data (title, content, target audience) |
| `AnnouncementRepository` | Store announcements with filtering by type and branch |
| `StudentAnnouncementsScreen` | View college and faculty announcements |
| `AdminCreateAnnouncementScreen` | Create college-wide announcements |
| `FacultyCreateAnnouncementScreen` | Create section/subject-specific announcements |

### **🎯 Club Events Module**
| Component | Function |
|-----------|----------|
| `ClubEventModel` | Club event structure |
| `ClubEventRepository` | Store and manage club events |
| `ClubEventService` | Hive-based local storage for clubs |
| `ClubScreen` | Browse and RSVP for club events |
| `AdminClubScreen` | Manage club events and registrations |
| `FacultyClubScreen` | Faculty event organization |
| `StudentClubEventsScreen` | Student club event view |

### **📝 Notes & PYQ Module**
| Component | Function |
|-----------|----------|
| `NotesSubjectCatalog` | Centralized subject list by branch and semester |
| `NotesScreen` | Browse notes and PYQs by category, search, and view uploads |
| `AdminUploadScreen` | Upload notes/PYQs with file picker and metadata |
| `FileService` | File picking, validation, and opening |

### **🛠️ Service Layer**
| Service | Responsibilities |
|---------|------------------|
| `MongoDBService` | MongoDB connection, collection access, indexing |
| `FileService` | File operations, type detection, size validation |
| `AnnouncementService` | Announcement creation and distribution |
| `ThemeService` | Theme persistence and switching |
| `OfflineCacheService` | Hive-based data caching |
| `DatabaseExportImportService` | Backup and restore collections |
| `EventAutomationService` | Scheduled notifications and reminders |
| `DeepLinkService` | Deep linking for navigation |

### **🎨 Widget & UI Components**
| Widget | Purpose |
|--------|---------|
| `AnimatedGradientBackground` | Gradient background with animation |
| `StudentMateLogo` | Application logo component |
| `CustomWidgets` | Reusable UI components (buttons, cards, etc.) |

---

## 🏗️ Technology Stack

### **Frontend**
- **Framework**: Flutter (Dart 3.0+)
- **UI Library**: Material Design 3
- **State Management**: Provider Pattern (Ready for Riverpod upgrade)
- **Fonts**: Google Fonts (Orbitron, Montserrat, etc.)

### **Backend & Data**
- **Database**: MongoDB (Primary)
- **Local Storage**: Hive (Offline caching)
- **File Storage**: Local filesystem (file://) and remote (http/https)

### **Additional Libraries**
| Library | Purpose |
|---------|---------|
| `mongo_dart` | MongoDB driver |
| `hive_flutter` | Local data persistence |
| `file_picker` | File selection UI |
| `url_launcher` | Open files and URLs |
| `uuid` | Unique identifier generation |
| `google_fonts` | Typography |
| `syncfusion_flutter_pdfviewer` | PDF viewing |
| `path_provider` | File system paths |

---

## 📁 Project Structure

```
StudentMate/
├── lib/
│   ├── models/              # Data models (9 models)
│   │   ├── user_model.dart
│   │   ├── attendance_model.dart
│   │   ├── grade_model.dart
│   │   ├── timetable_model.dart
│   │   ├── announcement_model.dart
│   │   ├── club_event_model.dart
│   │   ├── event_model.dart
│   │   ├── subject_model.dart
│   │   └── academic_model.dart
│   │
│   ├── repositories/        # Data access layer (8 repos)
│   │   ├── user_repository.dart
│   │   ├── attendance_repository.dart
│   │   ├── grade_repository.dart
│   │   ├── timetable_repository.dart
│   │   ├── announcement_repository.dart
│   │   ├── event_repository.dart
│   │   ├── subject_repository.dart
│   │   └── academic_repository.dart
│   │
│   ├── services/            # Business logic (10 services)
│   │   ├── auth_service.dart
│   │   ├── mongodb_service.dart
│   │   ├── file_service.dart
│   │   ├── announcement_service.dart
│   │   ├── club_event_service.dart
│   │   ├── theme_service.dart
│   │   ├── offline_cache_service.dart
│   │   ├── database_export_import_service.dart
│   │   ├── event_automation_service.dart
│   │   └── deep_link_service.dart
│   │
│   ├── views/               # Screen implementations (26 screens)
│   │   ├── Authentication
│   │   │   ├── sign_in_screen.dart
│   │   │   ├── sign_up_screen.dart
│   │   │   └── intro_screen.dart
│   │   ├── Student Views
│   │   │   ├── home_screen.dart
│   │   │   ├── student_attendance_screen.dart
│   │   │   ├── academics_screen.dart
│   │   │   ├── timetable_screen.dart
│   │   │   ├── student_announcements_screen.dart
│   │   │   ├── student_club_events_screen.dart
│   │   │   ├── calendar_screen.dart
│   │   │   ├── club_screen.dart
│   │   │   ├── notes_screen.dart
│   │   │   └── student_subject_detail_screen.dart
│   │   ├── Faculty Views
│   │   │   ├── faculty_academic_screen.dart
│   │   │   ├── faculty_attendance_screen.dart
│   │   │   ├── faculty_calendar_screen.dart
│   │   │   ├── faculty_club_screen.dart
│   │   │   └── faculty_create_announcement_screen.dart
│   │   └── Admin Views
│   │       ├── admin_academics_screen.dart
│   │       ├── admin_calendar_screen.dart
│   │       ├── admin_club_screen.dart
│   │       ├── admin_settings_screen.dart
│   │       ├── admin_create_announcement_screen.dart
│   │       ├── admin_create_club_event_screen.dart
│   │       ├── admin_upload_screen.dart
│   │       └── profile_screen.dart
│   │
│   ├── widgets/             # Reusable components
│   │   ├── animated_gradient_background.dart
│   │   ├── studentmate_logo.dart
│   │   ├── custom_widgets.dart
│   │   ├── announcement_widgets.dart
│   │   └── responsive_layout_components.dart
│   │
│   ├── utils/               # Utilities & constants
│   │   ├── app_theme.dart (3 themes)
│   │   ├── notes_subject_catalog.dart
│   │   ├── responsive_helper.dart
│   │   └── app_colors.dart
│   │
│   ├── viewmodels/          # State management (MVVM pattern ready)
│   │
│   └── main.dart            # Application entry point
│
├── assets/                  # Images, icons, fonts
├── android/                 # Android native code
├── windows/                 # Windows desktop support
├── web/                     # Web support
├── test/                    # Unit tests
└── pubspec.yaml            # Dependencies configuration
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter**: 3.0.0 or higher
- **Dart**: 3.0.0 or higher
- **MongoDB**: Running locally or remote instance
- **Visual Studio**: With C++ desktop development workload (for Windows)

### Installation Steps

```bash
# 1. Clone the repository
git clone https://github.com/sarthak-t10/StudentMate.git
cd StudentMate

# 2. Install dependencies
flutter pub get

# 3. Set MongoDB URI (optional, defaults to localhost:27017)
export MONGODB_URI=mongodb://localhost:27017/studentmate

# 4. Run the application
flutter run -d windows              # Windows desktop
flutter run -d chrome               # Web browser
```

### 📱 Running on Different Platforms

```bash
# Windows Desktop
flutter run -d windows

# Android Emulator/Device
flutter run

# iOS Simulator/Device
flutter run -d ios

# Web Browser
flutter run -d chrome
```

---

## 🔄 Architecture

### **MVVM Pattern**
```
┌─────────────────┐
│   Views/UI      │  (Screens)
└────────┬────────┘
         │
┌────────▼────────┐
│  ViewModels     │  (Business Logic)
└────────┬────────┘
         │
┌────────▼────────┐
│  Repositories   │  (Data Access)
└────────┬────────┘
         │
┌────────▼────────┐
│  Services       │  (APIs, DB, File Ops)
└─────────────────┘
```

### **Data Flow**
1. **UI Layer** (Views) - Displays data to users
2. **ViewModel Layer** - Manages state and business logic
3. **Repository Layer** - Abstract data access
4. **Service Layer** - Implements data operations (MongoDB, Hive, File I/O)

---

## 📊 Features Breakdown by Role

### **👨‍🎓 Student**
- View personal attendance and grades
- Browse notes and PYQs by subject
- Check timetable and class schedule
- Receive announcements
- RSVP for club events
- Manage profile and preferences

### **👨‍🏫 Faculty**
- Mark and manage student attendance
- Enter grades and manage marks
- Create section/subject announcements
- Organize club events
- View class schedules
- Manage academic events

### **👨‍💼 Admin**
- System-wide announcements
- Upload and manage notes/PYQs
- Manage all users (create, edit, delete)
- View system statistics
- Database management (export/import)
- Configure themes and settings

---

## 📥 Data Models Overview

### User Model
```dart
- id: String (unique identifier)
- name: String
- email: String (unique)
- password: String (hashed)
- role: String (student/faculty/admin)
- branch: String
- section: String
- createdAt: DateTime
```

### Grade Model
```dart
- id: String
- userId: String
- subject: String
- internalMarks: InternalComponent[]
- externalMarks: double
- totalMarks: double
- gradePoint: double
- createdAt: DateTime
```

### Attendance Model
```dart
- id: String
- userId: String
- subject: String
- date: DateTime
- isPresent: bool
- semester: int
- createdAt: DateTime
```

---

## 🔐 Security Features

- ✅ **Role-Based Access Control** - Different features for different user roles
- ✅ **Data Validation** - Input validation on all forms
- ✅ **MongoDB Indexing** - Optimized queries with proper indexes
- ✅ **Offline Caching** - Secure local data with Hive encryption
- ✅ **Session Management** - Automatic logout on app close

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test --verbose

# Run integration tests
flutter test integration_test/
```

---

## 📚 Code Examples

### Fetching Announcements
```dart
final announcementRepo = AnnouncementRepository();
final announcements = await announcementRepo.getCollegeAnnouncements();
```

### Uploading Notes
```dart
final file = await FileService.pickDocumentFile(maxSizeMB: 100);
await db.collection('notes_uploads').insertOne({
  'branch': 'CSE',
  'semester': '3',
  'subject': 'Data Structures',
  'fileName': file.fileName,
  'fileUrl': file.fileUrl,
});
```

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/NewFeature`)
3. **Commit** changes (`git commit -m 'Add NewFeature'`)
4. **Push** to branch (`git push origin feature/NewFeature`)
5. **Submit** a Pull Request

### Contribution Guidelines
- Follow Dart style guide
- Write meaningful commit messages
- Add comments for complex logic
- Test before submitting PR
- Update documentation as needed

---

## 📋 Project Roadmap

### ✅ Completed
- ✓ Core MVVM architecture
- ✓ User authentication
- ✓ Attendance tracking
- ✓ Grade management
- ✓ Notes and PYQ module
- ✓ Theme system (Light/Dark/Gold)
- ✓ Announcements system
- ✓ Club events management
- ✓ MongoDB integration

### 🔄 In Progress
- Notifications system
- Analytics dashboard
- Performance optimization

### 📌 Planned
- AI study assistant
- Push notifications
- Advanced search filters
- Export to PDF
- Mobile app version

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 💬 Support & Contact

- **Report Issues**: [GitHub Issues](https://github.com/sarthak-t10/StudentMate/issues)
- **Email**: support@studentmate.dev
- **Documentation**: [Full Docs](StudentMate/README.md)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- MongoDB for reliable database
- Contributors and users for feedback and support

---

<div align="center">

**Made with ❤️ for students, by students**

[⬆ back to top](#-studentmate---academic-productivity-platform)

</div>
