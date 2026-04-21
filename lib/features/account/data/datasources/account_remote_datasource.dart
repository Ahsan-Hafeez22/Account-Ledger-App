import 'package:dio/dio.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/network/api_endpoints.dart';
import 'package:account_ledger/features/account/data/models/account_model.dart';

abstract class AccountRemoteDatasource {
  /// `null` when the server returns 400 "No Account available".
  Future<AccountModel?> getAccount();

  Future<AccountModel> createAccount({
    required String accountTitle,
    required String pin,
  });

  Future<void> changePin({required String oldPin, required String newPin});

  Future<void> changeAccountStatus({required String status});

  Future<double> getAccountBalance({required String accountNumber});
}

class AccountRemoteDatasourceImpl implements AccountRemoteDatasource {
  final Dio dio;

  const AccountRemoteDatasourceImpl({required this.dio});

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
    throw ServerException(
      message: _extractErrorMessage(data, statusCode),
      code: '$scope-failed-${statusCode ?? 'unknown'}',
      details: data ?? e.toString(),
    );
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
    }
    return 'Request failed${statusCode != null ? ' ($statusCode)' : ''}';
  }

  @override
  Future<AccountModel?> getAccount() async {
    try {
      final response = await dio.get(ApiEndpoints.getAccount);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid accounts response',
          code: 'invalid-accounts-response',
        );
      }
      final raw = data['accounts'];
      if (raw is Map<String, dynamic>) {
        return AccountModel.fromJson(raw);
      }
      if (raw is List) {
        if (raw.isEmpty) return null;
        final first = raw.first;
        if (first is Map<String, dynamic>) {
          return AccountModel.fromJson(first);
        }
      }
      throw const ServerException(
        message: 'Invalid accounts payload',
        code: 'invalid-accounts-payload',
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final body = e.response?.data;
      if (statusCode == 400 && body is Map<String, dynamic>) {
        final msg = body['message'];
        if (msg is String && msg.toLowerCase().contains('no account')) {
          return null;
        }
      }
      _throwTypedDio(e, 'get-account');
    }
  }

  @override
  Future<AccountModel> createAccount({
    required String accountTitle,
    required String pin,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createAccount,
        data: {'accountTitle': accountTitle, 'pin': pin},
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid create-account response',
          code: 'invalid-create-account-response',
        );
      }
      final account = data['account'];
      if (account is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid create-account response',
          code: 'missing-account-object',
        );
      }
      return AccountModel.fromJson(account);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'create-account');
    }
  }

  @override
  Future<void> changeAccountStatus({required String status}) async {
    try {
      await dio.patch(ApiEndpoints.changeAccountStatus(status));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'change-account-status');
    }
  }

  @override
  Future<void> changePin({
    required String oldPin,
    required String newPin,
  }) async {
    try {
      await dio.post(
        ApiEndpoints.changePin,
        data: {'oldPin': oldPin, 'newPin': newPin},
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'change-pin');
    }
  }

  @override
  Future<double> getAccountBalance({required String accountNumber}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.accountBalance(accountNumber),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final b = data['balance'];
        if (b is num) return b.toDouble();
        if (b is String) return double.tryParse(b) ?? 0;
      }
      throw const ServerException(
        message: 'Invalid balance response',
        code: 'invalid-balance-response',
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'get-balance');
    }
  }
}
