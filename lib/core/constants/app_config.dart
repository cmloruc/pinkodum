class AppConfig {
  // iOS simulator ve macOS için localhost çalışır.
  // Android emülatör için: http://10.0.2.2:3000/api
  // Gerçek cihaz için: makinenin lokal IP'si, ör. http://192.168.1.x:3000/api
  static const backendBaseUrl = 'http://localhost:3000/api';
}
