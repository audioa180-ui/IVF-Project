class AppConfig {
  // Set this to your Render backend URL when deploying to production
  static const String productionApiUrl = 'https://ivf-project-main.onrender.com/api';
  
  // Local development URL
  static const String localApiUrl = 'http://localhost:4000/api';
  
  // Set to true when using production backend
  static const bool useProduction = true;
  
  static String get apiUrl => useProduction ? productionApiUrl : localApiUrl;
}
