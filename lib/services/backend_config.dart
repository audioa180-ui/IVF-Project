/// Runtime configuration for the secure API that sits in front of MongoDB.
///
/// Never put a MongoDB URI, database password, or MongoDB Atlas key in this
/// Flutter project. Values compiled into an APK can be extracted by anyone.
class BackendConfig {
  const BackendConfig._();

  /// Supply only the HTTPS URL of your future backend, for example:
  /// flutter run --dart-define=API_BASE_URL=https://api.example.com
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get isConfigured =>
      apiBaseUrl.startsWith('https://') || apiBaseUrl.startsWith('http://');

  static Uri endpoint(String path) {
    if (!isConfigured) {
      throw StateError(
        'API_BASE_URL is not configured. Start the app with --dart-define.',
      );
    }
    return Uri.parse('$apiBaseUrl$path');
  }
}
