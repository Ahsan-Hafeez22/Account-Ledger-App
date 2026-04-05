import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/authentication/domain/repositories/auth_repository.dart';

class ResendRegistrationOtpUseCase
    extends UseCase<void, ResendRegistrationOtpParams> {
  final AuthRepository repository;

  ResendRegistrationOtpUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResendRegistrationOtpParams params) {
    return repository.resendRegistrationOtp(email: params.email);
  }
}

class ResendRegistrationOtpParams extends Equatable {
  final String email;

  const ResendRegistrationOtpParams({required this.email});

  @override
  List<Object?> get props => [email];
}
