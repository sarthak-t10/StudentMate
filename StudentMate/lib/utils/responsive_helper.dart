import 'package:flutter/material.dart';

/// Responsive design helper class for calculating screen-dependent sizes and breakpoints.
/// This centralizes all responsive calculations to ensure consistent scaling across devices.
class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  // ═══════════════════════════════════════════════════════════════════════════
  // Screen Dimensions
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get the screen width in logical pixels
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Get the screen height in logical pixels
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Get the screen diagonal size
  double get diagonal => MediaQuery.of(context).size.longestSide;

  /// Get device padding (notches, safe area)
  EdgeInsets get safeAreaPadding => MediaQuery.of(context).padding;

  /// Get the device orientation (portrait/landscape)
  Orientation get orientation => MediaQuery.of(context).orientation;

  /// Check if device is in portrait mode
  bool get isPortrait => orientation == Orientation.portrait;

  /// Check if device is in landscape mode
  bool get isLandscape => orientation == Orientation.landscape;

  // ═══════════════════════════════════════════════════════════════════════════
  // Responsive Breakpoints
  // ═══════════════════════════════════════════════════════════════════════════

  /// Mobile breakpoint (small phones)
  static const double smallPhone = 300;

  /// Large phone breakpoint
  static const double largePhone = 600;

  /// Tablet breakpoint (small tablets and large phones)
  static const double tablet = 900;

  /// Large screen breakpoint (tablets and web)
  static const double largeScreen = 1200;

  /// Check if device is a small phone (<600dp width)
  bool get isSmallPhone => screenWidth < largePhone;

  /// Check if device is a large phone or small tablet (600-900dp width)
  bool get isMediumScreen => screenWidth >= largePhone && screenWidth < tablet;

  /// Check if device is a tablet (900-1200dp width)
  bool get isTablet => screenWidth >= tablet && screenWidth < largeScreen;

  /// Check if device is a large screen (>=1200dp width)
  bool get isLargeScreen => screenWidth >= largeScreen;

  // ═══════════════════════════════════════════════════════════════════════════
  // Grid Responsive Columns
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate grid columns dynamically based on screen width
  /// Returns 1-6 columns depending on device type
  int getGridColumns({int minColumns = 1, int maxColumns = 4}) {
    if (isSmallPhone) return minColumns;
    if (isMediumScreen) return minColumns + 1;
    if (isTablet) return minColumns + 2;
    return maxColumns;
  }

  /// Get responsive grid columns for card layouts (typically 1-3)
  int get cardGridColumns {
    if (isSmallPhone) return 2;
    if (isMediumScreen) return 2;
    if (isTablet) return 2;
    return 3;
  }

  /// Get responsive grid columns for small item grids (typically 2-4)
  int get itemGridColumns {
    if (isSmallPhone) return 2;
    if (isMediumScreen) return 3;
    if (isTablet) return 4;
    return 4;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Responsive Sizing - Scaling Factors
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get block size (percent of screen width for calculations)
  double get blockSizeHorizontal => screenWidth / 100;

  /// Get block size (percent of screen height for calculations)
  double get blockSizeVertical => screenHeight / 100;

  /// Get scaling factor relative to reference device (375dp wide phone)
  double get scaleFactor => screenWidth / 375.0;

  /// Get scaling factor relative to 600dp reference
  double get scaleFactorMedium => screenWidth / 600.0;

  /// Scale a value based on screen width
  double scale(double baseValue) => baseValue * scaleFactor;

  /// Scale a value based on 600dp reference
  double scaleMedium(double baseValue) => baseValue * scaleFactorMedium;

  // ═══════════════════════════════════════════════════════════════════════════
  // Responsive Padding & Spacing
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get responsive horizontal padding
  double get horizontalPadding {
    if (isSmallPhone) return 12.0;
    if (isMediumScreen) return 16.0;
    if (isTablet) return 20.0;
    return 24.0;
  }

  /// Get responsive vertical padding
  double get verticalPadding {
    if (isSmallPhone) return 12.0;
    if (isMediumScreen) return 16.0;
    if (isTablet) return 20.0;
    return 24.0;
  }

  /// Get responsive spacing between elements (small)
  double get spacingSmall {
    if (isSmallPhone) return 4.0;
    if (isMediumScreen) return 6.0;
    return 8.0;
  }

  /// Get responsive spacing between elements (medium)
  double get spacingMedium {
    if (isSmallPhone) return 8.0;
    if (isMediumScreen) return 12.0;
    return 16.0;
  }

  /// Get responsive spacing between elements (large)
  double get spacingLarge {
    if (isSmallPhone) return 12.0;
    if (isMediumScreen) return 16.0;
    if (isTablet) return 20.0;
    return 24.0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Responsive Font & Icon Sizes
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get responsive heading font size (typically for large titles)
  double get headingFontSize {
    if (isSmallPhone) return 28.0;
    if (isMediumScreen) return 32.0;
    return 36.0;
  }

  /// Get responsive title font size
  double get titleFontSize {
    if (isSmallPhone) return 20.0;
    if (isMediumScreen) return 24.0;
    return 28.0;
  }

  /// Get responsive subtitle font size
  double get subtitleFontSize {
    if (isSmallPhone) return 18.0;
    if (isMediumScreen) return 20.0;
    return 22.0;
  }

  /// Get responsive body font size
  double get bodyFontSize {
    if (isSmallPhone) return 14.0;
    if (isMediumScreen) return 15.0;
    return 16.0;
  }

  /// Get responsive small font size
  double get smallFontSize {
    if (isSmallPhone) return 12.0;
    if (isMediumScreen) return 13.0;
    return 14.0;
  }

  /// Get responsive icon size (small)
  double get iconSizeSmall {
    if (isSmallPhone) return 16.0;
    if (isMediumScreen) return 18.0;
    return 20.0;
  }

  /// Get responsive icon size (medium)
  double get iconSizeMedium {
    if (isSmallPhone) return 24.0;
    if (isMediumScreen) return 28.0;
    return 32.0;
  }

  /// Get responsive icon size (large)
  double get iconSizeLarge {
    if (isSmallPhone) return 32.0;
    if (isMediumScreen) return 40.0;
    return 48.0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Responsive Widget Dimensions
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get responsive card height
  double get cardHeight {
    if (isSmallPhone) return 140.0;
    if (isMediumScreen) return 160.0;
    if (isTablet) return 180.0;
    return 200.0;
  }

  /// Get responsive profile avatar size
  double get avatarSize {
    if (isSmallPhone) return 80.0;
    if (isMediumScreen) return 100.0;
    if (isTablet) return 120.0;
    return 140.0;
  }

  /// Get responsive button height
  double get buttonHeight {
    if (isSmallPhone) return 44.0;
    if (isMediumScreen) return 48.0;
    return 52.0;
  }

  /// Get responsive border radius (small)
  double get radiusSmall {
    if (isSmallPhone) return 6.0;
    if (isMediumScreen) return 8.0;
    return 10.0;
  }

  /// Get responsive border radius (medium)
  double get radiusMedium {
    if (isSmallPhone) return 12.0;
    if (isMediumScreen) return 14.0;
    return 16.0;
  }

  /// Get responsive border radius (large)
  double get radiusLarge {
    if (isSmallPhone) return 16.0;
    if (isMediumScreen) return 18.0;
    return 20.0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Container Width Calculations
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get max content width for large screens (prevents excessive horizontal expansion)
  double get maxContentWidth {
    if (isSmallPhone) return screenWidth - (horizontalPadding * 2);
    if (isMediumScreen) return screenWidth - (horizontalPadding * 2);
    if (isTablet) return screenWidth * 0.85;
    return 1200.0;
  }

  /// Get width for a single column taking up available space
  double get fullWidth => screenWidth - (horizontalPadding * 2);

  /// Get width for half screen (useful for 2-column layouts)
  double get halfWidth =>
      (screenWidth - (horizontalPadding * 2) - spacingMedium) / 2;

  /// Get width for a third screen
  double get thirdWidth =>
      (screenWidth - (horizontalPadding * 2) - (spacingMedium * 2)) / 3;

  /// Get width for a quarter screen
  double get quarterWidth =>
      (screenWidth - (horizontalPadding * 2) - (spacingMedium * 3)) / 4;

  // ═══════════════════════════════════════════════════════════════════════════
  // Aspect Ratios
  // ═══════════════════════════════════════════════════════════════════════════

  /// Standard card aspect ratio (width:height) - optimized for event poster images
  double get cardAspectRatio {
    if (isSmallPhone) return 0.65;
    if (isMediumScreen) return 0.75;
    return 0.85;
  }

  /// Wide card aspect ratio (for wider cards)
  double get wideCardAspectRatio => 2.4;

  /// Square aspect ratio
  double get squareAspectRatio => 1.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // Helper Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get a responsive EdgeInsets with all same values
  EdgeInsets getSymmetricPadding({
    required double horizontal,
    required double vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: scale(horizontal),
      vertical: scale(vertical),
    );
  }

  /// Get responsive EdgeInsets only
  EdgeInsets getOnlyPadding({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: scale(left),
      top: scale(top),
      right: scale(right),
      bottom: scale(bottom),
    );
  }

  /// Get responsive SizedBox for spacing
  SizedBox getSpacer({double height = 1.0, double width = 1.0}) {
    return SizedBox(
      height: scale(height),
      width: scale(width),
    );
  }

  /// Get responsive border radius
  BorderRadius getRadius({required double radius}) {
    return BorderRadius.circular(scale(radius));
  }

  /// Print device info for debugging
  void printDeviceInfo() {
    print('═══════════════════════════════════════════════════════════');
    print('📱 DEVICE INFO');
    print('═══════════════════════════════════════════════════════════');
    print('Screen Width: ${screenWidth.toStringAsFixed(1)} dp');
    print('Screen Height: ${screenHeight.toStringAsFixed(1)} dp');
    print('Orientation: $orientation');
    print('Device Type: ${_getDeviceType()}');
    print('Grid Columns: $cardGridColumns');
    print('Scale Factor: ${scaleFactor.toStringAsFixed(2)}x');
    print('═══════════════════════════════════════════════════════════');
  }

  String _getDeviceType() {
    if (isSmallPhone) return 'Small Phone';
    if (isMediumScreen) return 'Large Phone / Small Tablet';
    if (isTablet) return 'Tablet';
    return 'Large Screen / Desktop';
  }
}
