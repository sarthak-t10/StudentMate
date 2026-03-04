import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

/// Enum to define available themes
enum AppThemeMode {
  light,
  dark,
  goldDark, // Black background with gold/yellow gradient
}

/// Service to manage app theme preference and persistence
class ThemeService {
  static const String _themeBoxName = 'theme_prefs';
  static const String _themeModeKey = 'themeMode';

  late Box<String> _themeBox;
  bool _initialized = false;

  /// Initialize the theme service and load saved preference
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _themeBox = await Hive.openBox<String>(_themeBoxName);
      _initialized = true;
      debugPrint('✓ ThemeService initialized');
    } catch (e) {
      debugPrint('✗ ThemeService initialization failed: $e');
    }
  }

  /// Get current theme mode preference
  AppThemeMode getCurrentThemeMode() {
    if (!_initialized) return AppThemeMode.light;

    try {
      final themeModeString =
          _themeBox.get(_themeModeKey, defaultValue: 'light');
      return AppThemeMode.values.firstWhere(
        (mode) => mode.toString().split('.').last == themeModeString,
        orElse: () => AppThemeMode.light,
      );
    } catch (e) {
      debugPrint('Error getting theme mode: $e');
      return AppThemeMode.light;
    }
  }

  /// Save theme mode preference
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    if (!_initialized) return;

    try {
      final themeModeString = themeMode.toString().split('.').last;
      await _themeBox.put(_themeModeKey, themeModeString);
      debugPrint('✓ Theme mode saved: $themeModeString');
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Check if dark mode is enabled
  bool isDarkModeEnabled() {
    final currentMode = getCurrentThemeMode();
    return currentMode == AppThemeMode.dark ||
        currentMode == AppThemeMode.goldDark;
  }

  /// Check if gold dark mode is enabled
  bool isGoldDarkModeEnabled() {
    return getCurrentThemeMode() == AppThemeMode.goldDark;
  }

  /// Close the theme box
  Future<void> close() async {
    if (_initialized && _themeBox.isOpen) {
      await _themeBox.close();
    }
  }
}
