import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_list_page_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_status_check_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, TransactionListPageEntity>> getTransactions({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, TransactionEntity>> getTransactionDetail(
    String transactionId,
  );

  Future<Either<Failure, TransactionStatusCheckEntity>> checkStatus(
    String idempotencyKey,
  );

  Future<Either<Failure, void>> verifyPin(String pin);

  /// Persists idempotency payload, creates the transaction, then polls
  /// [check-status] and retries [create-transaction] while status is PENDING.
  Future<Either<Failure, TransactionEntity>> createTransfer({
    required String toAccount,
    required double amount,
    String? description,
  });

  /// When a pending payload exists (e.g. after an interrupted request), sync
  /// with the server. [Right(null)] if there was nothing pending.
  /// [Right(message)] when a pending transfer finished successfully.
  Future<Either<Failure, String?>> recoverPendingTransfer();
}
