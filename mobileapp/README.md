# Campus Management Mobile Application

A comprehensive Flutter-based mobile application for campus management, designed to serve students, faculty, and administrators with features for academic management, announcements, events, placement updates, and campus navigation.

## Features

### 1. User Authentication (1.1)
- Multi-role login (Student, Faculty, Admin)
- Secure registration with institutional email
- Password reset with OTP verification
- Role-based access control (RBAC)

### 2. User Profile Management (1.2)
- View and edit profile details
- Upload profile pictures
- View department, semester, and course information

### 3. Academic Management (1.3)
- View class timetables
- Track attendance by subject
- View internal marks
- Check examination schedule

### 4. Announcements Module (1.4)
- Department announcements
- College-wide announcements
- Event alerts
- Emergency notices

### 5. Event Management (1.5)
- View upcoming campus events
- Event details (date, time, venue, description)
- Event reminders

### 6. Campus Navigation (1.6)
- Interactive campus map
- Building location information

### 7. Placement & Career Section (1.7)
- Internship notifications
- Job postings
- Placement drive updates
- Resume upload

## Project Structure

```
lib/
├── main.dart                     # App entry point
├── models/                       # Data models
│   ├── user.dart
│   ├── announcement.dart
│   └── event.dart
├── screens/                      # UI screens
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── academic/
│   │   └── academic_screen.dart
│   ├── announcements/
│   │   └── announcements_screen.dart
│   ├── events/
│   │   └── events_screen.dart
│   ├── campus_navigation/
│   │   └── campus_navigation_screen.dart
│   └── placement/
│       └── placement_screen.dart
├── services/                     # API services
│   ├── api_service.dart         # Base API service with JWT handling
│   └── auth_service.dart        # Authentication service
├── providers/                    # State management (Provider pattern)
│   └── auth_provider.dart
├── utils/                        # Utility functions
└── widgets/                      # Reusable widgets
```

## Technology Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **Navigation**: Named Routes + MaterialApp

### Backend (To be implemented)
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB (MongoDB Atlas)
- **Authentication**: JWT (JSON Web Tokens)

### Dependencies
- `provider`: State management
- `dio`: HTTP client for API calls
- `flutter_secure_storage`: Secure token storage
- `jwt_decoder`: JWT token handling
- `shared_preferences`: Local data storage
- `image_picker`: Image selection for profile pictures
- `cached_network_image`: Image caching
- `intl`: Date/time formatting
- `form_validator`: Form validation
- `http`: Alternative HTTP client

## Installation & Setup

### Prerequisites
- Flutter SDK (3.11.1+)
- Dart SDK
- Android Studio / Xcode (for running on emulators)
- Git

### Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mobileapp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

4. **Run tests**
   ```bash
   flutter test
   ```

## Running on Different Platforms

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

### Windows
```bash
flutter run -d windows
```

## Environment Configuration

Create a `.env` file in the project root (if needed for API endpoints):
```
API_BASE_URL=http://your-api-url/api
```

Update `lib/services/api_service.dart` with your backend API URL:
```dart
static const String _baseUrl = 'http://your-api-url/api';
```

## Development Workflow

### Hot Reload
```bash
flutter run
# Press 'r' in the terminal to hot reload
# Press 'R' for hot restart
```

### Build Release APK
```bash
flutter build apk --release
```

### Build Release iOS
```bash
flutter build ios --release
```

## API Integration

The app uses Dio for HTTP requests with built-in JWT token management. The `ApiService` class handles:
- Base URL configuration
- Request/response interceptors
- JWT token attachment to headers
- Token refresh logic
- Secure token storage

### Example API Call
```dart
final response = await _apiService.getDio().post(
  '/auth/login',
  data: {
    'email': email,
    'password': password,
  },
);
```

## State Management

The app uses the Provider pattern for state management. Key providers:
- `AuthProvider`: Handles authentication state and user data

### Usage
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    return Text(authProvider.user?.name ?? 'Guest');
  },
)
```

## Security Features

- Secure JWT token storage using `flutter_secure_storage`
- Password encryption (handled by backend)
- Role-based access control
- Automatic token expiration handling
- HTTPS for API communications (to be configured)

## Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/widget_test.dart
```

## Performance Considerations

- Images are cached using `cached_network_image`
- JWT tokens are securely stored on device
- Pagination support can be added to list screens
- Lazy loading for large lists

## Future Enhancements

- [ ] Push notifications for announcements and events
- [ ] Offline caching for announcements and events
- [ ] Advanced campus mapping with directions
- [ ] Grade tracking and GPA calculator
- [ ] Real-time chat for student-faculty communication
- [ ] Biometric authentication
- [ ] Dark mode support
- [ ] Multi-language support

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -am 'Add new feature'`
3. Push branch: `git push origin feature/your-feature`
4. Open a pull request

## Troubleshooting

### Build Issues
- Clear build: `flutter clean && flutter pub get`
- Rebuild: `flutter pub get && flutter run`

### Plugin Issues
- Update plugins: `flutter pub upgrade`
- Remove pubspec.lock: `rm pubspec.lock && flutter pub get`

### iOS Issues
- Pod update: `cd ios && pod update && cd ..`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions, please open an issue in the repository or contact the development team.

## Authors

- Campus Management Development Team

## Acknowledgments

- Flutter team for the excellent framework
- Provider package for state management
- Dio team for HTTP client library
