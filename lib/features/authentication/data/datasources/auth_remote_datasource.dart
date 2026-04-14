import 'package:account_ledger/features/authentication/data/datasources/social_auth_datasource.dart';
import 'package:dio/dio.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/network/api_endpoints.dart';
import 'package:account_ledger/features/authentication/data/models/auth_response_model.dart';
import 'package:account_ledger/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });
  Future<AuthResponseModel> authenticateWithSocial(SocialAuthData authData);
  Future<Map<String, String>> refreshSession({required String refreshToken});
  Future<UserModel> getUser();
  Future<void> registerDevice(Map<String, dynamic> data);

  /// OTP email sent; response has [message] only (no user/tokens).
  Future<String> register({
    required String name,
    required String email,
    required String phone,
    required String defaultCurrency,
    required DateTime dateOfBirth,
    required String password,
  });

  Future<AuthResponseModel> verifyRegistrationOtp({
    required String email,
    required String otp,
  });

  Future<void> logout();
  Future<void> resendOtp({required String email});
  Future<String> forgotPassword({required String email});
  Future<String> verifyResetOtp({required String email, required String otp});
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<void> resetPassword({
    required String resetToken,
    required String password,
  });
  Future<void> deleteAccount();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  const AuthRemoteDatasourceImpl({required this.dio});

  Never _throwTypedDio(DioException e, String scope) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException(
        message: 'Connection timed out. Please try again.',
        code: '$scope-timeout',
        details: e.message,
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      throw const NetworkException(
        message: 'No internet connection',
        code: 'no-internet',
      );
    }
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    int? retryAfterSeconds;
    if (data is Map<String, dynamic> && data['retryAfterSeconds'] != null) {
      final r = data['retryAfterSeconds'];
      if (r is int) {
        retryAfterSeconds = r;
      } else if (r is num) {
        retryAfterSeconds = r.toInt();
      }
    }
    throw ServerException(
      message: _extractErrorMessage(data, statusCode),
      code: '$scope-failed-${statusCode ?? 'unknown'}',
      details: data ?? e.toString(),
      retryAfterSeconds: retryAfterSeconds,
    );
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final authResponse = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return authResponse;
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'login');
    }
  }

  @override
  Future<Map<String, String>> refreshSession({
    required String refreshToken,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );
      final data = response.data;

      final map = Map<String, dynamic>.from(data);
      final access =
          (map['accessToken'] ?? map['access_token'] ?? map['token'] ?? '')
              as String;
      final rotatedRefresh =
          (map['refreshToken'] ?? map['refresh_token'] ?? '') as String;
      if (access.isEmpty) {
        throw const ServerException(
          message: 'Missing access token in refresh response',
          code: 'missing-access-after-refresh',
        );
      }
      return {
        'accessToken': access,
        'refreshToken': rotatedRefresh.isNotEmpty
            ? rotatedRefresh
            : refreshToken,
      };
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'refresh');
    }
  }

  @override
  Future<UserModel> getUser() async {
    try {
      final response = await dio.get(ApiEndpoints.getUser);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final user = data['user'];
        if (user is Map<String, dynamic>) {
          return UserModel.fromJson(user);
        }
        return UserModel.fromJson(data);
      }
      throw const ServerException(
        message: 'Invalid user response',
        code: 'invalid-user-response',
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'get-user');
    }
  }

  @override
  Future<String> register({
    required String name,
    required String email,
    required String phone,
    required String defaultCurrency,
    required DateTime dateOfBirth,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'defaultCurrency': defaultCurrency,
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'password': password,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
      throw const ServerException(
        message: 'Unexpected registration response',
        code: 'register-invalid-response',
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'register');
    }
  }

  @override
  Future<AuthResponseModel> verifyRegistrationOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyOtp,
        data: {'email': email, 'otp': otp},
        options: Options(extra: {'skipAuth': true}),
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'verify-otp');
    }
  }

  @override
  Future<AuthResponseModel> authenticateWithSocial(
    SocialAuthData authData,
  ) async {
    try {
      final body = <String, dynamic>{'idToken': authData.idToken};
      final String endpoint = ApiEndpoints.googleAuth;
      final response = await dio.post(endpoint, data: body);
      final authResponse = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return authResponse;
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'social-auth');
    } catch (e) {
      throw ServerException(
        message: 'Social sign-in failed',
        code: 'social-auth-failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post(ApiEndpoints.logout);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'logout');
    }
  }

  String _extractErrorMessage(dynamic data, int? statusCode) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty && value.first is String) {
            return value.first as String;
          }
          if (value is String && value.isNotEmpty) {
            return value;
          }
        }
      }
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }

    if (statusCode == 422) {
      return 'Invalid credentials. Please check email and password.';
    }
    if (statusCode == 401) {
      return 'Session expired. Please log in again.';
    }
    return 'Request failed. Please try again. $statusCode';
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await dio.delete(ApiEndpoints.deleteAccount);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'delete-account');
    }
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await dio.post(
        ApiEndpoints.forgotPassword,
        data: {"email": email},
      );
      final data = response.data;
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      throw const ServerException(
        message: 'Invalid forgot-password response',
        code: 'forgot-password-invalid-response',
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'forgot-password');
    }
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    try {
      await dio.post(
        ApiEndpoints.resetPassword,
        data: {'resetToken': resetToken, 'password': password},
        options: Options(extra: {'skipAuth': true}),
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'reset-password');
    }
  }

  @override
  Future<String> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyResetOtp,
        data: {'email': email, 'otp': otp},
        options: Options(extra: {'skipAuth': true}),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final token = data['resetToken'];
        if (token is String && token.isNotEmpty) {
          return token;
        }
      }
      throw const ServerException(
        message: 'Invalid verify-reset-otp response',
        code: 'verify-reset-otp-invalid',
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'verify-reset-otp');
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    try {
      await dio.post(ApiEndpoints.resendOtp, data: {'email': email});
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'resend-otp');
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await dio.post(
        ApiEndpoints.changePassword,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'change-password');
    }
  }

  @override
  Future<void> registerDevice(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiEndpoints.registerDevice, data: data);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'register-device');
    }
  }
}
