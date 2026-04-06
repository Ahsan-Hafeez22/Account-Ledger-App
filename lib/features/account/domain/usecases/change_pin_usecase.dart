import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/account/domain/repositories/account_repository.dart';
import 'package:dartz/dartz.dart';

class ChangePinUsecase extends UseCase<void, ChangePinParams> {
  AccountRepository repository;
  ChangePinUsecase(this.repository);
  @override
  Future<Either<Failure, void>> call(ChangePinParams params) {
    return repository.changePin(newPin: params.newPin, oldPin: params.oldPin);
  }
}

class ChangePinParams {
  final String oldPin;
  final String newPin;
  ChangePinParams({required this.oldPin, required this.newPin});
}
