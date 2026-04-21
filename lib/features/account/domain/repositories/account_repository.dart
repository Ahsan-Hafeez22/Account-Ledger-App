import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/features/account/domain/entities/account_entity.dart';

abstract class AccountRepository {
  /// [Right(null)] when the user has no wallet yet (API 400 "No Account available").
  Future<Either<Failure, AccountEntity?>> getAccount();

  Future<Either<Failure, AccountEntity>> createAccount({
    required String accountTitle,
    required String pin,
  });
  Future<Either<Failure, void>> changePin({
    required String oldPin,
    required String newPin,
  });
  Future<Either<Failure, void>> changeAccountStatus({required String status});

  Future<Either<Failure, double>> getAccountBalance({
    required String accountNumber,
  });
}
