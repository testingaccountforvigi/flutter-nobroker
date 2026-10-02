/// Application configuration.
/// Environment variables and constants.
class AppConfig {
  AppConfig._();

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5001/api',
  );

  // LiveKit Configuration
  static const String livekitUrl = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: '',
  );

  // App Information
  static const String appName = 'NoBroker Owner Listings';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Image
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // Premium
  static const int premiumPriceInr = 499;
  static const int premiumDurationDays = 30;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPropertyTitleLength = 100;
  static const int maxPropertyDescriptionLength = 2000;
}
