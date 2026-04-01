import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';
import 'package:account_ledger/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GoogleAuthUsecase implements UseCase<UserEntity, NoParams> {
  final AuthRepository _authRepository;
  GoogleAuthUsecase(this._authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await _authRepository.signInWithGoogle();
  }
}
