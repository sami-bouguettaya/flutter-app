class ApiConfig {
  static const String baseUrl = 'http://172.20.10.5:5000/api';

  // Auth endpoints
  static const String register = '/users/register';
  static const String login = '/users/login';
  static const String profile = '/users/profile';

  // Car endpoints
  static const String cars = '/cars';

  // Headers
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
