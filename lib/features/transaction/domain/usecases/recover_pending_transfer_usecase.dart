import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/transaction/domain/repositories/transaction_repository.dart';

/// Completes a transfer that was left in secure storage after an uncertain
/// network outcome.
class RecoverPendingTransferUseCase implements UseCase<String?, NoParams> {
  final TransactionRepository _repository;

  RecoverPendingTransferUseCase(this._repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) {
    return _repository.recoverPendingTransfer();
  }
}
