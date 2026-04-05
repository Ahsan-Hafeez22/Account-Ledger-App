import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/authentication/domain/repositories/auth_repository.dart';

class VerifyResetOtpUseCase extends UseCase<String, VerifyResetOtpParams> {
  final AuthRepository repository;

  VerifyResetOtpUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(VerifyResetOtpParams params) {
    return repository.verifyResetOtp(email: params.email, otp: params.otp);
  }
}

class VerifyResetOtpParams extends Equatable {
  final String email;
  final String otp;

  const VerifyResetOtpParams({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}
