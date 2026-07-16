class ApiConfig {
  // Keep the admin workspace and patient app on the same API by default.
  // Override with --dart-define=API_BASE_URL=<url>/api for staging/local builds.
  static const String productionApiUrl = 'https://ivf-project-main.onrender.com/api';
  static const String localApiUrl = 'http://localhost:4000/api';
  static const String _override = String.fromEnvironment('API_BASE_URL');
  static String get apiUrl => _override.isNotEmpty ? _override : productionApiUrl;
}
