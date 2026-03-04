import 'package:flutter/material.dart';

// Color Palette
const Color _purpleLight = Color(0xFF9C6DD9);
const Color _purpleDark = Color(0xFF7C3AED);
const Color _pinkLight = Color(0xFFEC4899);
const Color _pinkDark = Color(0x0fdbe1d7);
const Color _blueDark = Color(0xFF0B3D91);
const Color _blueLight = Color(0xFF4FC3F7);

// Dark mode colors
const Color _blackBackground = Color(0xFF0A0A0A);
const Color _goldPrimary = Color(0xFFD4AF37);
const Color _goldLight = Color(0xFFFFD700);
const Color _goldDark = Color(0xFFF0B900);
const Color _brightYellow = Color(0xFFFFEB3B); // Bright yellow for widgets
const Color _whiteText = Color(0xFFFFFFFF); // White text for black background
const Color _lightGray = Color(0xFFE0E0E0); // Light gray for secondary text

class AppColors {
  // Primary Gradient Colors
  static const Color purpleLight = _purpleLight;
  static const Color purpleDark = _purpleDark;
  static const Color pinkLight = _pinkLight;
  static const Color pinkDark = _pinkDark;
  static const Color blueDark = _blueDark;
  static const Color blueLight = _blueLight;

  // Background Colors
  static const Color backgroundColor =
      Color(0xFFF8F7FC); // Very light with purple tint
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F0FB);

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

  // Attendance Colors
  static const Color attendanceGoodColor = Color(0xFF10B981); // Green
  static const Color attendanceBadColor = Color(0xFFEF4444); // Red
  static const Color attendanceWarningColor = Color(0xFFF59E0B); // Yellow

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF1F2937);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color textHintColor = Color(0xFFD1D5DB);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_purpleLight, _pinkLight],
  );

  static const LinearGradient primaryDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_purpleDark, _pinkDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [_pinkLight, _purpleLight],
  );

  static const LinearGradient secondaryDarkGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [_pinkDark, _purpleDark],
  );

  static const LinearGradient blueTextGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_blueDark, _blueLight],
  );

  // Dark Mode Gradient (Black background with Gold gradient)
  static const LinearGradient darkModePrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_goldPrimary, _goldLight],
  );

  static const LinearGradient darkModeSecondaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [_goldLight, _goldDark],
  );

  // Dark Mode Colors
  static const Color darkModeBackground = _blackBackground;
  static const Color darkModeSurface =
      _blackBackground; // Black surface for cards
  static const Color darkModeWidgetColor =
      _brightYellow; // Bright yellow for widgets
  static const Color darkModeText = _whiteText; // White text on black
  static const Color darkModeTextSecondary =
      _lightGray; // Light gray for secondary text
  static const Color goldLight = _goldLight;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
}

class AppShadow {
  static const BoxShadow light = BoxShadow(
    color: Color(0x1A7C3AED),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow medium = BoxShadow(
    color: Color(0x247C3AED),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow heavy = BoxShadow(
    color: Color(0x337C3AED),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
}

class AppTheme {
  static TextStyle _gradientHeadingStyle(
    double fontSize, {
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      foreground: Paint()
        ..shader = AppColors.blueTextGradient.createShader(
          const Rect.fromLTWH(0, 0, 260, 80),
        ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.purpleDark,
      secondary: AppColors.pinkLight,
      surface: AppColors.surface,
      error: AppColors.errorColor,
    ),
    scaffoldBackgroundColor: AppColors.backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _gradientHeadingStyle(20),
      iconTheme: const IconThemeData(color: AppColors.purpleDark),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      color: AppColors.surface,
      shadowColor: AppColors.purpleDark.withOpacity(0.1),
    ),
    textTheme: _buildTextTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purpleLight,
      secondary: AppColors.pinkLight,
      surface: Color(0xFF1F2937),
      error: AppColors.errorColor,
    ),
    scaffoldBackgroundColor: const Color(0xFF111827),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1F2937),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _gradientHeadingStyle(20),
      iconTheme: const IconThemeData(color: AppColors.purpleLight),
    ),
    textTheme: _buildDarkModeTextTheme(),
  );

  /// Dark mode theme with black background and yellow widgets
  static ThemeData goldDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkModeWidgetColor,
      secondary: AppColors.darkModeWidgetColor,
      surface: AppColors.darkModeSurface,
      error: AppColors.errorColor,
      background: AppColors.darkModeBackground,
      onPrimary: Colors.black, // Black text on yellow widgets
      onSurface: AppColors.darkModeText, // White text on black surface
    ),
    scaffoldBackgroundColor:
        AppColors.darkModeBackground, // Black background for gold dark
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: _gradientHeadingStyle(20),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      color: AppColors.darkModeWidgetColor, // Yellow card background
      shadowColor: AppColors.darkModeWidgetColor.withOpacity(0.3),
    ),
    textTheme: _buildGoldDarkModeTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkModeWidgetColor,
        foregroundColor: Colors.black, // Black text on yellow button
        elevation: 4,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkModeText,
        side: const BorderSide(color: AppColors.darkModeWidgetColor, width: 2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkModeWidgetColor,
      labelStyle: const TextStyle(color: Colors.black),
      hintStyle: const TextStyle(color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.darkModeWidgetColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:
            const BorderSide(color: AppColors.darkModeWidgetColor, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(AppColors.darkModeWidgetColor),
      checkColor: MaterialStateProperty.all(Colors.black),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(AppColors.darkModeWidgetColor),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.darkModeWidgetColor),
      trackColor: MaterialStateProperty.all(AppColors.darkModeSurface),
    ),
  );

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: _gradientHeadingStyle(32),
      displayMedium: _gradientHeadingStyle(28),
      displaySmall: _gradientHeadingStyle(24),
      headlineMedium: _gradientHeadingStyle(20, fontWeight: FontWeight.w600),
      headlineSmall: _gradientHeadingStyle(18, fontWeight: FontWeight.w600),
      titleLarge: _gradientHeadingStyle(16, fontWeight: FontWeight.w600),
      titleMedium: _gradientHeadingStyle(14, fontWeight: FontWeight.w600),
      titleSmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryColor,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryColor,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryColor,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryColor,
      ),
      labelLarge: _gradientHeadingStyle(14, fontWeight: FontWeight.w600),
    );
  }

  static TextTheme _buildDarkModeTextTheme() {
    return TextTheme(
      displayLarge: _gradientHeadingStyle(32),
      displayMedium: _gradientHeadingStyle(28),
      displaySmall: _gradientHeadingStyle(24),
      headlineMedium: _gradientHeadingStyle(20, fontWeight: FontWeight.w600),
      headlineSmall: _gradientHeadingStyle(18, fontWeight: FontWeight.w600),
      titleLarge: _gradientHeadingStyle(16, fontWeight: FontWeight.w600),
      titleMedium: _gradientHeadingStyle(14, fontWeight: FontWeight.w600),
      titleSmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.darkModeTextSecondary,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.darkModeText,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.darkModeText,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.darkModeTextSecondary,
      ),
      labelLarge: _gradientHeadingStyle(14, fontWeight: FontWeight.w600),
    );
  }

  /// Text theme for gold dark mode - all text is black (for yellow widgets)
  static TextTheme _buildGoldDarkModeTextTheme() {
    return TextTheme(
      displayLarge: _gradientHeadingStyle(32),
      displayMedium: _gradientHeadingStyle(28),
      displaySmall: _gradientHeadingStyle(24),
      headlineMedium: _gradientHeadingStyle(20, fontWeight: FontWeight.w600),
      headlineSmall: _gradientHeadingStyle(18, fontWeight: FontWeight.w600),
      titleLarge: _gradientHeadingStyle(16, fontWeight: FontWeight.w600),
      titleMedium: _gradientHeadingStyle(14, fontWeight: FontWeight.w600),
      titleSmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.black87,
      ),
      labelLarge: _gradientHeadingStyle(14, fontWeight: FontWeight.w600),
    );
  }
}

class AppTextStyles {
  static TextStyle blueGradient({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      foreground: Paint()
        ..shader = AppColors.blueTextGradient.createShader(
          const Rect.fromLTWH(0, 0, 260, 80),
        ),
    );
  }

  static TextStyle grayGradient({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      foreground: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F2F2F), Color(0xFF9E9E9E)],
        ).createShader(
          const Rect.fromLTWH(0, 0, 260, 80),
        ),
    );
  }
}
