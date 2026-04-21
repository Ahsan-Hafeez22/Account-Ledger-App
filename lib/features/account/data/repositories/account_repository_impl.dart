import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/features/account/data/datasources/account_remote_datasource.dart';
import 'package:account_ledger/features/account/domain/entities/account_entity.dart';
import 'package:account_ledger/features/account/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDatasource _remote;

  const AccountRepositoryImpl({required AccountRemoteDatasource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, AccountEntity?>> getAccount() async {
    try {
      final model = await _remote.getAccount();
      return Right(model?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> createAccount({
    required String accountTitle,
    required String pin,
  }) async {
    try {
      final model = await _remote.createAccount(
        accountTitle: accountTitle,
        pin: pin,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, void>> changeAccountStatus({
    required String status,
  }) async {
    try {
      await _remote.changeAccountStatus(status: status);
      return Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, void>> changePin({
    required String oldPin,
    required String newPin,
  }) async {
    try {
      await _remote.changePin(oldPin: oldPin, newPin: newPin);
      return Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, double>> getAccountBalance({
    required String accountNumber,
  }) async {
    try {
      final balance = await _remote.getAccountBalance(accountNumber: accountNumber);
      return Right(balance);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    }
  }
}
