/// Costanti globali dell'applicazione
library;

class AppConstants {
  AppConstants._();

  // Informazioni app
  static const String appName = 'Corpo Sostenibile';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.corposostenibile.com';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Animazioni
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
}
