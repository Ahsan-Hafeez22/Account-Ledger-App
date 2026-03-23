import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';
import 'package:account_ledger/features/authentication/domain/repositories/auth_repository.dart';

class GetCachedUserUseCase extends UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  GetCachedUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return repository.getCachedUser();
  }
}
