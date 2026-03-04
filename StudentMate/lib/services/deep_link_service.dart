import 'package:flutter/foundation.dart';

typedef DeepLinkCallback = void Function(
    String path, Map<String, String> params);

/// Service to handle deep linking for registration confirmation
/// Manages app scheme links like: studentmate://registration/success?eventId=...&userId=...
/// Note: Deep linking is disabled for Windows desktop builds
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();

  factory DeepLinkService() {
    return _instance;
  }

  DeepLinkService._internal();

  DeepLinkCallback? _onRegistrationSuccess;
  DeepLinkCallback? _onRegistrationError;

  /// Initialize deep link handling (stub - disabled for desktop)
  Future<void> initialize() async {
    debugPrint('✓ Deep link service initialized (disabled on this platform)');
  }

  /// Register callback for successful registration
  void onRegistrationSuccess(DeepLinkCallback callback) {
    _onRegistrationSuccess = callback;
  }

  /// Register callback for registration errors
  void onRegistrationError(DeepLinkCallback callback) {
    _onRegistrationError = callback;
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    debugPrint('📱 Deep link received: ${uri.toString()}');

    final path = uri.path;
    final params = uri.queryParameters;

    try {
      if (path.contains('registration/success')) {
        debugPrint(
            '✓ Registration successful: eventId=${params['eventId']}, userId=${params['userId']}');
        _onRegistrationSuccess?.call(path, params);
      } else if (path.contains('registration/error')) {
        debugPrint(
            '❌ Registration error: ${params['error'] ?? 'Unknown error'}');
        _onRegistrationError?.call(path, params);
      } else {
        debugPrint('⚠️ Unknown deep link path: $path');
      }
    } catch (e) {
      debugPrint('❌ Error handling deep link: $e');
    }
  }

  /// Generate confirmation redirect URL for Google Form
  /// Returns a deep link that Google Forms should redirect to after submission
  String getRegistrationConfirmationUrl({
    required String eventId,
    required String userId,
  }) {
    // For Android and iOS: studentmate://registration/success?eventId=...&userId=...
    // For Web: configure web-specific handling
    return 'https://studentmate.app/register/success?eventId=$eventId&userId=$userId';
  }

  /// Create a Google Form pre-fill URL with registration confirmation setup
  /// This URL can be embedded in the Google Form submission to redirect back to app
  String createGoogleFormUrlWithCallback({
    required String baseFormUrl,
    required String eventId,
    required String userId,
  }) {
    // Append callback URL as hidden field or form response destination
    // Note: Google Forms doesn't support post-submission redirects natively
    // This would typically be handled via:
    // 1. Form submission webhooks
    // 2. Google Apps Script
    // 3. Custom form confirmation message with deep link

    // For direct integration, add callback as query parameter
    final separator = baseFormUrl.contains('?') ? '&' : '?';
    return '$baseFormUrl${separator}usp=pp_url&entry.9999999=studentmate://registration/success?eventId=$eventId&userId=$userId';
  }

  /// Handle deep link from custom confirmation message
  /// In Google Forms, you can add a custom confirmation message with a link:
  /// "Thank you for registering! [Click here to return to StudentMate](studentmate://registration/success?eventId=...&userId=...)"
  void handleRegistrationConfirmation({
    required String eventId,
    required String userId,
  }) {
    final params = {
      'eventId': eventId,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _onRegistrationSuccess?.call('/registration/success', params);
  }

  /// Create a shareable registration link with event details
  String createRegistrationLink({
    required String eventId,
    required String eventName,
    required String clubName,
  }) {
    return 'studentmate://event/$eventId?name=$eventName&club=$clubName';
  }

  /// Parse registration link to extract event details
  Map<String, String>? parseRegistrationLink(String link) {
    try {
      final uri = Uri.parse(link);
      if (uri.scheme == 'studentmate' && uri.host == 'event') {
        return {
          'eventId': uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '',
          'name': uri.queryParameters['name'] ?? '',
          'club': uri.queryParameters['club'] ?? '',
        };
      }
    } catch (e) {
      debugPrint('❌ Error parsing registration link: $e');
    }
    return null;
  }

  /// Dispose resources
  void dispose() {
    debugPrint('✓ Deep link service disposed');
  }
}
