import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Starts registration: server sends OTP email (no tokens yet).
  Future<Either<Failure, String>> register({
    required String name,
    required String email,
    required String phone,
    required String defaultCurrency,
    required DateTime dateOfBirth,
    required String password,
  });

  Future<Either<Failure, UserEntity>> verifyRegistrationOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, void>> resendRegistrationOtp({required String email});

  Future<Either<Failure, String>> forgotPassword({required String email});

  Future<Either<Failure, String>> verifyResetOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, void>> resetPassword({
    required String resetToken,
    required String password,
  });

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> signInWithGoogle();
}
