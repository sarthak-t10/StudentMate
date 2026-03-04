# StudentMate - Feature Roadmap & Implementation Guide

## Phase 1: Foundation & Core UI (Current Phase)

### Objectives
Build the core UI structure with all major screens and navigation without backend integration.

### Features to Implement

#### 1.1 Splash Screen
- **File**: `lib/views/splash_screen.dart`
- **Tasks**:
  - [ ] Design splash screen UI
  - [ ] Add app logo/branding
  - [ ] Implement 2-3 second delay
  - [ ] Navigation to login screen
- **Dependencies**: None
- **Estimated Time**: 2-3 hours

#### 1.2 Authentication Screens
- **Files**: 
  - `lib/views/auth/login_screen.dart`
  - `lib/views/auth/registration_screen.dart`
- **Tasks**:
  - [ ] Design login form (email, password)
  - [ ] Design registration form (name, email, password, confirm password)
  - [ ] Form validation
  - [ ] Navigation between screens
  - [ ] Error message handling UI
- **Dependencies**: None (Phase 1)
- **Estimated Time**: 4-5 hours

#### 1.3 Home Dashboard
- **File**: `lib/views/home_screen.dart`
- **Tasks**:
  - [ ] Design dashboard layout
  - [ ] Create dashboard cards:
    - [ ] Attendance percentage card
    - [ ] CGPA card
    - [ ] Study hours card
    - [ ] Upcoming classes/tasks card
  - [ ] Add quick action buttons
  - [ ] Implement refresh functionality UI
- **Dependencies**: None (Phase 1)
- **Estimated Time**: 4-5 hours

#### 1.4 Attendance Tracker Screen
- **File**: `lib/views/attendance_screen.dart`
- **Tasks**:
  - [ ] Design subject attendance list
  - [ ] Create attendance card component:
    - [ ] Subject name
    - [ ] Percentage (red if <75%, green if ≥75%)
    - [ ] Present/Total classes
    - [ ] Add class button
  - [ ] Implement subject detail view
  - [ ] Add ability to manually input attendance
- **Dependencies**: None (Phase 1)
- **Estimated Time**: 5-6 hours

#### 1.5 Grades & CGPA Calculator
- **File**: `lib/views/grades_screen.dart`
- **Tasks**:
  - [ ] Design grades list view
  - [ ] Create grade card component:
    - [ ] Subject name
    - [ ] Grade letter (A, B, C, etc.)
    - [ ] Marks
    - [ ] Credits
  - [ ] Design CGPA summary section
  - [ ] Create semester selector
  - [ ] Manual grade entry form
- **Dependencies**: None (Phase 1)
- **Estimated Time**: 5-6 hours

#### 1.6 Timetable View
- **File**: `lib/views/timetable_screen.dart`
- **Tasks**:
  - [ ] Integrate table_calendar package
  - [ ] Design class schedule view:
    - [ ] Daily view with time slots
    - [ ] Subject name
    - [ ] Instructor name
    - [ ] Room/location
  - [ ] Implement week/day toggle
  - [ ] Add class details popup
  - [ ] Color-coded subjects
- **Dependencies**: table_calendar
- **Estimated Time**: 5-6 hours

#### 1.7 Profile Screen
- **File**: `lib/views/profile_screen.dart`
- **Tasks**:
  - [ ] Design profile header:
    - [ ] Avatar
    - [ ] Name
    - [ ] Roll number
    - [ ] Department/Semester
  - [ ] Create profile details section:
    - [ ] Email
    - [ ] Phone
    - [ ] Batch
  - [ ] Settings section:
    - [ ] Change password
    - [ ] Notifications toggle
    - [ ] Theme selector
    - [ ] Logout button
- **Dependencies**: None (Phase 1)
- **Estimated Time**: 4-5 hours

#### 1.8 Bottom Navigation
- **File**: `lib/main.dart` (update) + `lib/widgets/bottom_nav_bar.dart`
- **Tasks**:
  - [ ] Create bottom navigation bar
  - [ ] Add navigation icons
  - [ ] Implement tab switching
  - [ ] Add active tab indicator
- **Dependencies**: None
- **Estimated Time**: 2-3 hours

### Reusable Widgets to Create
- [ ] `CustomAppBar` - Consistent app bar across screens
- [ ] `LoadingWidget` - Loading indicator
- [ ] `ErrorWidget` - Error message display
- [ ] `AttendanceCard` - For attendance display
- [ ] `GradeCard` - For grade display
- [ ] `TimeSlot` - For timetable time slots
- [ ] `CustomButton` - Styled button component
- [ ] `CustomTextField` - Styled text input

### Phase 1 Checklist
- [ ] All screens designed and implemented
- [ ] Bottom navigation working
- [ ] Local dummy data for all screens
- [ ] Theme colors applied
- [ ] Material Design principles followed
- [ ] All screens responsive on different screen sizes
- [ ] Code analysis passing (0 issues)
- [ ] Documentation updated

**Estimated Total Time**: 35-45 hours

---

## Phase 2: Industry-Level Architecture & Logic

### Objectives
Implement MVVM architecture, local database, and business logic.

### Features to Implement

#### 2.1 MVVM Architecture
- **Create ViewModels**:
  - [ ] `AuthViewModel` - Authentication logic
  - [ ] `AttendanceViewModel` - Attendance calculations
  - [ ] `GradeViewModel` - Grade and CGPA calculations
  - [ ] `TimetableViewModel` - Schedule management
  - [ ] `ProfileViewModel` - User profile management

#### 2.2 Hive Database Integration
- [ ] Create database initialization service
- [ ] Implement `UserRepository`
- [ ] Implement `AttendanceRepository`
- [ ] Implement `GradeRepository`
- [ ] Implement `TimetableRepository`
- [ ] Add database operations (CRUD)

#### 2.3 Attendance Logic
- [ ] Implement percentage calculation:
  ```
  Percentage = (Present Classes / Total Classes) * 100
  ```
- [ ] Update UI based on percentage:
  - [ ] Red color when < 75%
  - [ ] Green color when ≥ 75%
  - [ ] Yellow warning at 75%
- [ ] Add attendance forecasting

#### 2.4 CGPA Calculator Logic
- [ ] Implement grade point calculation:
  ```
  Grade Point System:
  Marks >= 90: 4.0
  Marks >= 80: 3.5
  Marks >= 70: 3.0
  Marks >= 60: 2.5
  Marks >= 50: 2.0
  Marks < 50: 0.0
  ```
- [ ] Calculate SGPA (Semester GPA):
  ```
  SGPA = (Σ(Grade Point × Credit)) / Σ(Credits)
  ```
- [ ] Implement CGPA tracking across semesters

#### 2.5 State Management with Provider/Riverpod
- [ ] Set up providers for each domain
- [ ] Implement state notifiers
- [ ] Add error handling
- [ ] Implement loading states

#### 2.6 Authentication Service
- [ ] Local authentication checks
- [ ] Session management (Phase 1)
- [ ] Firebase integration (Phase 2 extension)

#### 2.7 Data Sync & Persistence
- [ ] Implement offline-first approach
- [ ] Cache management
- [ ] Data validation

### Phase 2 Checklist
- [ ] All ViewModels implemented
- [ ] Repositories working with Hive
- [ ] Business logic tested
- [ ] MVVM pattern properly used
- [ ] State management functional
- [ ] Data persists correctly
- [ ] Code analysis passing
- [ ] Unit tests written (if applicable)

**Estimated Total Time**: 40-50 hours

---

## Phase 3: Advanced Features & Product-Level Enhancement

### Features to Implement

#### 3.1 Analytics & Charts
- **File**: `lib/views/analytics_screen.dart`
- [ ] Implement attendance trend chart
- [ ] Implement grade distribution chart
- [ ] Implement study hours chart
- [ ] Add date range filters
- [ ] Export analytics as PDF

#### 3.2 Dark Mode
- [ ] Create dark theme in `app_theme.dart`
- [ ] Implement theme toggle
- [ ] Apply colors consistently
- [ ] Store theme preference

#### 3.3 Push Notifications
- [ ] Firebase Cloud Messaging setup
- [ ] Attendance reminders
- [ ] Class schedule notifications
- [ ] Grade notifications
- [ ] Assignment reminders

#### 3.4 Advanced Features
- [ ] Study schedule planner
- [ ] Notes/Study materials manager
- [ ] Reminder system
- [ ] Performance analytics
- [ ] Goal setting and tracking

#### 3.5 AI Study Assistant (Optional)
- **Option A**: Rule-based chatbot
- **Option B**: API-based AI integration
- [ ] Features:
  - [ ] Subject doubts resolution
  - [ ] Study tips
  - [ ] Exam preparation guidance
  - [ ] Note suggestions

#### 3.6 UI/UX Enhancements
- [ ] Custom app icon
- [ ] Splash screen animation
- [ ] Screen transitions/animations
- [ ] Haptic feedback
- [ ] Sound effects
- [ ] Bottom sheet designs

#### 3.7 Performance Optimization
- [ ] Image optimization
- [ ] Lazy loading
- [ ] Database query optimization
- [ ] Memory management
- [ ] Build size optimization

#### 3.8 Testing & Quality Assurance
- [ ] Unit tests for ViewModels
- [ ] Widget tests for screens
- [ ] Integration tests
- [ ] Performance testing
- [ ] Security testing

### Phase 3 Checklist
- [ ] All charts implemented
- [ ] Dark mode working
- [ ] Notifications functional
- [ ] Performance optimized
- [ ] All tests passing
- [ ] App ready for Play Store
- [ ] Documentation complete

**Estimated Total Time**: 50-60 hours

---

## Implementation Priority

### High Priority (Phase 1)
1. Home Dashboard
2. Attendance Tracker
3. Grades & CGPA Calculator
4. Basic Navigation

### Medium Priority (Phase 2)
1. Database Integration
2. MVVM Architecture
3. Business Logic
4. State Management

### Low Priority (Phase 3)
1. Analytics
2. Dark Mode
3. Notifications
4. Advanced Features

---

## Code Quality Standards

### Naming Conventions
- Classes: PascalCase (e.g., `UserModel`, `AttendanceScreen`)
- Methods/Functions: camelCase (e.g., `calculateCGPA()`)
- Variables: camelCase (e.g., `totalClasses`)
- Constants: UPPER_SNAKE_CASE (e.g., `APP_NAME`)

### File Organization
- Keep files under 500 lines
- One class per file (exceptions: related enums, extensions)
- Organized imports
- Clear comments for complex logic

### Error Handling
- Try-catch blocks for database operations
- Null safety throughout
- Meaningful error messages
- User-friendly error dialogs

### Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for features
- Minimum 70% code coverage

---

## Progress Tracking

Use this template to track progress:

```
## Week 1
- [x] Splash Screen
- [x] Login Screen
- [ ] Registration Screen
- [ ] Home Dashboard

## Week 2
- [ ] Attendance Screen
- [ ] Grades Screen
- [ ] Timetable Screen
- [ ] Profile Screen
```

---

## Useful Commands

```bash
# Run analysis
flutter analyze

# Run tests
flutter test

# Generate code
flutter pub run build_runner build

# Clean build
flutter clean && flutter pub get

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## Learning Resources

- Flutter Documentation: https://flutter.dev/docs
- Dart Language: https://dart.dev/guides
- MVVM Pattern: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel
- Firebase for Flutter: https://firebase.flutter.dev/
- Provider Package: https://pub.dev/packages/provider
- Hive Database: https://docs.hivedb.dev/

---

## Support & Questions

For questions about the project structure or implementation, refer to the copilot-instructions.md file or the main README.md.
