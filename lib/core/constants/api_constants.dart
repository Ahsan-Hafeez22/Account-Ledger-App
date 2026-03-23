abstract final class ApiConstants {
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorizationPrefix = 'Bearer';
  static const String accessTokenKey = 'access_token';
}
