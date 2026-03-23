import 'package:equatable/equatable.dart';

/// Base exception class for all custom exceptions
abstract class AppException extends Equatable implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({required this.message, this.code, this.details});

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException({required super.message, super.code, super.details});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when server/backend request fails
class ServerException extends AppException {
  const ServerException({required super.message, super.code, super.details});

  @override
  String toString() =>
      'ServerException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when network connection fails
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code, super.details});

  @override
  String toString() =>
      'NetworkException: $message${code != null ? ' (code: $code)' : ''}';
}

class LocationPermissionException extends AppException {
  const LocationPermissionException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() =>
      'NetworkException: $message${code != null ? ' (code: $code)' : ''}';
}

class LocationServiceException extends AppException {
  const LocationServiceException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() =>
      'NetworkException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  const CacheException({required super.message, super.code, super.details});

  @override
  String toString() =>
      'CacheException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when user cancels an operation
class CancelledException extends AppException {
  const CancelledException({
    super.message = 'Operation cancelled by user',
    super.code,
    super.details,
  });

  @override
  String toString() => 'CancelledException: $message';
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'ValidationException: $message';
}
