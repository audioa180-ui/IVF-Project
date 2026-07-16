class AppConfig {
  // Both Flutter clients use this same endpoint. Override it per environment:
  // flutter run --dart-define=API_BASE_URL=https://your-service.onrender.com/api
  static const String productionApiUrl = 'https://ivf-project-main.onrender.com/api';
  
  // Local development URL
  static const String localApiUrl = 'http://localhost:4000/api';
  
  // Set to true when using production backend
  static const String _override = String.fromEnvironment('API_BASE_URL');
  static String get apiUrl => _override.isNotEmpty ? _override : productionApiUrl;
}
