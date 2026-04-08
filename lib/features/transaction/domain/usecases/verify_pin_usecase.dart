import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:dartz/dartz.dart';

class VerfiyPinUsecase extends UseCase<void, VerifyPinParams> {
  final TransactionRepository repository;
  VerfiyPinUsecase(this.repository);
  @override
  Future<Either<Failure, void>> call(VerifyPinParams params) {
    return repository.verifyPin(params.pin);
  }
}

class VerifyPinParams {
  final String pin;
  VerifyPinParams({required this.pin});
}
