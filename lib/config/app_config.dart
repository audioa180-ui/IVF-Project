class AppConfig {
  // Set this to your Render backend URL when deploying to production
  // Example: 'https://bloom-ivf-backend.onrender.com/api'
  static const String productionApiUrl = 'https://your-render-app-url.onrender.com/api';
  
  // Local development URL
  static const String localApiUrl = 'http://localhost:4000/api';
  
  // Set to true when using production backend
  static const bool useProduction = false;
  
  static String get apiUrl => useProduction ? productionApiUrl : localApiUrl;
}
