import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/authentication/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase extends UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return repository.resetPassword(
      resetToken: params.resetToken,
      password: params.password,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String resetToken;
  final String password;

  const ResetPasswordParams({
    required this.resetToken,
    required this.password,
  });

  @override
  List<Object?> get props => [resetToken, password];
}
