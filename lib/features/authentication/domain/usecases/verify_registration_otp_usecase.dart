import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';
import 'package:account_ledger/features/authentication/domain/repositories/auth_repository.dart';

class VerifyRegistrationOtpUseCase
    extends UseCase<UserEntity, VerifyRegistrationOtpParams> {
  final AuthRepository repository;

  VerifyRegistrationOtpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(VerifyRegistrationOtpParams params) {
    return repository.verifyRegistrationOtp(
      email: params.email,
      otp: params.otp,
    );
  }
}

class VerifyRegistrationOtpParams extends Equatable {
  final String email;
  final String otp;

  const VerifyRegistrationOtpParams({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}
