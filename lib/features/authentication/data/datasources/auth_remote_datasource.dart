import 'package:dio/dio.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/network/api_endpoints.dart';
import 'package:account_ledger/features/authentication/data/models/auth_response_model.dart';
// import 'package:account_ledger/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  const AuthRemoteDatasourceImpl({required this.dio});

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
      final statusCode = e.response?.statusCode;
      throw ServerException(
        message: _extractErrorMessage(e.response?.data, statusCode),
        code: 'login-failed-${statusCode ?? 'unknown'}',
        details: e.response?.data ?? e.toString(),
      );
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      final authResponse = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return authResponse;
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw ServerException(
        message: _extractErrorMessage(e.response?.data, statusCode),
        code: 'signup-failed-${statusCode ?? 'unknown'}',
        details: e.response?.data ?? e.toString(),
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
      final statusCode = e.response?.statusCode;
      throw ServerException(
        message: _extractErrorMessage(e.response?.data, statusCode),
        code: 'logout-failed-${statusCode ?? 'unknown'}',
        details: e.response?.data ?? e.toString(),
      );
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
    return 'Request failed. Please try again.';
  }
}
