import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/auth_service.dart';
import 'services/mongodb_service.dart';
import 'services/club_event_service.dart';
import 'services/theme_service.dart';
import 'utils/app_theme.dart';
import 'views/sign_in_screen.dart';
import 'views/sign_up_screen.dart';
import 'views/home_screen.dart';
import 'views/profile_screen.dart';

late ThemeService themeService;
final themeModeNotifier = ValueNotifier<AppThemeMode>(AppThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local data persistence
  try {
    await Hive.initFlutter();
    debugPrint('✓ Hive initialized');
  } catch (e) {
    debugPrint('✗ Hive initialization failed: $e');
  }

  // Initialize Theme Service
  try {
    themeService = ThemeService();
    await themeService.initialize();
    debugPrint('✓ Theme Service initialized');
  } catch (e) {
    debugPrint('✗ Theme Service initialization failed: $e');
    themeService = ThemeService();
  }

  // Initialize Club Event Service
  try {
    final clubEventService = ClubEventService();
    await clubEventService.initialize();
    debugPrint('✓ Club Event Service initialized');
  } catch (e) {
    debugPrint('✗ Club Event Service initialization failed: $e');
  }

  // Initialize MongoDB connection
  try {
    await MongoDBService.getDb();
    debugPrint('MongoDB connected successfully');
  } catch (e) {
    debugPrint('MongoDB connection failed: $e');
  }

  final authService = AuthService();
  await authService.initialize();

  runApp(const StudentMateApp());
}

class StudentMateApp extends StatefulWidget {
  const StudentMateApp({Key? key}) : super(key: key);

  @override
  State<StudentMateApp> createState() => _StudentMateAppState();

  /// Method to rebuild the app with new theme
  static void updateTheme(BuildContext context) {
    if (context.findAncestorStateOfType<_StudentMateAppState>() != null) {
      context.findAncestorStateOfType<_StudentMateAppState>()?.setState(() {});
    }
  }
}

class _StudentMateAppState extends State<StudentMateApp> {
  @override
  void initState() {
    super.initState();
    // Initialize the notifier with current theme
    themeModeNotifier.value = themeService.getCurrentThemeMode();
    // Listen for theme changes from ThemeService
    themeModeNotifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, currentThemeMode, _) {
        ThemeData getThemeData() {
          switch (currentThemeMode) {
            case AppThemeMode.light:
              return AppTheme.lightTheme;
            case AppThemeMode.dark:
              return AppTheme.darkTheme;
            case AppThemeMode.goldDark:
              return AppTheme.goldDarkTheme;
            default:
              return AppTheme.lightTheme;
          }
        }

        return MaterialApp(
          title: 'StudentMate',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: getThemeData(),
          themeMode: currentThemeMode == AppThemeMode.light
              ? ThemeMode.light
              : ThemeMode.dark,
          home: const AuthWrapper(),
          routes: {
            '/signin': (context) => const SignInScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) => const HomeScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    if (authService.isUserLoggedIn()) {
      return const HomeScreen();
    } else {
      return const SignInScreen();
    }
  }
}
