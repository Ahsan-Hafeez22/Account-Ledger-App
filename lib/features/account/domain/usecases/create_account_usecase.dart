import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/account/domain/entities/account_entity.dart';
import 'package:account_ledger/features/account/domain/repositories/account_repository.dart';

class CreateAccountUseCase extends UseCase<AccountEntity, CreateAccountParams> {
  final AccountRepository repository;

  CreateAccountUseCase(this.repository);

  @override
  Future<Either<Failure, AccountEntity>> call(CreateAccountParams params) {
    return repository.createAccount(
      accountTitle: params.accountTitle,
      pin: params.pin,
    );
  }
}

class CreateAccountParams extends Equatable {
  final String accountTitle;
  final String pin;

  const CreateAccountParams({
    required this.accountTitle,
    required this.pin,
  });

  @override
  List<Object?> get props => [accountTitle, pin];
}
