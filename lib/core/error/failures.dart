import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Uses sealed class to ensure exhaustive pattern matching
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' (code: $code)' : ''}';
}

/// Failure when server/backend request fails
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred', super.code});
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure({
    super.message = 'Location Permission Failure',
    super.code,
  });
}

class LocationServiceFailure extends Failure {
  const LocationServiceFailure({
    super.message = 'Location Service Failure',
    super.code,
  });
}

/// Failure when network connection is unavailable
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection', super.code});
}

/// Failure when cache operations fail
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred', super.code});
}

/// Failure when credentials are invalid or user is unauthorized
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Invalid credentials',
    super.code,
  });
}

/// Failure when input validation fails
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Failure when authentication process fails
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed', super.code});
}

/// Failure when user cancels an operation
class CancelledFailure extends Failure {
  const CancelledFailure({
    super.message = 'Operation cancelled by user',
    super.code,
  });
}

/// Failure when user is not found
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure({super.message = 'User not found', super.code});
}

/// Failure when email is already in use
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure({
    super.message = 'Email is already registered',
    super.code,
  });
}

/// Failure when phone number is already in use
class PhoneAlreadyInUseFailure extends Failure {
  const PhoneAlreadyInUseFailure({
    super.message = 'Phone number is already registered',
    super.code,
  });
}

/// Failure when password is too weak
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure({
    super.message = 'Password is too weak',
    super.code,
  });
}
