import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/features/transaction/data/datasources/transaction_pending_local_datasource.dart';
import 'package:account_ledger/features/transaction/data/datasources/transaction_remote_datasource.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_list_page_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_status_check_entity.dart';
import 'package:account_ledger/features/transaction/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required TransactionRemoteDatasource remote,
    required TransactionPendingLocalDatasource pending,
  }) : _remote = remote,
       _pending = pending;

  static const _maxSyncSteps = 28;
  static const _pollDelay = Duration(milliseconds: 750);

  final TransactionRemoteDatasource _remote;
  final TransactionPendingLocalDatasource _pending;

  @override
  Future<Either<Failure, TransactionListPageEntity>> getTransactions({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _remote.getTransactions(
        page: page,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(
        TransactionListPageEntity(
          transactions: result.list.map((e) => e.toEntity()).toList(),
          pagination: result.page.toEntity(),
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionDetail(
    String transactionId,
  ) async {
    try {
      final model = await _remote.getTransactionDetail(transactionId);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, TransactionStatusCheckEntity>> checkStatus(
    String idempotencyKey,
  ) async {
    try {
      final model = await _remote.checkStatusByIdempotencyKey(idempotencyKey);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransfer({
    required String toAccount,
    required double amount,
    String? description,
  }) async {
    try {
      final payload = await _resolvePayload(
        toAccount: toAccount,
        amount: amount,
        description: description,
      );
      await _pending.savePending(payload);
      return await _syncUntilComplete(
        payload: payload,
        initialPostAlreadyDone: false,
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, String?>> recoverPendingTransfer() async {
    try {
      final stored = await _pending.readPending();
      if (stored == null) return const Right(null);
      final result = await _syncUntilComplete(
        payload: stored,
        initialPostAlreadyDone: true,
      );
      return result.fold(
        Left.new,
        (_) => const Right('Transaction completed successfully.'),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    }
  }

  Future<PendingTransferPayload> _resolvePayload({
    required String toAccount,
    required double amount,
    String? description,
  }) async {
    final trimmedTo = toAccount.trim();
    final desc = description?.trim() ?? '';
    final existing = await _pending.readPending();
    if (existing != null &&
        existing.toAccount == trimmedTo &&
        existing.amount == amount &&
        existing.description == desc) {
      return existing;
    }
    return PendingTransferPayload(
      idempotencyKey: const Uuid().v4(),
      toAccount: trimmedTo,
      amount: amount,
      description: desc,
    );
  }

  Future<Either<Failure, TransactionEntity>?> _tryResolveCreateResult(
    CreateTransactionRemoteResult r,
    PendingTransferPayload payload,
  ) async {
    switch (r.kind) {
      case CreateTransactionRemoteKind.completed:
      case CreateTransactionRemoteKind.alreadyCompleted:
        await _pending.clearPending();
        if (r.transaction != null) {
          return Right(r.transaction!.toEntity());
        }
        try {
          final check = await _remote.checkStatusByIdempotencyKey(
            payload.idempotencyKey,
          );
          final detail = await _remote.getTransactionDetail(
            check.transactionId,
          );
          return Right(detail.toEntity());
        } on AppException catch (e) {
          return Left(
            ServerFailure(
              message: e.message,
              code: e.code ?? 'txn-resolve-failed',
            ),
          );
        }
      case CreateTransactionRemoteKind.stillProcessing:
        return null;
    }
  }

  Future<Either<Failure, TransactionEntity>> _syncUntilComplete({
    required PendingTransferPayload payload,
    required bool initialPostAlreadyDone,
  }) async {
    if (!initialPostAlreadyDone) {
      final first = await _remote.createTransaction(
        toAccount: payload.toAccount,
        amount: payload.amount,
        idempotencyKey: payload.idempotencyKey,
        description: payload.description.isEmpty ? null : payload.description,
      );
      final resolved = await _tryResolveCreateResult(first, payload);
      if (resolved != null) return resolved;
    }

    for (var step = 0; step < _maxSyncSteps; step++) {
      if (step > 0) await Future<void>.delayed(_pollDelay);

      try {
        final check = await _remote.checkStatusByIdempotencyKey(
          payload.idempotencyKey,
        );
        final u = check.status.toUpperCase();
        if (u == 'COMPLETED') {
          await _pending.clearPending();
          try {
            final detail = await _remote.getTransactionDetail(
              check.transactionId,
            );
            return Right(detail.toEntity());
          } on AppException {
            return Right(
              TransactionEntity(
                id: check.transactionId,
                amount: check.amount,
                status: 'COMPLETED',
                createdAt: check.createdAt,
              ),
            );
          }
        }
        if (u == 'FAILED' || u == 'REVERSED') {
          await _pending.clearPending();
          final msg = u == 'REVERSED'
              ? 'This transaction was reversed.'
              : 'Transaction failed.';
          return Left(ServerFailure(message: msg, code: 'txn-terminal-$u'));
        }

        final again = await _remote.createTransaction(
          toAccount: payload.toAccount,
          amount: payload.amount,
          idempotencyKey: payload.idempotencyKey,
          description: payload.description.isEmpty ? null : payload.description,
        );
        final afterPost = await _tryResolveCreateResult(again, payload);
        if (afterPost != null) return afterPost;
      } on ServerException catch (e) {
        final is404 = e.code?.contains('404') ?? false;
        if (is404) await _pending.clearPending();
        return Left(ServerFailure(message: e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      }
    }

    return Left(
      ServerFailure(
        message:
            'Unable to confirm the transaction. Please check your connection and try again.',
        code: 'txn-sync-timeout',
      ),
    );
  }
}
