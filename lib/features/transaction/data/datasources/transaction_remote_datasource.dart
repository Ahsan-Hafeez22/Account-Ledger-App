import 'package:dio/dio.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/network/api_endpoints.dart';
import 'package:account_ledger/features/transaction/data/models/transaction_model.dart';
import 'package:account_ledger/features/transaction/data/models/transaction_pagination_model.dart';
import 'package:account_ledger/features/transaction/data/models/transaction_status_check_model.dart';

enum CreateTransactionRemoteKind {
  /// 201 or equivalent: full transaction in body.
  completed,

  /// 200 — already completed, includes transaction.
  alreadyCompleted,

  /// 200 — server still processing; no completed transaction yet.
  stillProcessing,
}

class CreateTransactionRemoteResult {
  final CreateTransactionRemoteKind kind;
  final TransactionModel? transaction;

  const CreateTransactionRemoteResult({
    required this.kind,
    this.transaction,
  });
}

abstract class TransactionRemoteDatasource {
  Future<CreateTransactionRemoteResult> createTransaction({
    required String toAccount,
    required double amount,
    required String idempotencyKey,
    String? description,
  });

  Future<TransactionStatusCheckModel> checkStatusByIdempotencyKey(
    String idempotencyKey,
  );

  Future<({List<TransactionModel> list, TransactionPaginationModel page})>
  getTransactions({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<TransactionModel> getTransactionDetail(String transactionId);
}

class TransactionRemoteDatasourceImpl implements TransactionRemoteDatasource {
  final Dio dio;

  const TransactionRemoteDatasourceImpl({required this.dio});

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
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return 'Request failed${statusCode != null ? ' ($statusCode)' : ''}';
  }

  @override
  Future<CreateTransactionRemoteResult> createTransaction({
    required String toAccount,
    required double amount,
    required String idempotencyKey,
    String? description,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.createTransaction,
        data: {
          'toAccount': toAccount,
          'amount': amount,
          'idempotencyKey': idempotencyKey,
          'description': description ?? '',
        },
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid create-transaction response',
          code: 'invalid-create-transaction-response',
        );
      }

      final code = response.statusCode ?? 0;
      if (code == 201) {
        final txn = data['transaction'];
        if (txn is! Map<String, dynamic>) {
          throw const ServerException(
            message: 'Invalid create-transaction payload',
            code: 'missing-transaction-object',
          );
        }
        return CreateTransactionRemoteResult(
          kind: CreateTransactionRemoteKind.completed,
          transaction: TransactionModel.fromJson(txn),
        );
      }

      if (code == 200) {
        final message = (data['message'] as String?)?.toLowerCase() ?? '';
        if (message.contains('still processing')) {
          return const CreateTransactionRemoteResult(
            kind: CreateTransactionRemoteKind.stillProcessing,
          );
        }
        if (message.contains('already completed')) {
          final txn = data['transaction'];
          if (txn is Map<String, dynamic>) {
            return CreateTransactionRemoteResult(
              kind: CreateTransactionRemoteKind.alreadyCompleted,
              transaction: TransactionModel.fromJson(txn),
            );
          }
        }
        final txn = data['transaction'];
        if (txn is Map<String, dynamic>) {
          return CreateTransactionRemoteResult(
            kind: CreateTransactionRemoteKind.alreadyCompleted,
            transaction: TransactionModel.fromJson(txn),
          );
        }
        return const CreateTransactionRemoteResult(
          kind: CreateTransactionRemoteKind.stillProcessing,
        );
      }

      throw ServerException(
        message: _extractErrorMessage(data, code),
        code: 'create-transaction-unexpected-$code',
        details: data,
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'create-transaction');
    }
  }

  @override
  Future<TransactionStatusCheckModel> checkStatusByIdempotencyKey(
    String idempotencyKey,
  ) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.checkTransactionStatus,
        queryParameters: {'idempotencyKey': idempotencyKey},
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid check-status response',
          code: 'invalid-check-status-response',
        );
      }
      final inner = data['data'];
      if (inner is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid check-status payload',
          code: 'invalid-check-status-payload',
        );
      }
      return TransactionStatusCheckModel.fromJson(inner);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'check-transaction-status');
    }
  }

  @override
  Future<({List<TransactionModel> list, TransactionPaginationModel page})>
  getTransactions({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (startDate != null) {
        query['startDate'] = startDate.toUtc().toIso8601String();
      }
      if (endDate != null) {
        query['endDate'] = endDate.toUtc().toIso8601String();
      }

      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.listTransactions,
        queryParameters: query,
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid transactions list response',
          code: 'invalid-transactions-response',
        );
      }
      final inner = data['data'];
      if (inner is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid transactions list payload',
          code: 'invalid-transactions-payload',
        );
      }
      final rawList = inner['transactions'];
      final paginationRaw = inner['pagination'];
      final list = <TransactionModel>[];
      if (rawList is List) {
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            list.add(TransactionModel.fromJson(item));
          } else if (item is Map) {
            list.add(TransactionModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
      final pageModel = paginationRaw is Map<String, dynamic>
          ? TransactionPaginationModel.fromJson(paginationRaw)
          : TransactionPaginationModel.fromJson(null);
      return (list: list, page: pageModel);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'list-transactions');
    }
  }

  @override
  Future<TransactionModel> getTransactionDetail(String transactionId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.getTransactionDetail(transactionId),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid transaction detail response',
          code: 'invalid-transaction-detail-response',
        );
      }
      final txn = data['transaction'];
      if (txn is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid transaction detail payload',
          code: 'invalid-transaction-detail-payload',
        );
      }
      return TransactionModel.fromJson(txn);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'transaction-detail');
    }
  }
}
